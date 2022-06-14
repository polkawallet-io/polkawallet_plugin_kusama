import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/bondExtraPage.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/plugin/store/balances.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginButton.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginInputBalance.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginScaffold.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginTxButton.dart';
import 'package:polkawallet_ui/pages/v3/txConfirmPage.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/index.dart';

class RebondPage extends StatefulWidget {
  RebondPage(this.plugin, {Key? key}) : super(key: key);
  final PluginKusama plugin;

  static final String route = '/staking/rebond';

  @override
  State<RebondPage> createState() => _RebondPageState();
}

class _RebondPageState extends State<RebondPage> {
  final TextEditingController _amountCtrl = new TextEditingController();
  String? _error;

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'staking')!;
    final symbol = (widget.plugin.networkState.tokenSymbol ?? ['DOT'])[0];
    final decimals = (widget.plugin.networkState.tokenDecimals ?? [12])[0];
    final labelStyle = Theme.of(context)
        .textTheme
        .headline5
        ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold);

    List<Map<String, dynamic>> unlockDetail = ModalRoute.of(context)!
        .settings
        .arguments as List<Map<String, dynamic>>;
    return PluginScaffold(
        appBar: PluginAppBar(title: Text(dic['action.rebond']!)),
        body: Observer(builder: (_) {
          BigInt redeemable = BigInt.zero;
          if (widget.plugin.store.staking.ownStashInfo!.stakingLedger != null) {
            redeemable = BigInt.parse(widget
                .plugin.store.staking.ownStashInfo!.account!.redeemable
                .toString());
          }
          BigInt unlocking = widget.plugin.store.staking.accountUnlockingTotal;
          unlocking -= redeemable;
          return Column(
            children: [
              PluginInputBalance(
                margin: EdgeInsets.only(top: 10, left: 16, right: 16),
                titleTag: dic['v3.rebondAmount'],
                balance: TokenBalanceData(
                    symbol: symbol,
                    decimals: decimals,
                    amount: unlocking.toString()),
                inputCtrl: _amountCtrl,
                tokenIconsMap: widget.plugin.tokenIcons,
                onClear: () {
                  setState(() {
                    _amountCtrl.text = "";
                  });
                },
                onSetMax: (amount) {
                  setState(() {
                    _amountCtrl.text =
                        Fmt.balance(unlocking.toString(), decimals);
                  });
                },
                onInputChange: (value) {
                  var error = Fmt.validatePrice(value, context);
                  if (error == null) {
                    final amount = double.parse(value.trim());
                    if (amount >=
                        unlocking / BigInt.from(pow(10, decimals)) - 0.001) {
                      error = dic['amount.low'];
                    }
                  }
                  setState(() {
                    _error = error;
                  });
                },
              ),
              ErrorMessage(
                _error,
                margin: EdgeInsets.symmetric(horizontal: 16),
              ),
              Padding(
                padding:
                    EdgeInsets.only(top: 18, left: 16, right: 16, bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(dic['v3.totalUnbonding']!, style: labelStyle),
                    Text(
                        "${Fmt.priceFloorBigIntFormatter(unlocking, decimals, lengthMax: 4)} $symbol ${unlockDetail.length > 0 ? "(${unlockDetail.length})" : ""}",
                        style: labelStyle)
                  ],
                ),
              ),
              Expanded(
                  child: ListView.separated(
                      itemBuilder: (context, index) => Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 31, vertical: 8),
                            color: Color(0x1AFFFFFF),
                            child: Row(
                              children: [
                                Container(
                                    width: 30,
                                    height: 30,
                                    margin: EdgeInsets.only(right: 10),
                                    child: widget.plugin
                                        .tokenIcons[symbol.toUpperCase()]!),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${Fmt.balance(unlockDetail[index]["balance"], decimals)} $symbol",
                                      style: labelStyle,
                                    ),
                                    Row(
                                      children: [
                                        Padding(
                                            padding: EdgeInsets.only(right: 3),
                                            child: Image.asset(
                                                "packages/polkawallet_plugin_kusama/assets/images/staking/icon_rebond.png",
                                                width: 8)),
                                        Text(
                                          unlockDetail[index]["time"]!,
                                          style: labelStyle?.copyWith(
                                              fontSize:
                                                  UI.getTextSize(10, context),
                                              fontWeight: FontWeight.w300),
                                        )
                                      ],
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                      separatorBuilder: (context, index) => Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            color: Color(0x1AFFFFFF),
                            child: Divider(
                              height: 1,
                              color: Colors.white.withAlpha(36),
                            ),
                          ),
                      itemCount: unlockDetail.length)),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: PluginButton(
                    title: dic['action.rebond']!,
                    onPressed: () async {
                      if (_error == null &&
                          _amountCtrl.text.trim().isNotEmpty) {
                        final params = TxConfirmParams(
                            txTitle: dic['action.rebond'],
                            module: 'staking',
                            call: 'rebond',
                            txDisplay: {
                              "amount": '${_amountCtrl.text} $symbol'
                            },
                            params: [
                              // "amount"
                              Fmt.tokenInt(_amountCtrl.text, decimals)
                                  .toString()
                            ],
                            isPlugin: true);
                        final res = await Navigator.of(context)
                            .pushNamed(TxConfirmPage.route, arguments: params);
                        if (res != null) {
                          Navigator.of(context).pop(true);
                        }
                      }
                    },
                  ))
            ],
          );
        }));
  }
}
