import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_kusama/pages/governance/council/council.dart';
import 'package:polkawallet_plugin_kusama/pages/governance/council/councilVotePage.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/connectionChecker.dart';
import 'package:polkawallet_ui/components/infoItem.dart';
import 'package:polkawallet_ui/components/outlinedButtonSmall.dart';
import 'package:polkawallet_ui/components/roundedButton.dart';
import 'package:polkawallet_ui/components/v3/borderedTitle.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginLoadingWidget.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginScaffold.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginTxButton.dart';
import 'package:polkawallet_ui/components/v3/roundedCard.dart';
import 'package:polkawallet_ui/pages/v3/txConfirmPage.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/i18n.dart';

class CouncilPage extends StatefulWidget {
  CouncilPage(this.plugin, {Key? key}) : super(key: key);
  final PluginKusama plugin;

  static const String route = '/gov/council';

  @override
  State<CouncilPage> createState() => _CouncilPageState();
}

class _CouncilPageState extends State<CouncilPage> {
  bool _votesExpanded = false;

  Future<void> _refreshData() async {
    await widget.plugin.service.gov.queryCouncilInfo();
    await widget.plugin.service.gov.queryCouncilVotes();
    await widget.plugin.service.gov.queryUserCouncilVote();
  }

  Future<void> _submitCancelVotes() async {
    final govDic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov')!;
    final moduleName = await widget.plugin.service.getRuntimeModuleName(
        ['electionsPhragmen', 'elections', 'phragmenElection']);
    final params = TxConfirmParams(
      module: moduleName,
      call: 'removeVoter',
      txTitle: govDic['vote.remove'],
      txDisplay: {'action': 'removeVoter'},
      params: [],
      isPlugin: true,
    );
    final res = await Navigator.of(context)
        .pushNamed(TxConfirmPage.route, arguments: params);
    if (res != null) {
      _refreshData();
    }
  }

  Future<void> _onCancelVotes() async {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_ui, 'common');
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Container(),
          content: Text(I18n.of(context)!
              .getDic(i18n_full_dic_kusama, 'gov')!['vote.remove.confirm']!),
          actions: [
            CupertinoButton(
              child: Text(dic!['cancel']!),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoButton(
              child: Text(dic['ok']!),
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

  Widget _buildTopCard(String tokenView) {
    final decimals = widget.plugin.networkState.tokenDecimals![0];
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov')!;

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
                    '${widget.plugin.store.gov.council.members!.length}/${int.parse(widget.plugin.store.gov.council.desiredSeats ?? '13')}',
              ),
              InfoItem(
                crossAxisAlignment: CrossAxisAlignment.center,
                title: dic['up'],
                content: widget.plugin.store.gov.council.runnersUp?.length
                    .toString(),
              ),
              InfoItem(
                crossAxisAlignment: CrossAxisAlignment.center,
                title: dic['candidate'],
                content: widget.plugin.store.gov.council.candidates!.length
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
                          children: List.of(userVotes!['votes']).map((i) {
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
                            I18n.of(context)!.getDic(
                                i18n_full_dic_ui, 'common')!['list.empty']!,
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
                _refreshData();
              }
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov')!;
    return PluginScaffold(
        appBar: PluginAppBar(
          title: Text(dic['council']!),
        ),
        body: Observer(builder: (_) {
          final isDataLoading = widget.plugin.store.gov.council.members == null;
          final decimals = widget.plugin.networkState.tokenDecimals![0];
          final symbol = widget.plugin.networkState.tokenSymbol![0];
          return SafeArea(
              child: isDataLoading
                  ? Column(
                      children: [
                        ConnectionChecker(widget.plugin,
                            onConnected: _refreshData),
                        Container(
                          height: MediaQuery.of(context).size.height / 2,
                          child: PluginLoadingWidget(),
                        )
                      ],
                    )
                  : Column(children: [
                      ConnectionChecker(widget.plugin,
                          onConnected: _refreshData),
                      Expanded(
                          child: ListView(
                        children: <Widget>[
                          _buildTopCard(symbol),
                          Container(
                            padding:
                                EdgeInsets.only(top: 16, left: 16, bottom: 8),
                            color: Theme.of(context).cardColor,
                            child: BorderedTitle(
                              title: dic['member'],
                            ),
                          ),
                          Container(
                            color: Theme.of(context).cardColor,
                            child: Column(
                              children: widget.plugin.store.gov.council.members!
                                  .map((i) {
                                return CandidateItem(
                                  accInfo: widget.plugin.store.accounts
                                      .addressIndexMap[i[0]],
                                  icon: widget.plugin.store.accounts
                                      .addressIconsMap[i[0]],
                                  balance: i,
                                  tokenSymbol: symbol,
                                  decimals: decimals,
                                );
                              }).toList(),
                            ),
                          ),
                          Container(
                            padding:
                                EdgeInsets.only(top: 16, left: 16, bottom: 8),
                            color: Theme.of(context).cardColor,
                            child: BorderedTitle(
                              title: dic['up'],
                            ),
                          ),
                          Container(
                            color: Theme.of(context).cardColor,
                            child: Column(
                              children: widget
                                  .plugin.store.gov.council.runnersUp!
                                  .map((i) {
                                return CandidateItem(
                                  accInfo: widget.plugin.store.accounts
                                      .addressIndexMap[i[0]],
                                  icon: widget.plugin.store.accounts
                                      .addressIconsMap[i[0]],
                                  balance: i,
                                  tokenSymbol: symbol,
                                  decimals: decimals,
                                );
                              }).toList(),
                            ),
                          ),
                          Container(
                            padding:
                                EdgeInsets.only(top: 16, left: 16, bottom: 8),
                            color: Theme.of(context).cardColor,
                            child: BorderedTitle(
                              title: dic['candidate'],
                            ),
                          ),
                          Container(
                            color: Theme.of(context).cardColor,
                            child: widget.plugin.store.gov.council.candidates!
                                        .length >
                                    0
                                ? Column(
                                    children: widget
                                        .plugin.store.gov.council.candidates!
                                        .map((i) {
                                      return CandidateItem(
                                        accInfo: widget.plugin.store.accounts
                                            .addressIndexMap[i],
                                        icon: widget.plugin.store.accounts
                                            .addressIconsMap[i],
                                        balance: [i],
                                        tokenSymbol: symbol,
                                        decimals: decimals,
                                      );
                                    }).toList(),
                                  )
                                : Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Text(dic['candidate.empty']!),
                                  ),
                          ),
                        ],
                      ))
                    ]));
        }));
  }
}
