import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/addressFormItem.dart';
import 'package:polkawallet_ui/components/addressInputField.dart';
import 'package:polkawallet_ui/components/txButton.dart';
import 'package:polkawallet_ui/pages/accountListPage.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/index.dart';

class BondPage extends StatefulWidget {
  BondPage(this.plugin, this.keyring);
  static final String route = '/staking/bond';
  final PluginKusama plugin;
  final Keyring keyring;
  @override
  _BondPageState createState() => _BondPageState();
}

class _BondPageState extends State<BondPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountCtrl = new TextEditingController();

  final _rewardToOptions = ['Staked', 'Stash', 'Controller'];

  KeyPairData _controller;

  int _rewardTo = 0;
  String _rewardAccount;

  Future<void> _changeControllerId(BuildContext context) async {
    final accounts = widget.keyring.keyPairs.toList();
    accounts.addAll(widget.keyring.externals);
    final acc = await Navigator.of(context).pushNamed(
      AccountListPage.route,
      arguments: AccountListPageParams(list: accounts),
    );
    if (acc != null) {
      setState(() {
        _controller = acc;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).getDic(i18n_full_dic_kusama, 'common');
    final dicStaking = I18n.of(context).getDic(i18n_full_dic_kusama, 'staking');
    final symbol = widget.plugin.networkState.tokenSymbol;
    final decimals = widget.plugin.networkState.tokenDecimals;

    double available = 0;
    if (widget.plugin.balances.native != null) {
      available = Fmt.balanceDouble(
          widget.plugin.balances.native.availableBalance.toString(), decimals);
    }

    final rewardToOptions =
        _rewardToOptions.map((i) => dicStaking['reward.$i']).toList();

    List<KeyPairData> accounts;
    if (_rewardTo == 3) {
      accounts = widget.keyring.keyPairs;
      accounts.addAll(widget.keyring.externals);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(dicStaking['action.bond']),
        centerTitle: true,
      ),
      body: Builder(builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 16, right: 16, top: 8),
                        child: AddressFormItem(
                          widget.keyring.current,
                          label: dicStaking['stash'],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 16, right: 16),
                        child: AddressFormItem(
                          _controller ?? widget.keyring.current,
                          label: dic['controller'],
                          onTap: () => _changeControllerId(context),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 16, right: 16),
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: dic['amount'],
                            labelText:
                                '${dic['amount']} (${dicStaking['available']}: ${Fmt.priceFloor(
                              available,
                              lengthMax: 3,
                            )} $symbol)',
                          ),
                          inputFormatters: [UI.decimalInputFormatter(decimals)],
                          controller: _amountCtrl,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          validator: (v) {
                            if (v.isEmpty) {
                              return dic['amount.error'];
                            }
                            if (double.parse(v.trim()) >= available) {
                              return dic['amount.low'];
                            }
                            return null;
                          },
                        ),
                      ),
                      ListTile(
                        title: Text(dic['bond.reward']),
                        subtitle: Text(rewardToOptions[_rewardTo]),
                        trailing: Icon(Icons.arrow_forward_ios, size: 18),
                        onTap: () {
                          showCupertinoModalPopup(
                            context: context,
                            builder: (_) => Container(
                              height: MediaQuery.of(context)
                                      .copyWith()
                                      .size
                                      .height /
                                  3,
                              child: CupertinoPicker(
                                backgroundColor: Colors.white,
                                itemExtent: 56,
                                scrollController: FixedExtentScrollController(
                                    initialItem: _rewardTo),
                                children: rewardToOptions
                                    .map((i) => Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Text(
                                          i,
                                          style: TextStyle(fontSize: 16),
                                        )))
                                    .toList(),
                                onSelectedItemChanged: (v) {
                                  setState(() {
                                    _rewardTo = v;
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      _rewardTo == 3
                          ? Padding(
                              padding: EdgeInsets.only(left: 16, right: 16),
                              child: AddressInputField(
                                widget.plugin.sdk.api,
                                accounts,
                                onChanged: (acc) {
                                  setState(() {
                                    _rewardAccount = acc.address;
                                  });
                                },
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: TxButton(
                  getTxParams: () async {
                    if (_formKey.currentState.validate()) {
                      final inputAmount = _amountCtrl.text.trim();
                      String controllerId = widget.keyring.current.address;
                      if (_controller != null) {
                        controllerId = _controller.address;
                      }
                      return TxConfirmParams(
                        txTitle: dicStaking['action.bond'],
                        module: 'staking',
                        call: 'bond',
                        txDisplay: {
                          "amount": '$inputAmount $symbol',
                          "reward_destination": _rewardTo == 3
                              ? {'Account': _rewardAccount}
                              : rewardToOptions[_rewardTo],
                        },
                        params: [
                          // "controllerId":
                          controllerId,
                          // "amount"
                          Fmt.tokenInt(inputAmount, decimals).toString(),
                          // "to"
                          _rewardTo == 3
                              ? {'Account': _rewardAccount}
                              : _rewardTo,
                        ],
                      );
                    }
                    return null;
                  },
                  onFinish: (Map res) {
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
