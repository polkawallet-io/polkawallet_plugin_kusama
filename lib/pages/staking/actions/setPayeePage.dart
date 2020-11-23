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

class SetPayeePage extends StatefulWidget {
  SetPayeePage(this.plugin, this.keyring);
  static final String route = '/staking/payee';
  final PluginKusama plugin;
  final Keyring keyring;
  @override
  _SetPayeePageState createState() => _SetPayeePageState();
}

class _SetPayeePageState extends State<SetPayeePage> {
  final _rewardToOptions = ['Staked', 'Stash', 'Controller', 'Account'];

  int _rewardTo;
  String _rewardAccount;

  TxConfirmParams _getTxParams() {
    final dic = I18n.of(context).getDic(i18n_full_dic_kusama, 'staking');
    final rewardToOptions =
        _rewardToOptions.map((i) => dic['reward.$i']).toList();
    final currentPayee = _rewardToOptions
        .indexOf(widget.plugin.store.staking.ownStashInfo.destination);

    if (currentPayee == _rewardTo) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Container(),
            content: Text('${dic['reward.warn']}'),
            actions: <Widget>[
              CupertinoButton(
                child: Text(I18n.of(context)
                    .getDic(i18n_full_dic_kusama, 'common')['ok']),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
      return null;
    }

    return TxConfirmParams(
      txTitle: dic['action.setting'],
      module: 'staking',
      call: 'setPayee',
      txDisplay: {
        "reward_destination": _rewardTo == 3
            ? {'Account': _rewardAccount}
            : rewardToOptions[_rewardTo],
      },
      params: [
        // "to"
        _rewardTo == 3 ? {'Account': _rewardAccount} : _rewardTo,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).getDic(i18n_full_dic_kusama, 'staking');
    final defaultValue = ModalRoute.of(context).settings.arguments ?? 0;

    final rewardToOptions =
        _rewardToOptions.map((i) => dic['reward.$i']).toList();

    List<KeyPairData> accounts;
    if (_rewardTo == 3) {
      accounts = widget.keyring.keyPairs;
      accounts.addAll(widget.keyring.externals);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(dic['action.setting']),
        centerTitle: true,
      ),
      body: Builder(builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 16, right: 16, top: 8),
                      child: AddressFormItem(
                        widget.keyring.current,
                        label: dic['controller'],
                      ),
                    ),
                    ListTile(
                      title: Text(dic['bond.reward']),
                      subtitle:
                          Text(rewardToOptions[_rewardTo ?? defaultValue]),
                      trailing: Icon(Icons.arrow_forward_ios, size: 18),
                      onTap: () {
                        showCupertinoModalPopup(
                          context: context,
                          builder: (_) => Container(
                            height:
                                MediaQuery.of(context).copyWith().size.height /
                                    3,
                            child: CupertinoPicker(
                              backgroundColor: Colors.white,
                              itemExtent: 56,
                              scrollController: FixedExtentScrollController(
                                  initialItem: defaultValue),
                              children: rewardToOptions
                                  .map((i) => Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Text(
                                          i,
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ))
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
              Padding(
                padding: EdgeInsets.all(16),
                child: TxButton(
                  getTxParams: _getTxParams,
                  onFinish: (bool success) {
                    if (success != null && success) {
                      Navigator.of(context).pop(success);
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
