import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:polkawallet_sdk/api/types/parachain/auctionData.dart';
import 'package:polkawallet_ui/components/infoItemRow.dart';
import 'package:polkawallet_ui/components/linearProgressBar.dart';
import 'package:polkawallet_ui/components/v3/plugin/roundedPluginCard.dart';
import 'package:polkawallet_ui/utils/consts.dart';
import 'package:polkawallet_ui/utils/format.dart';

class AuctionPanel extends StatelessWidget {
  AuctionPanel(this.auction, this.config, this.decimals, this.tokenSymbol,
      this.expectedBlockTime, this.endingPeriodBlocks);
  final AuctionData auction;
  final Map config;
  final int decimals;
  final String tokenSymbol;
  final int expectedBlockTime;
  final int endingPeriodBlocks;

  @override
  Widget build(BuildContext context) {
    final titleStyle =
        Theme.of(context).textTheme.headline3?.copyWith(color: Colors.white);
    final textStyle =
        Theme.of(context).textTheme.headline5?.copyWith(color: Colors.white);
    final textStyleSmall = Theme.of(context)
        .textTheme
        .headline5
        ?.copyWith(color: Colors.white, fontSize: 12);

    final auctionPeriodBlocks = endingPeriodBlocks * 3 ~/ 8;
    final endBlock = int.parse(auction.auction.endBlock ?? '0');
    final startBlock = endBlock - auctionPeriodBlocks;
    final closeBlock = endBlock + endingPeriodBlocks;
    final currentBlock = int.parse(auction.auction.bestNumber ?? '0');
    final ending = endBlock - currentBlock;
    final stageTitle = ending > 0 ? 'Auction Stage' : 'Ending Stage';
    final progress = ending > 0
        ? (auctionPeriodBlocks - ending) / auctionPeriodBlocks
        : (0 - ending) / endingPeriodBlocks;
    final endingTime = Fmt.blockToTime(
        ending > 0 ? ending : endingPeriodBlocks + ending, expectedBlockTime);
    final endingStageTime =
        Fmt.blockToTime(endingPeriodBlocks, expectedBlockTime);
    return RoundedPluginCard(
      borderRadius: BorderRadius.only(
          topRight: Radius.circular(8),
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8)),
      padding: EdgeInsets.fromLTRB(16, 0, 0, 12),
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: auction.auction.leasePeriod == null
          ? Container(
              height: MediaQuery.of(context).size.width / 2,
              child: Center(
                child: Text('No Data'),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: Container(
                          width: 32,
                          height: 32,
                          color: Colors.black,
                          child: Image.asset(
                            'packages/polkawallet_plugin_kusama/assets/images/public/icon_auction.png',
                            width: 26,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Auction #${auction.auction.numAuctions}',
                        style: titleStyle,
                      ),
                    ),
                    Container(
                      height: 72,
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(8),
                                bottomLeft: Radius.circular(8),
                              ),
                              color: PluginColorsDark.headline3,
                            ),
                            child: Text(
                              stageTitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5
                                  ?.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InfoItemRow(
                        'Leases',
                        '${auction.auction.leasePeriod} - ${auction.auction.leaseEnd}',
                        labelStyle: textStyle,
                        contentStyle: textStyle,
                      ),
                      InfoItemRow(
                        'Current Block',
                        '#$currentBlock',
                        labelStyle: textStyle,
                        contentStyle: textStyle,
                      ),
                      InfoItemRow(
                        'Auction Stage',
                        '$startBlock - $endBlock',
                        labelStyle: textStyle,
                        contentStyle: textStyle,
                      ),
                      InfoItemRow(
                        ending > 0 ? endingTime : '0 days',
                        Fmt.ratio(ending > 0 ? progress : 1),
                        labelStyle: textStyleSmall,
                        contentStyle: textStyleSmall,
                      ),
                      LinearProgressbar(
                          color: PluginColorsDark.primary,
                          backgroundColor: PluginColorsDark.headline3,
                          margin: EdgeInsets.only(top: 4, bottom: 4),
                          height: 9,
                          borderRadius: 2,
                          width: MediaQuery.of(context).size.width - 64,
                          progress: ending > 0 ? progress : 1),
                      InfoItemRow(
                        'Ending Stage',
                        '$endBlock - $closeBlock',
                        labelStyle: textStyle,
                        contentStyle: textStyle,
                      ),
                      InfoItemRow(
                        ending < 0 ? endingTime : endingStageTime,
                        Fmt.ratio(ending < 0 ? progress : 0),
                        labelStyle: textStyleSmall,
                        contentStyle: textStyleSmall,
                      ),
                      LinearProgressbar(
                          color: PluginColorsDark.primary,
                          backgroundColor: PluginColorsDark.headline3,
                          margin: EdgeInsets.only(top: 4, bottom: 4),
                          height: 9,
                          borderRadius: 2,
                          width: MediaQuery.of(context).size.width - 64,
                          progress: ending < 0 ? progress : 0),
                      Text('Latest Bid', style: textStyle),
                      ...auction.winners.map((e) {
                        final raised = Fmt.balance(e.value.toString(), decimals,
                            length: 2);
                        final logoUri =
                            (config[e.paraId] ?? {})['logo'] as String?;
                        return Container(
                          margin: EdgeInsets.only(top: 8, bottom: 8),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(right: 8),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(24),
                                      child: Container(
                                        color: PluginColorsDark.headline1,
                                        child: logoUri != null
                                            ? logoUri.contains('.svg')
                                                ? SvgPicture.network(logoUri,
                                                    height: 24, width: 24)
                                                : Image.network(logoUri,
                                                    height: 24, width: 24)
                                            : CircleAvatar(
                                                radius: 16,
                                                child: Text('#'),
                                              ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          e.paraId ?? '',
                                          style: textStyle?.copyWith(
                                              fontSize: 16, height: 1.2),
                                        ),
                                        Text(
                                          ((config[e.paraId] ?? {})['name'] ??
                                              ''),
                                          style: textStyleSmall?.copyWith(
                                              fontSize: 10, height: 1),
                                        )
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '$raised $tokenSymbol',
                                    style: textStyle,
                                  )
                                ],
                              ),
                              InfoItemRow(
                                'Crowdloan',
                                e.isCrowdloan == true ? 'Yes' : 'No',
                                labelStyle: textStyle,
                                contentStyle: textStyle,
                              ),
                              InfoItemRow(
                                'Bid Leases',
                                '${e.firstSlot} - ${e.lastSlot}',
                                labelStyle: textStyle,
                                contentStyle: textStyle,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
