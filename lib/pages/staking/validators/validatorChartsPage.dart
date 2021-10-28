import 'package:charts_flutter/flutter.dart' as charts;
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

          return Scaffold(
            appBar: AppBar(
              title: Text(dic['validator.chart']!),
              centerTitle: true,
            ),
            body: SafeArea(
              child: FutureBuilder(
                future: _getValidatorRewardsData(detail.accountId),
                builder: (_, data) {
                  if (!data.hasData) {
                    return Center(child: CupertinoActivityIndicator());
                  }
                  final rewardsChartData = plugin
                      .store.staking.rewardsChartDataCache[detail.accountId!];

                  List<ChartLineInfo> pointsChartLines = [
                    ChartLineInfo('Era Points',
                        charts.MaterialPalette.yellow.shadeDefault),
                    ChartLineInfo(
                        'Average', charts.MaterialPalette.gray.shadeDefault),
                  ];

                  List<ChartLineInfo> rewardChartLines = [
                    ChartLineInfo(
                        'Slashes', charts.MaterialPalette.red.shadeDefault),
                    ChartLineInfo(
                        'Rewards', charts.MaterialPalette.blue.shadeDefault),
                    ChartLineInfo(
                        'Average', charts.MaterialPalette.gray.shadeDefault),
                  ];

                  List<ChartLineInfo> stakesChartLines = [
                    ChartLineInfo('Elected Stake',
                        charts.MaterialPalette.yellow.shadeDefault),
                    ChartLineInfo(
                        'Average', charts.MaterialPalette.gray.shadeDefault),
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
                              color: Colors.yellow,
                            ),
                            ChartLabel(
                              name: 'Average',
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 240,
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.only(bottom: 16),
                        child: rewardsChartData == null
                            ? CupertinoActivityIndicator()
                            : new RewardsChart.withData(
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
                              color: Colors.blue,
                            ),
                            ChartLabel(
                              name: 'Slashes',
                              color: Colors.red,
                            ),
                            ChartLabel(
                              name: 'Average',
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 240,
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.only(bottom: 16),
                        child: rewardsChartData == null
                            ? CupertinoActivityIndicator()
                            : new RewardsChart.withData(
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
                              color: Colors.yellow,
                            ),
                            ChartLabel(
                              name: 'Average',
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 240,
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.only(bottom: 16),
                        child: rewardsChartData == null
                            ? CupertinoActivityIndicator()
                            : new RewardsChart.withData(
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
