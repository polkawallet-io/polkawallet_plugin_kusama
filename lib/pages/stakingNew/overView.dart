import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/stakePage.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/connectionChecker.dart';
import 'package:polkawallet_ui/components/infoItemRow.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginButton.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginInfoItem.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginLoadingWidget.dart';
import 'package:polkawallet_ui/components/circularProgressBar.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginTagCard.dart';
import 'package:polkawallet_ui/utils/format.dart';

class OverView extends StatefulWidget {
  OverView(this.plugin, {Key? key}) : super(key: key);
  final PluginKusama plugin;

  @override
  State<OverView> createState() => _OverViewState();
}

class _OverViewState extends State<OverView> {
  @override
  Widget build(BuildContext context) {
    final dicStaking =
        I18n.of(context)!.getDic(i18n_full_dic_kusama, 'staking')!;
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.only(left: 16, top: 30, right: 16, bottom: 20),
      child: Column(
        children: [
          Expanded(child: OverViewWidget(widget.plugin)),
          Padding(
              padding: EdgeInsets.only(bottom: 20, top: 10),
              child: PluginButton(
                title: dicStaking['v3.goStake']!,
                onPressed: () => Navigator.pushNamed(context, StakePage.route),
              ))
        ],
      ),
    );
  }
}

class OverViewWidget extends StatefulWidget {
  OverViewWidget(this.plugin, {Key? key}) : super(key: key);
  final PluginKusama plugin;

  @override
  State<OverViewWidget> createState() => _OverViewWidgetState();
}

class _OverViewWidgetState extends State<OverViewWidget> {
  Future<void> _updateData() async {
    await widget.plugin.service.staking.queryElectedInfo();
    widget.plugin.service.staking.queryMarketPrices();
  }

  @override
  Widget build(BuildContext context) {
    final dicStaking =
        I18n.of(context)!.getDic(i18n_full_dic_kusama, 'staking')!;

    return Observer(builder: (_) {
      final isDataLoading = widget.plugin.store.staking.overview.length == 0 ||
          widget.plugin.store.staking.marketPrices.length == 0;
      final overview = widget.plugin.store.staking.overview;
      double stakedRatio = 0;
      BigInt totalStaked = BigInt.zero;
      if (overview['totalStaked'] != null) {
        totalStaked = Fmt.balanceInt('0x${overview['totalStaked']}');
        stakedRatio = totalStaked / Fmt.balanceInt(overview['totalIssuance']);
      }
      final decimals = (widget.plugin.networkState.tokenDecimals ?? [12])[0];
      final symbol = (widget.plugin.networkState.tokenSymbol ?? ['DOT'])[0];
      final marketPrice = widget.plugin.store.staking.marketPrices[symbol] ?? 0;

      final labelStyle =
          Theme.of(context).textTheme.headline5?.copyWith(color: Colors.white);
      return isDataLoading
          ? Column(
              children: [
                ConnectionChecker(widget.plugin, onConnected: _updateData),
                PluginLoadingWidget(),
              ],
            )
          : Container(
              width: double.infinity,
              child: Column(
                children: [
                  Stack(alignment: Alignment.center, children: [
                    Container(
                        width: 176,
                        height: 176,
                        child: CustomPaint(
                          painter: CircularProgressBar(
                              startAngle: pi * 3 / 2,
                              width: 12,
                              lineColor: [Color(0x0FFFFFFF), Color(0xFF81FEB9)],
                              progress: stakedRatio * 0.4 + 0.6),
                        )),
                    Column(
                      children: [
                        Text(
                          dicStaking['overview.total']!,
                          style: Theme.of(context)
                              .textTheme
                              .headline4
                              ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                        ),
                        Text(
                            "${Fmt.priceFloorBigIntFormatter(totalStaked, decimals)} $symbol",
                            style: Theme.of(context)
                                .textTheme
                                .headline4
                                ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    color: Colors.white)),
                        Text(
                            "\$ ${Fmt.priceFloorFormatter(Fmt.bigIntToDouble(totalStaked, decimals) * marketPrice)}",
                            style: Theme.of(context)
                                .textTheme
                                .headline4
                                ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    color: Colors.white))
                      ],
                    ),
                  ]),
                  PluginTagCard(
                    margin: EdgeInsets.only(top: 20),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    titleTag: dicStaking['v3.information'],
                    radius: const Radius.circular(14),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            PluginInfoItem(
                                title: dicStaking['v3.stakedPortion'],
                                titleStyle: labelStyle,
                                content: Fmt.ratio(stakedRatio),
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5
                                    ?.copyWith(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        height: 2.0),
                                contentCrossAxisAlignment:
                                    CrossAxisAlignment.start),
                            PluginInfoItem(
                              title: dicStaking['v3.returns'],
                              titleStyle: labelStyle,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5
                                  ?.copyWith(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      height: 2.0),
                              content:
                                  Fmt.ratio(overview['stakedReturn'] / 100),
                            ),
                          ],
                        ),
                        // TODO:update content
                        InfoItemRow(
                          dicStaking['v3.lastReward']!,
                          "TODO $symbol",
                          labelStyle: labelStyle,
                          contentStyle: labelStyle,
                        ),
                        InfoItemRow(
                          dicStaking['v3.minThreshold']!,
                          "TODO $symbol",
                          labelStyle: labelStyle,
                          contentStyle: labelStyle,
                        ),
                        InfoItemRow(
                          dicStaking['v3.unbondingPeriod']!,
                          "TODO",
                          labelStyle: labelStyle,
                          contentStyle: labelStyle,
                        ),
                        InfoItemRow(
                          dicStaking['v3.activeNominators']!,
                          "TODO",
                          labelStyle: labelStyle,
                          contentStyle: labelStyle,
                        )
                      ],
                    ),
                  )
                ],
              ));
    });
  }
}