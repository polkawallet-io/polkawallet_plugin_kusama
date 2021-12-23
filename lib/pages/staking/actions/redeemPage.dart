import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/addressFormItem.dart';
import 'package:polkawallet_ui/components/txButton.dart';
import 'package:polkawallet_ui/components/v3/back.dart';
import 'package:polkawallet_ui/utils/format.dart';

class RedeemPage extends StatefulWidget {
  RedeemPage(this.plugin, this.keyring);
  static final String route = '/staking/redeem';
  final PluginKusama plugin;
  final Keyring keyring;
  @override
  _RedeemPageState createState() => _RedeemPageState();
}

class _RedeemPageState extends State<RedeemPage> {
  int? _slashingSpans;

  Future<int?> _getSlashingSpans() async {
    if (_slashingSpans != null) return _slashingSpans;

    final String stashId = widget.plugin.store.staking.ownStashInfo!.stashId ??
        widget.plugin.store.staking.ownStashInfo!.account!.accountId!;
    final int? spans =
        await widget.plugin.sdk.api.staking.getSlashingSpans(stashId);
    setState(() {
      _slashingSpans = spans;
    });
    return spans ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'common');
    final dicStaking =
        I18n.of(context)!.getDic(i18n_full_dic_kusama, 'staking')!;
    final symbol = widget.plugin.networkState.tokenSymbol![0];
    final decimals = widget.plugin.networkState.tokenDecimals![0];

    final redeemable = Fmt.balance(
        widget.plugin.store.staking.ownStashInfo!.account!.redeemable
            .toString(),
        decimals,
        length: decimals);
    return Scaffold(
      appBar: AppBar(
        title: Text(dicStaking['action.redeem']!),
        centerTitle: true,
        leading: BackBtn(
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
      body: Builder(builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(16),
                  children: <Widget>[
                    AddressFormItem(
                      widget.keyring.current,
                      label: dicStaking['controller'],
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: dic!['amount'],
                        labelText: '${dic['amount']}($symbol)',
                      ),
                      initialValue: redeemable,
                      readOnly: true,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: FutureBuilder(
                  future: _getSlashingSpans(),
                  builder: (_, AsyncSnapshot snapshot) {
                    return snapshot.hasData
                        ? TxButton(
                            getTxParams: () async {
                              return TxConfirmParams(
                                txTitle: dicStaking['action.redeem'],
                                module: 'staking',
                                call: 'withdrawUnbonded',
                                txDisplay: {
                                  'spanCount': _slashingSpans,
                                },
                                txDisplayBold: {
                                  dic["amount"]!: Text(
                                    '$redeemable $symbol',
                                    style:
                                        Theme.of(context).textTheme.headline1,
                                  ),
                                },
                                params: [_slashingSpans],
                              );
                            },
                            onFinish: (Map? res) {
                              if (res != null) {
                                Navigator.of(context).pop(res);
                              }
                            },
                          )
                        : CupertinoActivityIndicator();
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
