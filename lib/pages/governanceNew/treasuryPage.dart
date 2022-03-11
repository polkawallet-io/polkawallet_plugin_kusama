import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_kusama/common/constants.dart';
import 'package:polkawallet_plugin_kusama/pages/governanceNew/govExternalLinks.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/api/types/gov/genExternalLinksParams.dart';
import 'package:polkawallet_sdk/api/types/gov/treasuryOverviewData.dart';
import 'package:polkawallet_sdk/api/types/gov/treasuryTipData.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/addressIcon.dart';
import 'package:polkawallet_ui/components/circularProgressBar.dart';
import 'package:polkawallet_ui/components/v3/infoItemRow.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginInfoItem.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginScaffold.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginTabCard.dart';
import 'package:polkawallet_ui/components/v3/plugin/roundedPluginCard.dart';
import 'package:polkawallet_ui/utils/consts.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/i18n.dart';
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

  final Map<String, List> _links = {};

  String _getSpendPeriod() {
    if (widget.plugin.networkConst['treasury'] != null) {
      final period =
          int.parse(widget.plugin.networkConst['treasury']['spendPeriod']);
      final blockTime =
          int.parse(widget.plugin.networkConst['babe']['expectedBlockTime']);
      final spendDays = period * (blockTime ~/ 1000) ~/ SECONDS_OF_DAY;
      final ongoing = widget.plugin.store.gov.bestNumber.toInt() % period;
      return "${Fmt.blockToTime(period - ongoing, blockTime)}/ $spendDays days";
    }
    return '--/--';
  }

  double _getSpendPeriodRatio() {
    if (widget.plugin.networkConst['treasury'] != null) {
      final period =
          int.parse(widget.plugin.networkConst['treasury']['spendPeriod']);
      final ongoing = widget.plugin.store.gov.bestNumber.toInt() % period;
      return ongoing / (period * 1.0);
    }
    return 0;
  }

  Future<List?> _getExternalLinks(int id) async {
    if (_links[id.toString()] != null) return _links[id.toString()];
    final List? res = await widget.plugin.sdk.api.gov.getExternalLinks(
      GenExternalLinksParams.fromJson(
          {'data': id.toString(), 'type': 'treasury'}),
    );
    if (res != null) {
      setState(() {
        _links[id.toString()] = res;
      });
    }
    return res;
  }

  Future<void> _fetchData() async {
    widget.plugin.service.gov.updateBestNumber();
    widget.plugin.service.gov.queryTreasuryTips();
    final datas = await widget.plugin.service.gov.queryTreasuryOverview();
    datas.approvals!.forEach((element) {
      _getExternalLinks(int.parse(element.id!));
    });
    datas.proposals!.forEach((element) {
      _getExternalLinks(int.parse(element.id!));
    });
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
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  // itemCount: (_tab == 0 ? proposals.length : tips.length) + 1,
                  itemCount: 2,
                  itemBuilder: (_, index) {
                    if (index == 0) {
                      return Column(
                        children: [
                          _OverviewCard(
                            symbol: symbol,
                            decimals: decimals,
                            spendPeriod: _getSpendPeriod(),
                            spendPeriodRatio: _getSpendPeriodRatio(),
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
                    } else {
                      return (_tab == 0 ? proposals.length : tips.length) == 0
                          ? Container(
                              padding: EdgeInsets.all(16),
                              margin: EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(8),
                                  bottomLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                ),
                                color: PluginColorsDark.cardColor,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                I18n.of(context)!.getDic(
                                    i18n_full_dic_ui, 'common')!['list.empty']!,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline4
                                    ?.copyWith(color: Colors.white),
                              ))
                          : Container(
                              width: double.infinity,
                              padding: EdgeInsets.zero,
                              margin: EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                  color: PluginColorsDark.cardColor,
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(8),
                                      topRight: Radius.circular(8),
                                      bottomRight: Radius.circular(8))),
                              child: ListView.separated(
                                  padding: EdgeInsets.zero,
                                  separatorBuilder: (context, index) => _tab ==
                                          0
                                      ? Padding(
                                          padding: EdgeInsets.only(left: 13),
                                          child: Divider(),
                                        )
                                      : Container(),
                                  itemCount: _tab == 0
                                      ? proposals.length
                                      : tips.length,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final i = index;
                                    if (_tab == 0) {
                                      final link = _links[
                                          int.parse(proposals[i].id!)
                                              .toString()];
                                      return _ProposalItem(
                                        symbol: symbol,
                                        decimals: decimals,
                                        icon: widget.plugin.store.accounts
                                                .addressIconsMap[
                                            proposals[i].proposal!.proposer],
                                        accInfo: widget.plugin.store.accounts
                                                .addressIndexMap[
                                            proposals[i].proposal!.proposer],
                                        proposal: proposals[i],
                                        plugin: widget.plugin,
                                        isApproved: index >=
                                            (widget
                                                        .plugin
                                                        .store
                                                        .gov
                                                        .treasuryOverview
                                                        .proposals ??
                                                    [])
                                                .length,
                                        links: Visibility(
                                          visible: link != null,
                                          child: GovExternalLinks(link ?? []),
                                        ),
                                      );
                                    }

                                    final TreasuryTipData tip = tips[i];
                                    final icon = widget.plugin.store.accounts
                                        .addressIconsMap[tip.who];
                                    final indices = widget.plugin.store.accounts
                                        .addressIndexMap[tip.who];
                                    return Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Row(
                                          children: [
                                            Expanded(
                                                child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                right: 10),
                                                        child: AddressIcon(
                                                          tip.who,
                                                          svg: icon,
                                                          size: 28,
                                                        )),
                                                    Expanded(
                                                        child: UI.accountDisplayName(
                                                            tip.who, indices,
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .headline5
                                                                ?.copyWith(
                                                                    color: PluginColorsDark
                                                                        .headline1,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600)))
                                                  ],
                                                ),
                                                Padding(
                                                    padding:
                                                        EdgeInsets.only(top: 3),
                                                    child: Text.rich(
                                                        TextSpan(children: [
                                                      TextSpan(
                                                          text:
                                                              "${dic['treasury.reason']}：",
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .headline5
                                                              ?.copyWith(
                                                                  color: PluginColorsDark
                                                                      .headline1,
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600)),
                                                      TextSpan(
                                                          text: tip.reason!,
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .headline5
                                                              ?.copyWith(
                                                                  color: PluginColorsDark
                                                                      .headline1,
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300))
                                                    ])))
                                              ],
                                            )),
                                            Column(
                                              children: [
                                                Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 6),
                                                    child: Image.asset(
                                                      'packages/polkawallet_plugin_kusama/assets/images/gov/gov_treasury.png',
                                                      width: 32,
                                                    )),
                                                Text(
                                                  "${dic['treasury.tipper']}(${tip.tips!.length.toString()})",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline5
                                                      ?.copyWith(
                                                          color:
                                                              PluginColorsDark
                                                                  .headline1,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                ),
                                                Text(
                                                  '${Fmt.balance(
                                                    tip.deposit.toString(),
                                                    decimals,
                                                  )} $symbol',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline5
                                                      ?.copyWith(
                                                          color:
                                                              PluginColorsDark
                                                                  .headline1,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                ),
                                              ],
                                            )
                                          ],
                                        ));
                                  }));
                    }
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
    required this.spendPeriod,
    this.overview,
    this.refreshPage,
    required this.spendPeriodRatio,
  });

  final String symbol;
  final int decimals;
  final String spendPeriod;
  final double spendPeriodRatio;
  final TreasuryOverviewData? overview;
  final Function? refreshPage;

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov')!;
    final labelStyle = Theme.of(context)
        .textTheme
        .headline4
        ?.copyWith(fontSize: 12, color: PluginColorsDark.headline2);
    final titleStyle = Theme.of(context)
        .textTheme
        .headline1
        ?.copyWith(fontSize: 14, color: PluginColorsDark.headline1);

    final available = Fmt.priceFloorBigIntFormatter(
        Fmt.balanceInt(overview?.balance ?? '0'), decimals);
    final spendable = Fmt.priceFloorBigIntFormatter(
        Fmt.balanceInt(overview?.spendable ?? '0'), decimals);
    final leftRatio = Fmt.balanceInt(overview?.balance ?? '0') == BigInt.zero
        ? 0.0
        : Fmt.balanceInt(overview?.spendable ?? '0') /
            Fmt.balanceInt(overview?.balance ?? '0');
    return RoundedPluginCard(
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.symmetric(vertical: 16),
        borderRadius: const BorderRadius.all(const Radius.circular(8)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProgressBar(
                      progress: leftRatio, key: Key("${Fmt.ratio(leftRatio)}")),
                  PluginInfoItem(
                    contentCrossAxisAlignment: CrossAxisAlignment.start,
                    title: '$spendable/$available $symbol',
                    content:
                        '${dic['treasury.spendable']}/${dic['treasury.available']}',
                    isExpanded: false,
                    lowTitle: true,
                    style: labelStyle,
                    titleStyle: titleStyle,
                  ),
                  Row(
                    children: [
                      PluginInfoItem(
                        contentCrossAxisAlignment: CrossAxisAlignment.start,
                        title: (overview?.approvals?.length ?? 0).toString(),
                        content: dic['treasury.approval'],
                        lowTitle: true,
                        style: labelStyle,
                        titleStyle: titleStyle,
                      ),
                      PluginInfoItem(
                        contentCrossAxisAlignment: CrossAxisAlignment.start,
                        title: int.parse(overview?.proposalCount ?? '0x0')
                            .toString(),
                        content: dic['treasury.total'],
                        lowTitle: true,
                        style: labelStyle,
                        titleStyle: titleStyle,
                      ),
                    ],
                  )
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProgressBar(progress: this.spendPeriodRatio, key: Key("1")),
                PluginInfoItem(
                  contentCrossAxisAlignment: CrossAxisAlignment.start,
                  title: spendPeriod,
                  content: dic['treasury.period'],
                  isExpanded: false,
                  lowTitle: true,
                  style: labelStyle,
                  titleStyle: titleStyle,
                ),
                PluginInfoItem(
                  contentCrossAxisAlignment: CrossAxisAlignment.start,
                  title:
                      "${Fmt.priceFloorBigIntFormatter(Fmt.balanceInt(overview?.burn ?? '0'), decimals)} $symbol",
                  content: dic['v3.treasury.nextBurn'],
                  isExpanded: false,
                  lowTitle: true,
                  style: labelStyle,
                  titleStyle: titleStyle,
                ),
              ],
            ),
          ],
        ));
  }
}

class _ProgressBar extends StatefulWidget {
  _ProgressBar({Key? key, this.progress = 0.5}) : super(key: key);
  final double progress;

  @override
  State<_ProgressBar> createState() => __ProgressBarState();
}

class __ProgressBarState extends State<_ProgressBar>
    with TickerProviderStateMixin {
  AnimationController? controller;
  double animationNumber = 0;
  late Animation<double> animation;

  void _startAnimation(double progress) {
    this.controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    animation =
        Tween(begin: animationNumber, end: progress).animate(this.controller!);
    animation.addListener(() {
      setState(() {
        animationNumber = animation.value;
      });
    });
    Future.delayed(Duration(milliseconds: 150), () {
      controller!.forward();
    });
  }

  @override
  void didUpdateWidget(covariant _ProgressBar oldWidget) {
    if (this.controller == null ||
        (!this.controller!.isAnimating &&
            oldWidget.progress != widget.progress)) {
      _startAnimation(widget.progress);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: Stack(alignment: Alignment.center, children: [
          Container(
            width: 96,
            height: 96,
            child: CustomPaint(
              painter: CircularProgressBar(
                  startAngle: pi * 3 / 2,
                  width: 10,
                  lineColor: [Color(0x4DFFFFFF), Color(0xFF81FEB9)],
                  progress:
                      this.controller != null && this.controller!.isAnimating
                          ? animationNumber
                          : widget.progress,
                  bgColor: Colors.white.withAlpha(38)),
            ),
          ),
          Text(
            Fmt.ratio(widget.progress),
            style: Theme.of(context)
                .textTheme
                .headline4
                ?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ]));
  }
}

class _ProposalItem extends StatefulWidget {
  _ProposalItem(
      {Key? key,
      this.symbol,
      this.decimals,
      this.proposal,
      this.icon,
      this.accInfo,
      this.isApproved = true,
      required this.plugin,
      this.links})
      : super(key: key);

  final String? symbol;
  final int? decimals;
  final String? icon;
  final Map? accInfo;
  final SpendProposalData? proposal;
  final bool isApproved;
  final PluginKusama plugin;
  final Widget? links;

  @override
  State<_ProposalItem> createState() => __ProposalItemState();
}

class __ProposalItemState extends State<_ProposalItem> {
  bool _isExpansion = false;

  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov')!;
    final decimals = widget.plugin.networkState.tokenDecimals![0];
    final symbol = widget.plugin.networkState.tokenSymbol![0];
    final style = Theme.of(context)
        .textTheme
        .headline5
        ?.copyWith(fontSize: 12, color: Colors.white);
    List<Widget> widgets = [];
    if (_isExpansion) {
      widgets.addAll([
        Padding(
          padding: EdgeInsets.only(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dic['treasury.beneficiary']!, style: style),
              Row(
                children: [
                  AddressIcon(
                    widget.proposal!.proposal!.beneficiary,
                    svg: widget.plugin.store.accounts.addressIconsMap[
                        widget.proposal!.proposal!.beneficiary],
                    size: 14,
                  ),
                  Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: UI.accountDisplayName(
                          widget.proposal!.proposal!.beneficiary,
                          widget.plugin.store.accounts.addressIndexMap[
                              widget.proposal!.proposal!.beneficiary],
                          style: style,
                          expand: false))
                ],
              )
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 4),
          child: InfoItemRow(
            dic['treasury.value']!,
            '${Fmt.balance(
              widget.proposal!.proposal!.value.toString(),
              decimals,
            )} $symbol',
            labelStyle: style,
            contentStyle: style,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 4),
          child: InfoItemRow(
            dic['v3.locked']!,
            '${Fmt.balance(
              widget.proposal!.proposal!.bond.toString(),
              decimals,
            )} $symbol',
            labelStyle: style,
            contentStyle: style,
          ),
        ),
        Container(
            padding: EdgeInsets.only(top: 20),
            width: double.infinity,
            alignment: Alignment.centerRight,
            child: widget.links)
      ]);
    }
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _isExpansion = !_isExpansion;
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      margin: EdgeInsets.only(left: 16, top: 8),
                      child: Text(
                        '#${int.parse(widget.proposal!.id!)}',
                        style: Theme.of(context).textTheme.headline3?.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      )),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                      color: Color(0x1AFFFFFF),
                    ),
                    child: Text(
                      dic['v3.treasury.${widget.isApproved ? 'Approved' : 'pending'}']!,
                      style: Theme.of(context).textTheme.headline5?.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: widget.isApproved
                              ? PluginColorsDark.green
                              : PluginColorsDark.headline1),
                    ),
                  )
                ]),
            Padding(
                padding: EdgeInsets.only(bottom: 16, left: 16, right: 16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                              padding: EdgeInsets.only(right: 5),
                              child: AddressIcon(
                                widget.proposal!.proposal!.proposer,
                                svg: widget.icon,
                                size: 28,
                              )),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              UI.accountDisplayName(
                                  widget.proposal!.proposal!.proposer,
                                  widget.accInfo,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline5
                                      ?.copyWith(
                                          color: PluginColorsDark.headline1,
                                          fontWeight: FontWeight.w600)),
                              Text(dic['treasury.proposer']!, style: style)
                            ],
                          ))
                        ],
                      ),
                      ...widgets
                    ]))
          ],
        ));
  }
}
