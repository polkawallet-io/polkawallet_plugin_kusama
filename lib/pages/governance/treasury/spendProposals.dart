import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:polkawallet_plugin_kusama/common/constants.dart';
import 'package:polkawallet_plugin_kusama/pages/governance/treasury/spendProposalPage.dart';
import 'package:polkawallet_plugin_kusama/pages/governance/treasury/submitProposalPage.dart';
import 'package:polkawallet_plugin_kusama/pages/governance/treasury/submitTipPage.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/api/types/gov/treasuryOverviewData.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/addressIcon.dart';
import 'package:polkawallet_ui/components/borderedTitle.dart';
import 'package:polkawallet_ui/components/infoItem.dart';
import 'package:polkawallet_ui/components/listTail.dart';
import 'package:polkawallet_ui/components/roundedButton.dart';
import 'package:polkawallet_ui/components/roundedCard.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/index.dart';

class SpendProposals extends StatefulWidget {
  SpendProposals(this.plugin, this.keyring);
  final PluginKusama plugin;
  final Keyring keyring;

  @override
  _ProposalsState createState() => _ProposalsState();
}

class _ProposalsState extends State<SpendProposals> {
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      new GlobalKey<RefreshIndicatorState>();

  Future<void> _fetchData() async {
    await widget.plugin.service!.gov.queryTreasuryOverview();
  }

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

  void _refreshPage() {
    _refreshKey.currentState!.show();
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
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov');
    return GetBuilder(
        init: widget.plugin.store?.accounts,
        builder: (_) {
          return GetBuilder(
            init: widget.plugin.store?.gov,
            builder: (_) {
              final decimals = widget.plugin.networkState.tokenDecimals![0];
              final symbol = widget.plugin.networkState.tokenSymbol![0];
              final balance = Fmt.balance(
                widget.plugin.store!.gov.treasuryOverview.balance,
                decimals,
              );
              bool isCouncil = false;
              widget.plugin.store!.gov.council.members!.forEach((e) {
                if (widget.keyring.current.address == e[0]) {
                  isCouncil = true;
                }
              });
              return RefreshIndicator(
                onRefresh: _fetchData,
                key: _refreshKey,
                child: ListView(
                  children: <Widget>[
                    _OverviewCard(
                      symbol: symbol,
                      balance: balance,
                      spendPeriod: _getSpendPeriod(),
                      overview: widget.plugin.store!.gov.treasuryOverview,
                      isCouncil: isCouncil,
                      refreshPage: _refreshPage,
                    ),
                    Container(
                      color: Theme.of(context).cardColor,
                      margin: EdgeInsets.only(top: 8),
                      child: widget.plugin.store!.gov.treasuryOverview
                                  .proposals ==
                              null
                          ? Center(child: CupertinoActivityIndicator())
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                                  child: BorderedTitle(
                                    title: dic!['treasury.proposal'],
                                  ),
                                ),
                                widget.plugin.store!.gov.treasuryOverview
                                                .proposals !=
                                            null &&
                                        widget
                                                .plugin
                                                .store!
                                                .gov
                                                .treasuryOverview
                                                .proposals!
                                                .length >
                                            0
                                    ? Column(
                                        children: widget.plugin.store!.gov
                                            .treasuryOverview.proposals!
                                            .map((e) {
                                          return _ProposalItem(
                                            symbol: symbol,
                                            decimals: decimals,
                                            icon: widget.plugin.store!.accounts
                                                    .addressIconsMap[
                                                e.proposal!.proposer],
                                            accInfo: widget.plugin.store!
                                                    .accounts.addressIndexMap[
                                                e.proposal!.proposer],
                                            proposal: e,
                                            onRefresh: _refreshPage,
                                          );
                                        }).toList(),
                                      )
                                    : ListTail(
                                        isEmpty: widget
                                                .plugin
                                                .store!
                                                .gov
                                                .treasuryOverview
                                                .proposals!
                                                .length ==
                                            0,
                                        isLoading: widget.plugin.store!.gov
                                                .treasuryOverview.proposals ==
                                            null,
                                      ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                                  child: BorderedTitle(
                                    title: dic['treasury.approval'],
                                  ),
                                ),
                                widget.plugin.store!.gov.treasuryOverview
                                                .approvals !=
                                            null &&
                                        widget
                                                .plugin
                                                .store!
                                                .gov
                                                .treasuryOverview
                                                .approvals!
                                                .length >
                                            0
                                    ? Padding(
                                        padding: EdgeInsets.only(bottom: 24),
                                        child: Column(
                                          children: widget.plugin.store!.gov
                                              .treasuryOverview.approvals!
                                              .map((e) {
                                            e.isApproval = true;
                                            return _ProposalItem(
                                              symbol: symbol,
                                              decimals: decimals,
                                              icon: widget.plugin.store!
                                                      .accounts.addressIconsMap[
                                                  e.proposal!.proposer],
                                              accInfo: widget.plugin.store!
                                                      .accounts.addressIndexMap[
                                                  e.proposal!.proposer],
                                              proposal: e,
                                              onRefresh: _refreshPage,
                                            );
                                          }).toList(),
                                        ),
                                      )
                                    : ListTail(
                                        isEmpty: widget
                                                .plugin
                                                .store!
                                                .gov
                                                .treasuryOverview
                                                .approvals!
                                                .length ==
                                            0,
                                        isLoading: widget.plugin.store!.gov
                                                .treasuryOverview.approvals ==
                                            null,
                                      ),
                              ],
                            ),
                    ),
                  ],
                ),
              );
            },
          );
        });
  }
}

class _OverviewCard extends StatelessWidget {
  _OverviewCard({
    this.symbol,
    this.balance,
    this.spendPeriod,
    this.overview,
    this.isCouncil,
    this.refreshPage,
  });

  final String? symbol;
  final String? balance;
  final int? spendPeriod;
  final TreasuryOverviewData? overview;
  final bool? isCouncil;
  final Function? refreshPage;

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov')!;
    return RoundedCard(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              InfoItem(
                crossAxisAlignment: CrossAxisAlignment.center,
                title: dic['treasury.proposal'],
                content: overview!.proposals?.length.toString(),
              ),
              InfoItem(
                crossAxisAlignment: CrossAxisAlignment.center,
                title: dic['treasury.total'],
                content: int.parse(overview!.proposalCount ?? '0').toString(),
              ),
              InfoItem(
                crossAxisAlignment: CrossAxisAlignment.center,
                title: dic['treasury.approval'],
                content: overview!.approvals?.length.toString(),
              ),
            ],
          ),
          Container(height: 24),
          Row(
            children: <Widget>[
              InfoItem(
                crossAxisAlignment: CrossAxisAlignment.center,
                title: '${dic['treasury.available']} ($symbol)',
                content: balance,
              ),
              InfoItem(
                crossAxisAlignment: CrossAxisAlignment.center,
                title: dic['treasury.period'],
                content: '$spendPeriod days',
              ),
            ],
          ),
          Divider(height: 24),
          Row(
            children: <Widget>[
              Expanded(
                child: RoundedButton(
                  text: dic['treasury.submit'],
                  icon: Icon(
                    Icons.add,
                    color: Theme.of(context).cardColor,
                    size: 20,
                  ),
                  onPressed: () async {
                    final res = await Navigator.of(context)
                        .pushNamed(SubmitProposalPage.route);
                    if (res != null) {
                      refreshPage!();
                    }
                  },
                ),
              ),
              Container(width: 12),
              RoundedButton(
                text: dic['treasury.tip'],
                icon: Icon(
                  Icons.add,
                  color: Theme.of(context).cardColor,
                  size: 20,
                ),
                onPressed: () async {
                  final res = await Navigator.of(context).pushNamed(
                    SubmitTipPage.route,
                    arguments: isCouncil,
                  );
                  if (res != null) {
                    refreshPage!();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
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
      onTap: () async {
        final res = await Navigator.of(context)
            .pushNamed(SpendProposalPage.route, arguments: proposal);
        if (res != null) {
          onRefresh!();
        }
      },
    );
  }
}
