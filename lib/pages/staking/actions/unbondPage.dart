import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/bondExtraPage.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/plugin/store/balances.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/txButton.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginAddressFormItem.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginInputBalance.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginScaffold.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginTxButton.dart';
import 'package:polkawallet_ui/utils/consts.dart';
import 'package:polkawallet_ui/utils/format.dart';

class UnBondPage extends StatefulWidget {
  UnBondPage(this.plugin, this.keyring);
  static final String route = '/staking/unbond';
  final PluginKusama plugin;
  final Keyring keyring;
  @override
  _UnBondPageState createState() => _UnBondPageState();
}

class _UnBondPageState extends State<UnBondPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _amountCtrl = new TextEditingController();

  BigInt _minNominate = BigInt.zero;

  String? _error;

  Future<void> _queryMinNominate() async {
    final min = await widget.plugin.sdk.webView!
        .evalJavascript('api.query.staking.minNominatorBond()');
    setState(() {
      _minNominate = Fmt.balanceInt(min);
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _queryMinNominate();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'common');
    final dicStaking =
        I18n.of(context)!.getDic(i18n_full_dic_kusama, 'staking')!;
    final symbol = widget.plugin.networkState.tokenSymbol![0];
    final decimals = widget.plugin.networkState.tokenDecimals![0];

    final stashInfo = widget.plugin.store.staking.ownStashInfo;
    double bonded = 0;
    bool hasNomination = false;
    if (stashInfo != null) {
      bonded = Fmt.bigIntToDouble(
          BigInt.parse(stashInfo.stakingLedger!['active'].toString()),
          decimals);
      hasNomination = stashInfo.nominating!.length > 0;
    }

    return PluginScaffold(
      appBar: PluginAppBar(
        title: Text(dicStaking['action.unbond']!),
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
                        label: dicStaking['controller'],
                      ),
                      PluginInputBalance(
                        margin: EdgeInsets.only(top: 10),
                        titleTag: dic!['amount'],
                        balance: TokenBalanceData(
                            symbol: symbol,
                            decimals: decimals,
                            amount: bonded.toString()),
                        inputCtrl: _amountCtrl,
                        tokenIconsMap: widget.plugin.tokenIcons,
                        onInputChange: (value) {
                          var error = Fmt.validatePrice(value, context);
                          if (error == null) {
                            final amount = double.parse(value.trim());
                            if (amount > bonded) {
                              error = dic['amount.low'];
                            }
                            if (hasNomination &&
                                bonded - amount <=
                                    Fmt.bigIntToDouble(
                                        _minNominate, decimals)) {
                              error = dicStaking['bond.unbond.min'];
                            }
                          }
                          setState(() {
                            _error = error;
                          });
                        },
                      ),
                      ErrorMessage(
                        _error,
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
                        txTitle: dicStaking['action.unbond'],
                        module: 'staking',
                        call: 'unbond',
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
