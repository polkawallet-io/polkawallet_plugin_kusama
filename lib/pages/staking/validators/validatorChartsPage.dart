import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_kusama/common/components/chartLabel.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/validators/validatorRewardsChart.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/store/staking/types/validatorData.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginLoadingWidget.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginScaffold.dart';

class ValidatorChartsPage extends StatelessWidget {
  ValidatorChartsPage(this.plugin, this.keyring);
  static final String route = '/staking/validator/chart';
  final PluginKusama plugin;
  final Keyring keyring;

  Future<Map?> _getValidatorRewardsData(String? accountId) async {
    final rewardsChartData =
        plugin.store.staking.rewardsChartDataCache[accountId!];
    if (rewardsChartData != null) return rewardsChartData;
    return plugin.service.staking.queryValidatorRewards(accountId);
  }

  @override
  Widget build(BuildContext context) => Observer(
        builder: (_) {
          final dic =
              I18n.of(context)!.getDic(i18n_full_dic_kusama, 'staking')!;
          final ValidatorData detail =
              ModalRoute.of(context)!.settings.arguments as ValidatorData;

          return PluginScaffold(
            appBar: PluginAppBar(
                title: Text(dic['validator.chart']!), centerTitle: true),
            body: SafeArea(
              child: FutureBuilder(
                future: _getValidatorRewardsData(detail.accountId),
                builder: (_, data) {
                  if (!data.hasData) {
                    return Center(child: PluginLoadingWidget());
                  }
                  final rewardsChartData = plugin
                      .store.staking.rewardsChartDataCache[detail.accountId!];

                  List<ChartLineInfo> pointsChartLines = [
                    ChartLineInfo('Era Points', Color(0xFFFF7849)),
                    ChartLineInfo('Average', Colors.white),
                  ];

                  List<ChartLineInfo> rewardChartLines = [
                    ChartLineInfo('Slashes', Color(0xFF81FEB9)),
                    ChartLineInfo('Rewards', Color(0xFFFF7849)),
                    ChartLineInfo('Average', Colors.white),
                  ];

                  List<ChartLineInfo> stakesChartLines = [
                    ChartLineInfo('Elected Stake', Color(0xFFFF7849)),
                    ChartLineInfo('Average', Colors.white),
                  ];
                  return ListView(
                    children: <Widget>[
                      // blocks labels & chart
                      Padding(
                        padding: EdgeInsets.only(left: 16, top: 16),
                        child: Column(
                          children: <Widget>[
                            ChartLabel(
                              name: 'Era Points',
                              color: Color(0xFFFF7849),
                            ),
                            ChartLabel(
                              name: 'Average',
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 240,
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.only(bottom: 16),
                        child: rewardsChartData == null
                            ? CupertinoActivityIndicator(
                                color: const Color(0xFF3C3C44))
                            : RewardsChart.withData(
                                pointsChartLines,
                                rewardsChartData['points'][0],
                                rewardsChartData['points'][1],
                              ),
                      ),
                      // Rewards labels & chart
                      Divider(),
                      Padding(
                        padding: EdgeInsets.only(left: 16, top: 8),
                        child: Column(
                          children: <Widget>[
                            ChartLabel(
                              name: 'Rewards',
                              color: Color(0xFF81FEB9),
                            ),
                            ChartLabel(
                              name: 'Slashes',
                              color: Color(0xFFFF7849),
                            ),
                            ChartLabel(
                              name: 'Average',
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 240,
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.only(bottom: 16),
                        child: rewardsChartData == null
                            ? CupertinoActivityIndicator(
                                color: const Color(0xFF3C3C44))
                            : RewardsChart.withData(
                                rewardChartLines,
                                rewardsChartData['rewards'][0],
                                rewardsChartData['rewards'][1],
                              ),
                      ),
                      // Stakes labels & chart
                      Divider(),
                      Padding(
                        padding: EdgeInsets.only(left: 16, top: 8),
                        child: Column(
                          children: <Widget>[
                            ChartLabel(
                              name: 'Elected Stake',
                              color: Color(0xFFFF7849),
                            ),
                            ChartLabel(
                              name: 'Average',
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 240,
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.only(bottom: 16),
                        child: rewardsChartData == null
                            ? CupertinoActivityIndicator(
                                color: const Color(0xFF3C3C44))
                            : RewardsChart.withData(
                                stakesChartLines,
                                List<List>.from([
                                  rewardsChartData['stakes'][0][1],
                                  rewardsChartData['stakes'][0][2],
                                ]),
                                rewardsChartData['stakes'][1],
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      );
}
