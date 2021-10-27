import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:polkawallet_plugin_kusama/pages/governance/council/council.dart';
import 'package:polkawallet_plugin_kusama/pages/governance/govExternalLinks.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/api/types/gov/genExternalLinksParams.dart';
import 'package:polkawallet_sdk/api/types/gov/treasuryOverviewData.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/borderedTitle.dart';
import 'package:polkawallet_ui/components/roundedButton.dart';
import 'package:polkawallet_ui/components/roundedCard.dart';
import 'package:polkawallet_ui/components/txButton.dart';
import 'package:polkawallet_ui/pages/txConfirmPage.dart';
import 'package:polkawallet_ui/utils/format.dart';

class MotionDetailPage extends StatefulWidget {
  MotionDetailPage(this.plugin, this.keyring);
  final PluginKusama plugin;
  final Keyring keyring;

  static const String route = '/gov/council/motion';

  @override
  _MotionDetailPageState createState() => _MotionDetailPageState();
}

class _MotionDetailPageState extends State<MotionDetailPage> {
  final List<String?> methodExternal = [
    'externalPropose',
    'externalProposeDefault',
    'externalProposeMajority'
  ];
  final List<String?> methodTreasury = ['approveProposal', 'rejectProposal'];

  Map? _treasuryProposal;

  List? _links;

  Future<List?> _getExternalLinks(int? id) async {
    if (_links != null) return _links;

    final List? res = await widget.plugin.sdk.api.gov.getExternalLinks(
      GenExternalLinksParams.fromJson(
          {'data': id.toString(), 'type': 'council'}),
    );
    if (res != null) {
      setState(() {
        _links = res;
      });
    }
    return res;
  }

  Future<Map?> _fetchTreasuryProposal(String? id) async {
    if (_treasuryProposal != null) return _treasuryProposal;

    final Map? data =
        await widget.plugin.sdk.api.gov.queryTreasuryProposal(id!);
    if (data != null) {
      setState(() {
        _treasuryProposal = data;
      });
    }
    return _treasuryProposal;
  }

  void _onVote(bool approve) async {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov')!;
    final CouncilMotionData motion =
        ModalRoute.of(context)!.settings.arguments as CouncilMotionData;
    final args = TxConfirmParams(
      module: 'council',
      call: 'vote',
      txTitle: dic['treasury.vote'],
      txDisplay: {
        "proposalHash": motion.hash,
        "proposalId": motion.votes!.index,
        "voteValue": approve,
      },
      params: [
        motion.hash,
        motion.votes!.index,
        approve,
      ],
    );
    final res = await Navigator.of(context)
        .pushNamed(TxConfirmPage.route, arguments: args);
    if (res != null) {
      final CouncilMotionData motion =
          ModalRoute.of(context)!.settings.arguments as CouncilMotionData;
      _fetchTreasuryProposal(motion.proposal!.args![0]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map? dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov');
    final CouncilMotionData? motion =
        ModalRoute.of(context)!.settings.arguments as CouncilMotionData?;
    return GetBuilder(
      init: widget.plugin.store?.gov,
      builder: (_) {
        int blockTime = 6000;
        if (widget.plugin.networkConst['treasury'] != null) {
          blockTime = int.parse(
              widget.plugin.networkConst['babe']['expectedBlockTime']);
        }
        List<List<String>> params = [];
        motion!.proposal!.meta!.args!.asMap().forEach((k, v) {
          params.add(
              ['${v.name}: ${v.type}', motion.proposal!.args![k].toString()]);
        });
        bool isCouncil = false;
        widget.plugin.store!.gov.council.members!.forEach((e) {
          if (widget.keyring.current.address == e[0]) {
            isCouncil = true;
          }
        });
        bool isVotedYes = false;
        bool isVotedNo = false;
        motion.votes!.ayes!.forEach((e) {
          if (e == widget.keyring.current.address) {
            isVotedYes = true;
          }
        });
        motion.votes!.nays!.forEach((e) {
          if (e == widget.keyring.current.address) {
            isVotedNo = true;
          }
        });
        bool isTreasury = motion.proposal!.section == 'treasury' &&
            methodTreasury.indexOf(motion.proposal!.method) > -1;
        bool isExternal = motion.proposal!.section == 'democracy' &&
            methodExternal.indexOf(motion.proposal!.method) > -1;

        final votesEnd = BigInt.parse(motion.votes!.end.toString());
        return Scaffold(
          appBar: AppBar(
            title: Text('${dic!['council.motion']} #${motion.votes!.index}'),
            centerTitle: true,
          ),
          body: SafeArea(
            child: ListView(
              children: <Widget>[
                RoundedCard(
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${motion.proposal!.section}.${motion.proposal!.method}',
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      Text(motion.proposal!.meta!.documentation!.trim()),
                      Divider(),
                      Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: ProposalArgsItem(
                          label: Text('Hash'),
                          content: Text(
                            Fmt.address(motion.hash, pad: 10)!,
                            style: Theme.of(context).textTheme.headline4,
                          ),
                          margin: EdgeInsets.all(0),
                        ),
                      ),
                      params.length > 0
                          ? Text(
                              dic['proposal.params'],
                              style: TextStyle(
                                  color:
                                      Theme.of(context).unselectedWidgetColor),
                            )
                          : Container(),
                      params.length > 0
                          ? ProposalArgsList(params)
                          : Container(),
                      isTreasury
                          ? FutureBuilder(
                              future: _fetchTreasuryProposal(
                                  motion.proposal!.args![0]),
                              builder: (_, AsyncSnapshot<Map?> snapshot) {
                                if (snapshot.hasData) {
                                  return ProposalArgsItem(
                                    label: Text('proposal: TreasuryProposal'),
                                    content: Text(jsonEncode(snapshot.data)),
                                  );
                                }
                                return CupertinoActivityIndicator();
                              },
                            )
                          : Container(),
//                      isExternal
//                          ? FutureBuilder(
//                              future: _fetchTreasuryProposal(
//                                  motion.proposal.args[0]),
//                              builder: (_, AsyncSnapshot<Map> snapshot) {
//                                return snapshot.hasData
//                                    ? ProposalArgsItem(
//                                        label: Text('rpop'),
//                                        content: Text('xx'),
//                                      )
//                                    : CupertinoActivityIndicator();
//                              },
//                            )
//                          : Container(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(dic['vote.end']),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  Fmt.blockToTime(
                                    (votesEnd -
                                            widget.plugin.store!.gov.bestNumber)
                                        .toInt(),
                                    blockTime,
                                  ),
                                  style: Theme.of(context).textTheme.headline4,
                                ),
                                Text(
                                  '#$votesEnd',
                                  style: Theme.of(context).textTheme.headline4,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      FutureBuilder(
                        future: _getExternalLinks(motion.votes!.index),
                        builder: (_, AsyncSnapshot snapshot) {
                          if (snapshot.hasData) {
                            return GovExternalLinks(snapshot.data);
                          }
                          return Container();
                        },
                      ),
                      Divider(height: 24),
                      ProposalVoteButtonsRow(
                        isCouncil: isCouncil,
                        isVotedNo: isVotedNo,
                        isVotedYes: isVotedYes,
                        onVote: _onVote,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: BorderedTitle(title: dic['vote.voter']),
                ),
                ProposalVotingList(plugin: widget.plugin, council: motion),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ProposalArgsList extends StatefulWidget {
  ProposalArgsList(this.args);
  final List<List<String>> args;
  @override
  _ProposalArgsListState createState() => _ProposalArgsListState();
}

class _ProposalArgsListState extends State<ProposalArgsList> {
  bool _showDetail = false;

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [
      GestureDetector(
        child: Row(
          children: <Widget>[
            Icon(
              _showDetail
                  ? Icons.keyboard_arrow_down
                  : Icons.keyboard_arrow_right,
            ),
            Text(I18n.of(context)!
                .getDic(i18n_full_dic_kusama, 'gov')!['detail']!)
          ],
        ),
        onTap: () {
          setState(() {
            _showDetail = !_showDetail;
          });
        },
      )
    ];
    if (_showDetail) {
      items.addAll(widget.args.map((e) {
        return ProposalArgsItem(
          label: Text(e[0]),
          content: Text(
            e[1],
            style: Theme.of(context).textTheme.headline4,
          ),
        );
      }));
    }

    return Container(
      margin: EdgeInsets.only(top: 8, bottom: 8),
      decoration: BoxDecoration(
          border: Border(
              left:
                  BorderSide(color: Theme.of(context).dividerColor, width: 3))),
      child: Column(
        children: items,
      ),
    );
  }
}

class ProposalVoteButtonsRow extends StatelessWidget {
  ProposalVoteButtonsRow({
    this.isCouncil,
    this.isVotedYes,
    this.isVotedNo,
    this.onVote,
  });

  final bool? isCouncil;
  final bool? isVotedYes;
  final bool? isVotedNo;
  final Function(bool)? onVote;

  @override
  Widget build(BuildContext context) {
    final Map? dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov');
    return Row(
      children: <Widget>[
        Expanded(
          child: RoundedButton(
            icon: Icon(
              Icons.clear,
              color: Theme.of(context).cardColor,
            ),
            color: Colors.orange,
            text: isVotedNo! ? '${dic!['no']}(${dic['voted']})' : dic!['no'],
            onPressed: isCouncil! && !isVotedNo! ? () => onVote!(false) : null,
          ),
        ),
        Container(width: 16),
        Expanded(
          child: RoundedButton(
            icon: Icon(
              Icons.check,
              color: Theme.of(context).cardColor,
            ),
            text: isVotedYes! ? '${dic['yes']}(${dic['voted']})' : dic['yes'],
            onPressed: isCouncil! && !isVotedYes! ? () => onVote!(true) : null,
          ),
        ),
      ],
    );
  }
}

class ProposalArgsItem extends StatelessWidget {
  ProposalArgsItem({this.label, this.content, this.margin});

  final Widget? label;
  final Widget? content;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.fromLTRB(8, 4, 4, 4),
      padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
      decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.all(Radius.circular(4))),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[label!, content!],
            ),
          )
        ],
      ),
    );
  }
}

class ProposalVotingList extends StatefulWidget {
  ProposalVotingList({this.plugin, this.council});

  final PluginKusama? plugin;
  final CouncilMotionData? council;

  @override
  _ProposalVotingListState createState() => _ProposalVotingListState();
}

class _ProposalVotingListState extends State<ProposalVotingList> {
  int _tab = 0;

  void _changeTab(int i) {
    if (_tab != i) {
      setState(() {
        _tab = i;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov');
    final symbol = widget.plugin!.networkState.tokenSymbol![0];
    final decimals = widget.plugin!.networkState.tokenDecimals![0];
    final String voteCountAye =
        '${widget.council!.votes!.ayes!.length}/${widget.council!.votes!.threshold}';
    final int thresholdNay = widget.plugin!.store!.gov.council.members!.length -
        widget.council!.votes!.threshold! +
        1;
    final String voteCountNay =
        '${widget.council!.votes!.nays!.length}/$thresholdNay';
    return Container(
      padding: EdgeInsets.only(bottom: 24),
      margin: EdgeInsets.only(top: 8),
      color: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [0, 1].map((e) {
                final Color tabColor = e == _tab
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).disabledColor;
                return GestureDetector(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      e == 0
                          ? '${dic!['yes']}($voteCountAye)'
                          : '${dic!['no']}($voteCountNay)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: tabColor,
                      ),
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                        width: 2,
                        color: tabColor,
                      )),
                    ),
                  ),
                  onTap: () => _changeTab(e),
                );
              }).toList(),
            ),
          ),
          Column(
            children: _tab == 0
                ? widget.council!.votes!.ayes!.map((e) {
                    return CandidateItem(
                      accInfo:
                          widget.plugin!.store!.accounts.addressIndexMap[e],
                      icon: widget.plugin!.store!.accounts.addressIconsMap[e],
                      balance: widget.plugin!.store!.gov.council.members!
                          .firstWhere((i) => i[0] == e),
                      tokenSymbol: symbol,
                      decimals: decimals,
                    );
                  }).toList()
                : widget.council!.votes!.nays!.map((e) {
                    return CandidateItem(
                      accInfo:
                          widget.plugin!.store!.accounts.addressIndexMap[e],
                      icon: widget.plugin!.store!.accounts.addressIconsMap[e],
                      balance: widget.plugin!.store!.gov.council.members!
                          .firstWhere((i) => i[0] == e),
                      tokenSymbol: symbol,
                      decimals: decimals,
                    );
                  }).toList(),
          )
        ],
      ),
    );
  }
}
