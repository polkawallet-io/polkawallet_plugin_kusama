import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_chainx/common/components/infoItem.dart';
import 'package:polkawallet_plugin_chainx/pages/governance/council/candidateDetailPage.dart';
import 'package:polkawallet_plugin_chainx/pages/governance/council/councilVotePage.dart';
import 'package:polkawallet_plugin_chainx/polkawallet_plugin_chainx.dart';
import 'package:polkawallet_plugin_chainx/utils/i18n/index.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/addressIcon.dart';
import 'package:polkawallet_ui/components/borderedTitle.dart';
import 'package:polkawallet_ui/components/outlinedButtonSmall.dart';
import 'package:polkawallet_ui/components/roundedButton.dart';
import 'package:polkawallet_ui/components/roundedCard.dart';
import 'package:polkawallet_ui/components/txButton.dart';
import 'package:polkawallet_ui/pages/txConfirmPage.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/i18n.dart';
import 'package:polkawallet_ui/utils/index.dart';

class Council extends StatefulWidget {
  Council(this.plugin);
  final PluginChainX plugin;

  @override
  State<StatefulWidget> createState() => _CouncilState();
}

class _CouncilState extends State<Council> {
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      new GlobalKey<RefreshIndicatorState>();

  bool _votesExpanded = false;

  Future<void> _fetchCouncilInfo() async {
    if (widget.plugin.sdk.api.connectedNode == null) {
      return;
    }
    await widget.plugin.service.gov.queryCouncilVotes();
    widget.plugin.service.gov.queryUserCouncilVote();
  }

  Future<void> _submitCancelVotes() async {
    final govDic = I18n.of(context).getDic(i18n_full_dic_chainx, 'gov');
    final params = TxConfirmParams(
      module: 'electionsPhragmen',
      call: 'removeVoter',
      txTitle: govDic['vote.remove'],
      txDisplay: {},
      params: [],
    );
    final res = await Navigator.of(context)
        .pushNamed(TxConfirmPage.route, arguments: params);
    if (res != null) {
      _refreshKey.currentState.show();
    }
  }

  Future<void> _onCancelVotes() async {
    final dic = I18n.of(context).getDic(i18n_full_dic_ui, 'common');
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Container(),
          content: Text(I18n.of(context)
              .getDic(i18n_full_dic_chainx, 'gov')['vote.remove.confirm']),
          actions: [
            CupertinoButton(
              child: Text(dic['cancel']),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoButton(
              child: Text(dic['ok']),
              onPressed: () {
                Navigator.of(context).pop();
                _submitCancelVotes();
              },
            )
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshKey.currentState.show();
    });
  }

  Widget _buildTopCard(String tokenView) {
    final decimals = widget.plugin.networkState.tokenDecimals[0] ?? 12;
    final dic = I18n.of(context).getDic(i18n_full_dic_chainx, 'gov');

    final userVotes = widget.plugin.store.gov.userCouncilVotes;
    BigInt voteAmount = BigInt.zero;
    double listHeight = 48;
    if (userVotes != null) {
      voteAmount = BigInt.parse(userVotes['stake'].toString());
      int listCount = List.of(userVotes['votes']).length;
      if (listCount > 0) {
        listHeight = double.parse((listCount * 52).toString());
      }
    }
    return RoundedCard(
      margin: EdgeInsets.fromLTRB(16, 12, 16, 24),
      padding: EdgeInsets.all(24),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              InfoItem(
                crossAxisAlignment: CrossAxisAlignment.center,
                title: dic['seats'],
                content:
                    '${widget.plugin.store.gov.council.members.length}/${int.parse(widget.plugin.store.gov.council.desiredSeats)}',
              ),
              InfoItem(
                crossAxisAlignment: CrossAxisAlignment.center,
                title: dic['up'],
                content:
                    widget.plugin.store.gov.council.runnersUp.length.toString(),
              ),
              InfoItem(
                crossAxisAlignment: CrossAxisAlignment.center,
                title: dic['candidate'],
                content: widget.plugin.store.gov.council.candidates.length
                    .toString(),
              )
            ],
          ),
          Divider(height: 24),
          Column(
            children: <Widget>[
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _votesExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 28,
                      color: Theme.of(context).unselectedWidgetColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _votesExpanded = !_votesExpanded;
                      });
                    },
                  ),
                  InfoItem(
                    content: '${Fmt.token(voteAmount, decimals)} $tokenView',
                    title: dic['vote.my'],
                  ),
                  OutlinedButtonSmall(
                    content: dic['vote.remove'],
                    active: false,
                    onPressed: listHeight > 48
                        ? () {
                            _onCancelVotes();
                          }
                        : null,
                  ),
                ],
              ),
              AnimatedContainer(
                height: _votesExpanded ? listHeight : 0,
                duration: Duration(seconds: 1),
                curve: Curves.fastOutSlowIn,
                child: AnimatedOpacity(
                  opacity: _votesExpanded ? 1.0 : 0.0,
                  duration: Duration(seconds: 1),
                  curve: Curves.fastLinearToSlowEaseIn,
                  child: listHeight > 48
                      ? ListView(
                          children: List.of(userVotes['votes']).map((i) {
                            return CandidateItem(
                              accInfo: widget
                                  .plugin.store.accounts.addressIndexMap[i],
                              icon: widget
                                  .plugin.store.accounts.addressIconsMap[i],
                              iconSize: 32,
                              balance: [i],
                              tokenSymbol: tokenView,
                              decimals: decimals,
                              noTap: true,
                            );
                          }).toList(),
                        )
                      : Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Text(
                            I18n.of(context).getDic(
                                i18n_full_dic_ui, 'common')['list.empty'],
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                ),
              )
            ],
          ),
          Divider(height: 24),
          RoundedButton(
            text: dic['vote'],
            onPressed: () async {
              final res =
                  await Navigator.of(context).pushNamed(CouncilVotePage.route);
              if (res != null) {
                _refreshKey.currentState.show();
              }
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).getDic(i18n_full_dic_chainx, 'gov');
    return Observer(builder: (_) {
      final decimals = widget.plugin.networkState.tokenDecimals[0];
      final symbol = widget.plugin.networkState.tokenSymbol[0];
      return RefreshIndicator(
        key: _refreshKey,
        onRefresh: _fetchCouncilInfo,
        child: widget.plugin.store.gov.council == null
            ? Container()
            : ListView(
                children: <Widget>[
                  _buildTopCard(symbol),
                  Container(
                    padding: EdgeInsets.only(top: 16, left: 16, bottom: 8),
                    color: Theme.of(context).cardColor,
                    child: BorderedTitle(
                      title: dic['member'],
                    ),
                  ),
                  Container(
                    color: Theme.of(context).cardColor,
                    child: Column(
                      children:
                          widget.plugin.store.gov.council.members.map((i) {
                        return CandidateItem(
                          accInfo: widget
                              .plugin.store.accounts.addressIndexMap[i[0]],
                          icon: widget
                              .plugin.store.accounts.addressIconsMap[i[0]],
                          balance: i,
                          tokenSymbol: symbol,
                          decimals: decimals,
                        );
                      }).toList(),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 16, left: 16, bottom: 8),
                    color: Theme.of(context).cardColor,
                    child: BorderedTitle(
                      title: dic['up'],
                    ),
                  ),
                  Container(
                    color: Theme.of(context).cardColor,
                    child: Column(
                      children:
                          widget.plugin.store.gov.council.runnersUp.map((i) {
                        return CandidateItem(
                          accInfo: widget
                              .plugin.store.accounts.addressIndexMap[i[0]],
                          icon: widget
                              .plugin.store.accounts.addressIconsMap[i[0]],
                          balance: i,
                          tokenSymbol: symbol,
                          decimals: decimals,
                        );
                      }).toList(),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 16, left: 16, bottom: 8),
                    color: Theme.of(context).cardColor,
                    child: BorderedTitle(
                      title: dic['candidate'],
                    ),
                  ),
                  Container(
                    color: Theme.of(context).cardColor,
                    child: widget.plugin.store.gov.council.candidates.length > 0
                        ? Column(
                            children: widget.plugin.store.gov.council.candidates
                                .map((i) {
                              return CandidateItem(
                                accInfo: widget
                                    .plugin.store.accounts.addressIndexMap[i],
                                icon: widget
                                    .plugin.store.accounts.addressIconsMap[i],
                                balance: [i],
                                tokenSymbol: symbol,
                                decimals: decimals,
                              );
                            }).toList(),
                          )
                        : Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(dic['candidate.empty']),
                          ),
                  ),
                ],
              ),
      );
    });
  }
}

class CandidateItem extends StatelessWidget {
  CandidateItem({
    this.accInfo,
    this.balance,
    this.tokenSymbol,
    this.decimals,
    this.icon,
    this.iconSize,
    this.noTap = false,
    this.trailing,
  });
  final Map accInfo;
  // balance == [<candidate_address>, <0x_candidate_backing_amount>]
  final List balance;
  final String tokenSymbol;
  final int decimals;
  final String icon;
  final double iconSize;
  final bool noTap;
  final Widget trailing;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: AddressIcon(balance[0], size: iconSize, svg: icon),
      title: UI.accountDisplayName(balance[0], accInfo),
      subtitle: balance.length == 1
          ? null
          : Text(
              '${I18n.of(context).getDic(i18n_full_dic_chainx, 'gov')['backing']}: ${Fmt.token(
              BigInt.parse(balance[1].toString()),
              decimals,
              length: 0,
            )} $tokenSymbol'),
      onTap: noTap
          ? null
          : () => Navigator.of(context).pushNamed(CandidateDetailPage.route,
              arguments: balance.length == 1 ? [balance[0], '0x0'] : balance),
      trailing: trailing ?? Container(width: 8),
    );
  }
}
