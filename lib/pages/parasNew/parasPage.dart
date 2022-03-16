import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_kusama/common/constants.dart';
import 'package:polkawallet_plugin_kusama/pages/parasNew/auctionPanel.dart';
import 'package:polkawallet_plugin_kusama/pages/parasNew/contributePage.dart';
import 'package:polkawallet_plugin_kusama/pages/parasNew/crowdLoanList.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/service/walletApi.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/api/types/parachain/auctionData.dart';
import 'package:polkawallet_sdk/api/types/parachain/fundData.dart';
import 'package:polkawallet_sdk/api/types/parachain/parasOverviewData.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/listTail.dart';
import 'package:polkawallet_ui/components/v3/infoItemRow.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginInfoItem.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginLoadingWidget.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginScaffold.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginTabCard.dart';
import 'package:polkawallet_ui/components/v3/plugin/roundedPluginCard.dart';
import 'package:polkawallet_ui/utils/consts.dart';
import 'package:polkawallet_ui/utils/format.dart';

class ParasPage extends StatefulWidget {
  ParasPage(this.plugin, this.keyring);
  final PluginKusama plugin;
  final Keyring keyring;

  static const String route = '/parachain/index';

  @override
  _ParasPageState createState() => _ParasPageState();
}

class _ParasPageState extends State<ParasPage> {
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      new GlobalKey<RefreshIndicatorState>();

  bool _loaded = false;
  int _tab = 0;

  Timer? _dataQueryTimer;

  Future<void> _getCrowdLoans() async {
    if (widget.plugin.sdk.api.connectedNode == null) return;

    final res = await Future.wait([
      widget.plugin.sdk.api.parachain.queryAuctionWithWinners(),
      WalletApi.getCrowdLoansConfig(
          isKSM: widget.plugin.basic.name == network_name_kusama),
      widget.plugin.sdk.api.parachain.queryParasOverview(),
    ]);

    if (mounted && res[0] != null && res[1] != null) {
      widget.plugin.store.paras.setOverviewData(
          res[0] as AuctionData, res[1] as Map, res[2] as ParasOverviewData);

      if (!_loaded) {
        setState(() {
          _loaded = true;
        });
      }

      if (widget.plugin.store.paras.auctionData.funds.length > 0) {
        _getUserContributions((res[0] as AuctionData).funds);
      }
    }

    if (mounted) {
      _dataQueryTimer?.cancel();
      _dataQueryTimer = Timer(Duration(seconds: 12), _getCrowdLoans);
    }
  }

  Future<void> _getUserContributions(List<FundData> funds) async {
    final data = await widget.plugin.sdk.api.parachain.queryUserContributions(
        funds.map((e) => e.paraId).toList(), widget.keyring.current.pubKey!);

    if (mounted && data != null) {
      final res = {};
      data.asMap().forEach((k, v) {
        res[funds[k].paraId] = v;
      });
      widget.plugin.store.paras.setUserContributions(res);
    }
  }

  Future<void> _goToContribute(FundData fund) async {
    final res = await Navigator.of(context)
        .pushNamed(ContributePage.route, arguments: fund);
    if (res != null) {
      _refreshKey.currentState?.show();
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _getCrowdLoans();
    });
  }

  @override
  void dispose() {
    _dataQueryTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final decimals = (widget.plugin.networkState.tokenDecimals ?? [12])[0];
    final symbol = (widget.plugin.networkState.tokenSymbol ?? ['KSM'])[0];
    final expectedBlockTime = int.parse(
        widget.plugin.networkConst['babe']['expectedBlockTime'].toString());
    final endingPeriod = int.parse(
        widget.plugin.networkConst['auctions']['endingPeriod'].toString());

    return PluginScaffold(
      appBar: PluginAppBar(
        title: Text(I18n.of(context)!
            .getDic(i18n_full_dic_kusama, 'common')!['parachain']!),
      ),
      body: _loaded
          ? RefreshIndicator(
              key: _refreshKey,
              onRefresh: _getCrowdLoans,
              child: Observer(
                builder: (_) {
                  final auction = widget.plugin.store.paras.auctionData;
                  final config = widget.plugin.store.paras.fundsVisible;
                  final contributions =
                      widget.plugin.store.paras.userContributions;
                  final funds = auction.funds.toList();
                  final visibleFundIds = [];
                  config.forEach((k, v) {
                    if (v['visible'] ?? false) {
                      visibleFundIds.add(k);
                    }
                  });
                  funds.retainWhere(
                      (e) => visibleFundIds.indexOf(e.paraId) > -1);
                  funds.sort(
                      (a, b) => int.parse(a.paraId) - int.parse(b.paraId));
                  funds.sort((a, b) => a.isWinner || a.isEnded ? 1 : -1);

                  return Column(
                    children: [
                      _OverviewCard(
                        overview: widget.plugin.store.paras.overview,
                        contributions:
                            widget.plugin.store.paras.userContributions,
                        bestNumber: widget.plugin.store.gov.bestNumber.toInt(),
                        blockTime: int.parse(widget.plugin.networkConst['babe']
                            ['expectedBlockTime']),
                        decimals: decimals,
                        symbol: symbol,
                      ),
                      PluginTabCard(
                        ['Crowdloans', 'Auction'],
                        (index) {
                          setState(() {
                            _tab = index;
                          });
                        },
                        _tab,
                        margin: EdgeInsets.only(left: 16),
                      ),
                      Expanded(
                        child: ListView.builder(
                            physics: BouncingScrollPhysics(),
                            itemCount: _tab == 1 ? 1 : funds.length,
                            itemBuilder: (_, i) {
                              if (_tab == 1) {
                                return auction.auction.leasePeriod != null
                                    ? AuctionPanel(auction, config, decimals,
                                        symbol, expectedBlockTime, endingPeriod)
                                    : Container(
                                        height:
                                            MediaQuery.of(context).size.width,
                                        child: ListTail(
                                          isEmpty: true,
                                          isLoading: false,
                                          color: PluginColorsDark.headline3,
                                        ),
                                      );
                              }
                              return CrowdLoanListItem(
                                fund: funds[i],
                                index: i,
                                config: config,
                                contributions: contributions,
                                decimals: decimals,
                                tokenSymbol: symbol,
                                onContribute: () => _goToContribute(funds[i]),
                              );
                            }),
                      )
                    ],
                  );
                },
              ),
            )
          : Center(
              child: PluginLoadingWidget(),
            ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  _OverviewCard(
      {required this.overview,
      required this.contributions,
      required this.bestNumber,
      required this.blockTime,
      required this.decimals,
      required this.symbol});

  final ParasOverviewData overview;
  final Map contributions;
  final int bestNumber;
  final int blockTime;
  final int decimals;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    final textStyle =
        Theme.of(context).textTheme.headline5?.copyWith(color: Colors.white);

    final labelStyle = Theme.of(context)
        .textTheme
        .headline3
        ?.copyWith(fontSize: 14, color: PluginColorsDark.headline1);
    final contentStyle = Theme.of(context)
        .textTheme
        .headline1
        ?.copyWith(fontSize: 22, color: PluginColorsDark.headline1);

    final contributed =
        contributions.values.map((e) => Fmt.balanceInt(e)).toList();
    contributed.retainWhere((e) => e > BigInt.zero);
    final contributedAmount =
        contributed.isEmpty ? BigInt.zero : contributed.reduce((v, e) => v + e);

    final leaseDays =
        overview.leaseLength * (blockTime ~/ 1000) ~/ SECONDS_OF_DAY;
    final leasePeriod =
        "${Fmt.blockToTime(overview.leaseLength - overview.leaseProgress, blockTime)}/ $leaseDays days";

    return RoundedPluginCard(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              PluginInfoItem(
                title: Fmt.priceFloorBigInt(contributedAmount, decimals,
                        lengthMax: 4) +
                    ' $symbol',
                content: 'You Contributed',
                contentCrossAxisAlignment: CrossAxisAlignment.start,
                lowTitle: true,
                style: labelStyle,
                titleStyle: contentStyle,
                // content: contributions.values
                //     .reduce((value, element) => value + element),
              ),
              PluginInfoItem(
                title: contributed.length.toString(),
                content: 'Contributed Parachains',
                lowTitle: true,
                style: labelStyle,
                titleStyle: contentStyle,
                isExpanded: false,
              )
            ],
          ),
          InfoItemRow(
            'Total Parachains',
            overview.parasCount.toString(),
            labelStyle: textStyle,
            contentStyle: textStyle,
          ),
          InfoItemRow(
            'Current Lease',
            overview.currentLease.toString(),
            labelStyle: textStyle,
            contentStyle: textStyle,
          ),
          InfoItemRow(
            'Lease Period',
            leasePeriod,
            labelStyle: textStyle,
            contentStyle: textStyle,
          ),
        ],
      ),
    );
  }
}
