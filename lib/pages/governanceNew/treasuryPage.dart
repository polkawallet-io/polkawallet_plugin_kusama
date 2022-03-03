import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_kusama/common/constants.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/api/types/gov/genExternalLinksParams.dart';
import 'package:polkawallet_sdk/api/types/gov/treasuryOverviewData.dart';
import 'package:polkawallet_sdk/api/types/gov/treasuryTipData.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/addressIcon.dart';
import 'package:polkawallet_ui/components/circularProgressBar.dart';
import 'package:polkawallet_ui/components/roundedCard.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginInfoItem.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginScaffold.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginTabCard.dart';
import 'package:polkawallet_ui/components/v3/plugin/roundedPluginCard.dart';
import 'package:polkawallet_ui/utils/consts.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/index.dart';

class TreasuryPage extends StatefulWidget {
  TreasuryPage(this.plugin, this.keyring);
  final PluginKusama plugin;
  final Keyring keyring;

  static const String route = '/gov/treasury/index';

  @override
  _TreasuryPageState createState() => _TreasuryPageState();
}

class _TreasuryPageState extends State<TreasuryPage> {
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      new GlobalKey<RefreshIndicatorState>();

  int _tab = 0;

  List? _links;

  int _getSpendPeriod() {
    int spendDays = 0;
    if (widget.plugin.networkConst['treasury'] != null) {
      final period =
          int.parse(widget.plugin.networkConst['treasury']['spendPeriod']);
      final blockTime =
          int.parse(widget.plugin.networkConst['babe']['expectedBlockTime']);
      spendDays = period * (blockTime ~/ 1000) ~/ SECONDS_OF_DAY;
    }
    return spendDays;
  }

  Future<List?> _getExternalLinks(int id) async {
    if (_links != null) return _links;

    final List? res = await widget.plugin.sdk.api.gov.getExternalLinks(
      GenExternalLinksParams.fromJson(
          {'data': id.toString(), 'type': 'treasury'}),
    );
    if (res != null) {
      setState(() {
        _links = res;
      });
    }
    return res;
  }

  Future<void> _fetchData() async {
    widget.plugin.service.gov.updateBestNumber();
    widget.plugin.service.gov.queryTreasuryTips();
    await widget.plugin.service.gov.queryTreasuryOverview();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _refreshKey.currentState?.show();
    });
  }

  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov')!;
    return PluginScaffold(
      appBar: PluginAppBar(title: Text(dic['treasury']!)),
      body: Observer(
        builder: (_) {
          final decimals = widget.plugin.networkState.tokenDecimals![0];
          final symbol = widget.plugin.networkState.tokenSymbol![0];

          final proposals =
              (widget.plugin.store.gov.treasuryOverview.proposals ?? [])
                  .toList();
          proposals
              .addAll(widget.plugin.store.gov.treasuryOverview.approvals ?? []);

          final tips = <TreasuryTipData>[];
          if (widget.plugin.store.gov.treasuryTips != null) {
            tips.addAll(widget.plugin.store.gov.treasuryTips!.reversed);
          }

          return RefreshIndicator(
              key: _refreshKey,
              child: ListView.builder(
                  itemCount: (_tab == 0 ? proposals.length : tips.length) + 1,
                  itemBuilder: (_, index) {
                    if (index == 0) {
                      return Column(
                        children: [
                          _OverviewCard(
                            symbol: symbol,
                            decimals: decimals,
                            spendPeriod: _getSpendPeriod(),
                            overview: widget.plugin.store.gov.treasuryOverview,
                          ),
                          PluginTabCard(
                            [dic['treasury']!, dic['treasury.tip']!],
                            (index) {
                              setState(() {
                                _tab = index;
                              });
                            },
                            _tab,
                          ),
                        ],
                      );
                    }
                    final i = index - 1;
                    if (_tab == 0) {
                      return _ProposalItem(
                        symbol: symbol,
                        decimals: decimals,
                        icon: widget.plugin.store.accounts
                            .addressIconsMap[proposals[i].proposal!.proposer],
                        accInfo: widget.plugin.store.accounts
                            .addressIndexMap[proposals[i].proposal!.proposer],
                        proposal: proposals[i],
                      );
                    }

                    final TreasuryTipData tip = tips[i];
                    final icon =
                        widget.plugin.store.accounts.addressIconsMap[tip.who];
                    final indices =
                        widget.plugin.store.accounts.addressIndexMap[tip.who];
                    return RoundedCard(
                      margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
                      padding: EdgeInsets.only(top: 16, bottom: 16),
                      child: ListTile(
                        leading: AddressIcon(
                          tip.who,
                          svg: icon,
                        ),
                        title: UI.accountDisplayName(tip.who, indices),
                        subtitle: Text(tip.reason!),
                        trailing: Column(
                          children: <Widget>[
                            Text(
                              tip.tips!.length.toString(),
                              style: Theme.of(context).textTheme.headline4,
                            ),
                            Text(I18n.of(context)!.getDic(i18n_full_dic_kusama,
                                'gov')!['treasury.tipper']!)
                          ],
                        ),
                        // onTap: () async {
                        //   final res = await Navigator.of(context).pushNamed(
                        //     TipDetailPage.route,
                        //     arguments: tip,
                        //   );
                        //   if (res != null) {
                        //     _refreshKey.currentState!.show();
                        //   }
                        // },
                      ),
                    );
                  }),
              onRefresh: _fetchData);
        },
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  _OverviewCard({
    required this.symbol,
    required this.decimals,
    this.spendPeriod,
    this.overview,
    this.refreshPage,
  });

  final String symbol;
  final int decimals;
  final int? spendPeriod;
  final TreasuryOverviewData? overview;
  final Function? refreshPage;

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov')!;
    final labelStyle = Theme.of(context)
        .textTheme
        .headline4
        ?.copyWith(fontSize: 12, color: PluginColorsDark.headline2);

    final available = Fmt.balance(
      overview?.balance ?? '0',
      decimals,
    );
    final spendable = Fmt.balance(
      overview?.spendable ?? '0',
      decimals,
    );
    return RoundedPluginCard(
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProgressBar(),
                  PluginInfoItem(
                    contentCrossAxisAlignment: CrossAxisAlignment.start,
                    title: '$spendable/$available $symbol',
                    content:
                        '${dic['treasury.spendable']}/${dic['treasury.available']}',
                    isExpanded: false,
                    lowTitle: true,
                    style: labelStyle,
                  ),
                  Row(
                    children: [
                      PluginInfoItem(
                        contentCrossAxisAlignment: CrossAxisAlignment.start,
                        title: (overview?.approvals?.length ?? 0).toString(),
                        content: dic['treasury.approval'],
                        lowTitle: true,
                        style: labelStyle,
                      ),
                      PluginInfoItem(
                        contentCrossAxisAlignment: CrossAxisAlignment.start,
                        title: overview?.proposalCount ?? '0',
                        content: dic['treasury.total'],
                        lowTitle: true,
                        style: labelStyle,
                      ),
                    ],
                  )
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProgressBar(),
                PluginInfoItem(
                  contentCrossAxisAlignment: CrossAxisAlignment.start,
                  title: '$spendPeriod days',
                  content: dic['treasury.period'],
                  isExpanded: false,
                  lowTitle: true,
                  style: labelStyle,
                ),
                PluginInfoItem(
                  contentCrossAxisAlignment: CrossAxisAlignment.start,
                  title: '0',
                  content: 'next',
                  isExpanded: false,
                  lowTitle: true,
                  style: labelStyle,
                ),
              ],
            ),
          ],
        ));
  }
}

class _ProgressBar extends StatelessWidget {
  _ProgressBar({this.progress = 0.5});
  final double progress;
  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      Container(
        width: 96,
        height: 96,
        child: CustomPaint(
          painter: CircularProgressBar(
              startAngle: pi * 3 / 2,
              width: 10,
              lineColor: [Color(0x0FFFFFFF), Color(0xFF81FEB9)],
              progress: progress),
        ),
      ),
      Text(
        Fmt.ratio(progress),
        style: Theme.of(context)
            .textTheme
            .headline4
            ?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
      ),
    ]);
  }
}

class _ProposalItem extends StatelessWidget {
  _ProposalItem({
    this.symbol,
    this.decimals,
    this.proposal,
    this.icon,
    this.accInfo,
    this.onRefresh,
  });

  final String? symbol;
  final int? decimals;
  final String? icon;
  final Map? accInfo;
  final SpendProposalData? proposal;
  final Function? onRefresh;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: AddressIcon(proposal!.proposal!.proposer, svg: icon),
      title: UI.accountDisplayName(proposal!.proposal!.proposer, accInfo),
      subtitle: Text(
          '${Fmt.balance(proposal!.proposal!.value.toString(), decimals!)} $symbol'),
      trailing: Text(
        '# ${int.parse(proposal!.id!)}',
        style: Theme.of(context).textTheme.headline4,
      ),
      // onTap: () async {
      //   final res = await Navigator.of(context)
      //       .pushNamed(SpendProposalPage.route, arguments: proposal);
      //   if (res != null) {
      //     onRefresh!();
      //   }
      // },
    );
  }
}
