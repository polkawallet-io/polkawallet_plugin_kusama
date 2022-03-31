import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/api/types/staking/ownStashInfo.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/textTag.dart';
import 'package:polkawallet_ui/components/txButton.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginAddressFormItem.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginAddressTextFormField.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginInputItem.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginScaffold.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginTxButton.dart';

class SetPayeePage extends StatefulWidget {
  SetPayeePage(this.plugin, this.keyring);
  static final String route = '/staking/payee';
  final PluginKusama plugin;
  final Keyring keyring;
  @override
  _SetPayeePageState createState() => _SetPayeePageState();
}

class _SetPayeePageState extends State<SetPayeePage> {
  final _formKey = GlobalKey<FormState>();

  int? _rewardTo;
  String? _rewardAccount;

  Future<TxConfirmParams?> _getTxParams() async {
    if (!(_formKey.currentState?.validate() ?? false)) return null;

    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'staking');
    final rewardToOptions =
        PayeeSelector.options.map((i) => dic!['reward.$i']).toList();
    final OwnStashInfoData? currentPayee =
        widget.plugin.store.staking.ownStashInfo;

    if (_rewardTo == null) {
      bool noChange = false;
      if (currentPayee!.destinationId != 3 || _rewardAccount == null) {
        noChange = true;
      } else if (currentPayee.destinationId == 3 &&
          currentPayee.destination!.contains(_rewardAccount!.toLowerCase())) {
        noChange = true;
      }
      if (noChange) {
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Container(),
              content: Text('${dic!['reward.warn']}'),
              actions: <Widget>[
                CupertinoButton(
                  child: Text(I18n.of(context)!
                      .getDic(i18n_full_dic_kusama, 'common')!['ok']!),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
        return null;
      }
    }

    final to = _rewardTo ?? currentPayee!.destinationId;
    return TxConfirmParams(
      txTitle: dic!['action.setting'],
      module: 'staking',
      call: 'setPayee',
      txDisplay: {
        dic['bond.reward']:
            to == 3 ? {'Account': _rewardAccount} : rewardToOptions[to!],
      },
      params: [
        // "to"
        to == 3 ? {'Account': _rewardAccount} : to,
      ],
      isPlugin: true,
    );
  }

  void _onPayeeChanged(int? to, String? address) {
    setState(() {
      _rewardTo = to;
      _rewardAccount = address;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'staking')!;

    return PluginScaffold(
      appBar: PluginAppBar(
        title: Text(dic['v3.rewardDest']!),
        centerTitle: true,
      ),
      body: Builder(builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  padding: EdgeInsets.only(left: 16, right: 16, top: 8),
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: PluginAddressFormItem(
                        account: widget.keyring.current,
                        label: dic['controller'],
                      ),
                    ),
                    Form(
                      key: _formKey,
                      child: PayeeSelector(
                        widget.plugin,
                        widget.keyring,
                        initialValue: widget.plugin.store.staking.ownStashInfo,
                        onChange: _onPayeeChanged,
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: PluginTxButton(
                  getTxParams: _getTxParams,
                  onFinish: (Map? res) {
                    if (res != null) {
                      Navigator.of(context).pop(res);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class PayeeSelector extends StatefulWidget {
  PayeeSelector(this.plugin, this.keyring, {this.initialValue, this.onChange});

  static const options = ['Staked', 'Stash', 'Controller', 'Account'];

  final PluginKusama plugin;
  final Keyring keyring;
  final OwnStashInfoData? initialValue;
  final Function(int?, String?)? onChange;

  @override
  _PayeeSelectorState createState() => _PayeeSelectorState();
}

class _PayeeSelectorState extends State<PayeeSelector> {
  int? _rewardTo;
  KeyPairData? _rewardAccount;

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'staking')!;

    final rewardToOptions =
        PayeeSelector.options.map((i) => dic['reward.$i']).toList();

    KeyPairData defaultAcc = widget.keyring.current;
    if ((_rewardTo ?? widget.initialValue!.destinationId) == 3) {
      if (widget.initialValue!.destinationId == 3) {
        final acc = KeyPairData();
        acc.address = jsonDecode(widget.initialValue!.destination!)['account'];
        defaultAcc = acc;
      }
    }

    return PluginInputItem(
      label: dic['bond.reward']!,
      child: Column(
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      rewardToOptions[_rewardTo ??
                          widget.initialValue!.destinationId ??
                          0]!,
                      style: Theme.of(context).textTheme.headline4!.copyWith(
                          color: Color(0xCCFFFFFF), fontSize: 14, height: 1.2),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Color(0xCCFFFFFF),
                  )
                ],
              ),
            ),
            onTap: () {
              showCupertinoModalPopup(
                context: context,
                builder: (_) => Container(
                  height: MediaQuery.of(context).copyWith().size.height / 3,
                  child: CupertinoPicker(
                    backgroundColor: Colors.white,
                    itemExtent: 56,
                    scrollController: FixedExtentScrollController(
                        initialItem: _rewardTo ??
                            widget.initialValue!.destinationId ??
                            0),
                    children: rewardToOptions
                        .map((i) => Padding(
                              padding: EdgeInsets.all(12),
                              child: Text(
                                i!,
                                style: TextStyle(fontSize: 14),
                              ),
                            ))
                        .toList(),
                    onSelectedItemChanged: (v) {
                      setState(() {
                        _rewardTo = v;
                        _rewardAccount = widget.keyring.current;
                      });
                      widget.onChange!(v, widget.keyring.current.address);
                    },
                  ),
                ),
              );
            },
          ),
          Visibility(
            visible: (_rewardTo ?? widget.initialValue!.destinationId) == 3,
            child: Container(
              margin: EdgeInsets.only(top: 12),
              child: PluginAddressTextFormField(
                widget.plugin.sdk.api,
                widget.keyring.allWithContacts,
                initialValue: _rewardAccount ?? defaultAcc,
                onChanged: (acc) {
                  setState(() {
                    _rewardAccount = acc;
                  });
                  widget.onChange!(_rewardTo, acc.address);
                },
                key: ValueKey<KeyPairData?>(_rewardAccount),
              ),
            ),
          ),
          Visibility(
              visible: _rewardTo == 3,
              child: Row(
                children: [
                  Expanded(
                      child: TextTag(
                    dic['stake.payee.warn'],
                    color: Colors.deepOrange,
                    fontSize: 12,
                    margin: EdgeInsets.symmetric(vertical: 16),
                    padding: EdgeInsets.all(8),
                  ))
                ],
              )),
        ],
      ),
    );
  }
}
