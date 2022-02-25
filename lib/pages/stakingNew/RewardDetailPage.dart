import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_kusama/pages/stakingNew/RewardsChart.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/TransferIcon.dart';
import 'package:polkawallet_ui/components/connectionChecker.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginInfoItem.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginLoadingWidget.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginScaffold.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginTextTag.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/rewardDetailPage.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/i18n.dart';

class RewardDetailNewPage extends StatefulWidget {
  RewardDetailNewPage(this.plugin, {Key? key}) : super(key: key);
  final PluginKusama plugin;

  static final String route = '/staking/rewardDetail';

  @override
  State<RewardDetailNewPage> createState() => _RewardDetailNewPageState();
}

class _RewardDetailNewPageState extends State<RewardDetailNewPage> {
  bool _isLoading = false;

  Future<void> _updateData() async {
    await widget.plugin.service.staking.updateStakingRewards();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      if (widget.plugin.store.staking.txsRewards.length == 0) {
        setState(() {
          _isLoading = true;
        });
        await _updateData();
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'staking')!;
    final int decimals = widget.plugin.networkState.tokenDecimals![0];
    final String symbol = widget.plugin.networkState.tokenSymbol![0];
    var sum = 0.0;
    widget.plugin.store.staking.txsRewards.forEach((data) {
      sum += Fmt.balanceDouble(data.amount!, decimals) *
          (data.eventId == 'Reward' ? 1.0 : -1.0);
    });
    return PluginScaffold(
      appBar: PluginAppBar(title: Text(dic['v3.rewardDetail']!)),
      body: Observer(builder: (_) {
        return _isLoading
            ? Container(
                height: MediaQuery.of(context).size.height / 2,
                width: double.infinity,
                alignment: Alignment.center,
                child: PluginLoadingWidget(),
              )
            : widget.plugin.store.staking.txsRewards.length == 0
                ? Container(
                    width: double.infinity,
                    height: double.infinity,
                    alignment: Alignment.center,
                    child: Text(
                      I18n.of(context)!
                          .getDic(i18n_full_dic_ui, 'common')!['list.empty']!,
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ConnectionChecker(widget.plugin,
                            onConnected: _updateData),
                        Container(
                            padding: EdgeInsets.only(
                                left: 17, right: 20, top: 9, bottom: 10),
                            margin: EdgeInsets.only(left: 16),
                            decoration: BoxDecoration(
                                color: Color(0x24FFFFFF),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(14),
                                    topRight: Radius.circular(14))),
                            child: PluginInfoItem(
                              title: dic['v3.stagedRewards'],
                              isExpanded: false,
                              titleStyle: Theme.of(context)
                                  .textTheme
                                  .headline5
                                  ?.copyWith(color: Colors.white),
                              crossAxisAlignment: CrossAxisAlignment.start,
                              content:
                                  "${sum < 0 ? '-' : '+'}${Fmt.priceFloorFormatter(sum, lengthMax: 5)}",
                            )),
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(horizontal: 16),
                          padding: EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                              color: Color(0x1AFFFFFF),
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(14),
                                  topRight: Radius.circular(14),
                                  bottomRight: Radius.circular(14))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 50, top: 8),
                                child: Text('Rewards ($symbol)',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.white)),
                              ),
                              Container(
                                height: MediaQuery.of(context).size.width / 2.4,
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: RewardsChart.withData(widget
                                    .plugin.store.staking.txsRewards
                                    .map((e) => TimeSeriesAmount(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            e.blockTimestamp! * 1000),
                                        Fmt.balanceDouble(e.amount!, decimals) *
                                            (e.eventId == 'Reward'
                                                ? 1.0
                                                : -1.0)))
                                    .toList()),
                              )
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            PluginTextTag(
                                margin: EdgeInsets.only(top: 22, left: 16),
                                padding: EdgeInsets.zero,
                                title: dic['txs.reward']!),
                            Container(
                              color: Color(0x1AFFFFFF),
                              child: Column(
                                children: [
                                  ...widget.plugin.store.staking.txsRewards
                                      .map((i) {
                                    final isReward = i.eventId == 'Reward';
                                    return Column(children: [
                                      ListTile(
                                        dense: true,
                                        leading: Container(
                                          width: 32,
                                          padding: EdgeInsets.only(top: 4),
                                          child: TransferIcon(
                                            type: isReward
                                                ? TransferIconType.earn
                                                : TransferIconType.fine,
                                            bgColor: Colors.white.withAlpha(87),
                                            iconColor: isReward
                                                ? Colors.white
                                                : Color(0xFFFFA07E),
                                          ),
                                        ),
                                        title: Text(i.eventId!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline5
                                                ?.copyWith(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                        subtitle: Text(
                                            Fmt.dateTime(DateTime
                                                .fromMillisecondsSinceEpoch(
                                                    i.blockTimestamp! * 1000)),
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline5
                                                ?.copyWith(
                                                    color: Colors.white,
                                                    fontSize: 10)),
                                        trailing: Text(
                                          '${isReward ? '+' : '-'} ${Fmt.balance(i.amount!, decimals)} $symbol',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline4
                                              ?.copyWith(
                                                  color: isReward
                                                      ? Colors.white
                                                      : Color(0xFFFFA07E),
                                                  fontWeight: FontWeight.w600),
                                        ),
                                        onTap: () {
                                          Navigator.of(context).pushNamed(
                                              RewardDetailPage.route,
                                              arguments: i);
                                        },
                                      ),
                                      Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12),
                                          child: Divider(
                                            color: Colors.white.withAlpha(36),
                                            height: 5,
                                          ))
                                    ]);
                                  }).toList()
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  );
      }),
    );
  }
}
