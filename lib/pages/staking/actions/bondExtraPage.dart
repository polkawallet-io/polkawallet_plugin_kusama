import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/plugin/store/balances.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/addressFormItem.dart';
import 'package:polkawallet_ui/components/txButton.dart';
import 'package:polkawallet_ui/components/v3/back.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginAddressFormItem.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginInputBalance.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginScaffold.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginTxButton.dart';
import 'package:polkawallet_ui/utils/consts.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/index.dart';

class BondExtraPage extends StatefulWidget {
  BondExtraPage(this.plugin, this.keyring);
  static final String route = '/staking/bondExtra';
  final PluginKusama plugin;
  final Keyring keyring;
  @override
  _BondExtraPageState createState() => _BondExtraPageState();
}

class _BondExtraPageState extends State<BondExtraPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _amountCtrl = new TextEditingController();

  String? _error1;

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'common');
    final dicStaking =
        I18n.of(context)!.getDic(i18n_full_dic_kusama, 'staking')!;
    final symbol = widget.plugin.networkState.tokenSymbol![0];
    final decimals = widget.plugin.networkState.tokenDecimals![0];

    BigInt available = BigInt.zero;
    if (widget.plugin.balances.native != null) {
      available =
          Fmt.balanceInt(widget.plugin.balances.native!.freeBalance.toString());
      widget.plugin.balances.native!.lockedBreakdown!.forEach((e) {
        if (e.use!.contains('staking')) {
          available -= Fmt.balanceInt(e.amount.toString());
        }
      });
    }

    return PluginScaffold(
      appBar: PluginAppBar(
        title: Text(dicStaking['action.bondExtra']!),
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
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.all(16),
                    children: <Widget>[
                      PluginAddressFormItem(
                        account: widget.keyring.current,
                        label: dicStaking['stash'],
                      ),
                      PluginInputBalance(
                        margin: EdgeInsets.only(top: 10),
                        titleTag: dic!['amount'],
                        balance: TokenBalanceData(
                            symbol: symbol,
                            decimals: decimals,
                            amount: available.toString()),
                        inputCtrl: _amountCtrl,
                        tokenIconsMap: widget.plugin.tokenIcons,
                        onInputChange: (value) {
                          var error = Fmt.validatePrice(value, context);
                          if (error == null) {
                            if (double.parse(value.trim()) >=
                                Fmt.bigIntToDouble(available, decimals)) {
                              error = dic['amount.low'];
                            }
                          }
                          setState(() {
                            _error1 = error;
                          });
                        },
                      ),
                      ErrorMessage(
                        _error1,
                        margin: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: PluginTxButton(
                  getTxParams: () async {
                    if (_formKey.currentState!.validate()) {
                      final inputAmount = _amountCtrl.text.trim();
                      return TxConfirmParams(
                        txTitle: dicStaking['action.bondExtra'],
                        module: 'staking',
                        call: 'bondExtra',
                        txDisplayBold: {
                          dic["amount"]!: Text(
                            '$inputAmount $symbol',
                            style: Theme.of(context)
                                .textTheme
                                .headline1
                                ?.copyWith(color: PluginColorsDark.headline1),
                          ),
                        },
                        params: [
                          // "amount"
                          Fmt.tokenInt(inputAmount, decimals).toString(),
                        ],
                        isPlugin: true,
                      );
                    }
                    return null;
                  },
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

class ErrorMessage extends StatelessWidget {
  ErrorMessage(this.error, {this.margin});
  final error;
  EdgeInsetsGeometry? margin;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: error == null
          ? EdgeInsets.zero
          : margin ?? EdgeInsets.only(left: 16, top: 4),
      child: error == null
          ? null
          : Row(children: [
              Text(
                error,
                style: TextStyle(fontSize: 12, color: Colors.red),
              )
            ]),
    );
  }
}
