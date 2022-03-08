import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_kusama/pages/governanceNew/candidateDetailPage.dart';
import 'package:polkawallet_plugin_kusama/pages/governanceNew/councilVotePage.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/addressIcon.dart';
import 'package:polkawallet_ui/components/connectionChecker.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginButton.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginInfoItem.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginLoadingWidget.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginOutlinedButtonSmall.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginRadioButton.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginScaffold.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginTextTag.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginTxButton.dart';
import 'package:polkawallet_ui/components/v3/plugin/roundedPluginCard.dart';
import 'package:polkawallet_ui/pages/v3/txConfirmPage.dart';
import 'package:polkawallet_ui/utils/consts.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/i18n.dart';
import 'package:polkawallet_ui/utils/index.dart';

class CouncilPage extends StatefulWidget {
  CouncilPage(this.plugin, {Key? key}) : super(key: key);
  final PluginKusama plugin;

  static const String route = '/gov/council';

  @override
  State<CouncilPage> createState() => _CouncilPageState();
}

class _CouncilPageState extends State<CouncilPage> {
  bool _select = false;
  List<List>? _selectDatas;

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
    int listCount = 0;
    BigInt voteAmount = BigInt.zero;
    if (userVotes != null) {
      voteAmount = BigInt.parse(userVotes['stake'].toString());
      listCount = List.of(userVotes['votes']).length;
    }
    return RoundedPluginCard(
      margin: EdgeInsets.fromLTRB(16, 12, 16, 24),
      borderRadius: const BorderRadius.all(const Radius.circular(8)),
      color: Color(0x1aFFFFFF),
      child: Column(
        children: <Widget>[
          Container(
              padding:
                  EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 14),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(14),
                    topRight: const Radius.circular(14)),
                color: Color.fromARGB(255, 68, 70, 74),
              ),
              child: Row(
                children: <Widget>[
                  PluginInfoItem(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    contentCrossAxisAlignment: CrossAxisAlignment.start,
                    titleStyle: Theme.of(context)
                        .textTheme
                        .headline5
                        ?.copyWith(color: Colors.white),
                    style: Theme.of(context).textTheme.headline3?.copyWith(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.7),
                    title: dic['seats'],
                    content:
                        '${widget.plugin.store.gov.council.members!.length}/${int.parse(widget.plugin.store.gov.council.desiredSeats ?? '13')}',
                  ),
                  PluginInfoItem(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    contentCrossAxisAlignment: CrossAxisAlignment.start,
                    titleStyle: Theme.of(context)
                        .textTheme
                        .headline5
                        ?.copyWith(color: Colors.white),
                    style: Theme.of(context).textTheme.headline3?.copyWith(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.7),
                    title: dic['up'],
                    content: widget.plugin.store.gov.council.runnersUp?.length
                        .toString(),
                  ),
                  PluginInfoItem(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    contentCrossAxisAlignment: CrossAxisAlignment.start,
                    titleStyle: Theme.of(context)
                        .textTheme
                        .headline5
                        ?.copyWith(color: Colors.white),
                    style: Theme.of(context).textTheme.headline3?.copyWith(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.7),
                    title: dic['candidate'],
                    content: widget.plugin.store.gov.council.candidates!.length
                        .toString(),
                  )
                ],
              )),
          Container(
            padding: EdgeInsets.only(left: 16, top: 15, right: 12, bottom: 15),
            child: Row(
              children: [
                PluginInfoItem(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  contentCrossAxisAlignment: CrossAxisAlignment.start,
                  titleStyle: Theme.of(context)
                      .textTheme
                      .headline5
                      ?.copyWith(color: Colors.white),
                  style: Theme.of(context).textTheme.headline3?.copyWith(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.7),
                  title: dic['voted'],
                  content:
                      '${Fmt.priceFloorBigIntFormatter(voteAmount, decimals)} $tokenView',
                ),
                Expanded(
                    child: Row(
                  children: [
                    PluginInfoItem(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      contentCrossAxisAlignment: CrossAxisAlignment.start,
                      titleStyle: Theme.of(context)
                          .textTheme
                          .headline5
                          ?.copyWith(color: Colors.white),
                      style: Theme.of(context).textTheme.headline3?.copyWith(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.7),
                      title: dic['vote.my'],
                      content: listCount.toString(),
                    ),
                    Expanded(
                        child: PluginOutlinedButtonSmall(
                      margin: EdgeInsets.only(top: 15),
                      content: dic['v3.unvoteAll'],
                      color: PluginColorsDark.primary,
                      minSize: 29,
                      active: true,
                      onPressed: listCount > 0 ? () => _onCancelVotes() : null,
                    ))
                  ],
                ))
              ],
            ),
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
          final isDataLoading =
              widget.plugin.store.gov.council.members == null ||
                  widget.plugin.store.gov.userCouncilVotes == null;
          final decimals = widget.plugin.networkState.tokenDecimals![0];
          final symbol = widget.plugin.networkState.tokenSymbol![0];
          if (_selectDatas == null) {
            final userVotes = widget.plugin.store.gov.userCouncilVotes;
            _selectDatas = [];
            if (userVotes != null) {
              List.of(userVotes['votes']).forEach((element) {
                _selectDatas!.add([element]);
              });
            }
          }
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
                        physics: BouncingScrollPhysics(),
                        children: <Widget>[
                          _buildTopCard(symbol),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              PluginTextTag(
                                padding: EdgeInsets.zero,
                                margin: EdgeInsets.only(left: 16),
                                title: dic['member']!,
                              ),
                              PluginOutlinedButtonSmall(
                                margin: EdgeInsets.only(bottom: 6, right: 16),
                                content: _select
                                    ? I18n.of(context)!.getDic(
                                        i18n_full_dic_kusama,
                                        'common')!['cancel']
                                    : dic['v3.select'],
                                color: PluginColorsDark.primary,
                                activeTextcolor:
                                    _select ? Colors.white : Colors.black,
                                active: true,
                                fontSize: 12,
                                minSize: 19,
                                onPressed: () {
                                  setState(() {
                                    _select = !_select;
                                  });
                                },
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 3),
                              )
                            ],
                          ),
                          Container(
                            color: Color(0xFFFFFFFF).withAlpha(25),
                            child: Column(
                              children: widget.plugin.store.gov.council.members!
                                  .map((i) {
                                final index = List.of(widget.plugin.store.gov
                                        .userCouncilVotes!['votes'])
                                    .indexWhere((element) {
                                  return element == i[0];
                                });
                                return CandidateItem(
                                  accInfo: widget.plugin.store.accounts
                                      .addressIndexMap[i[0]],
                                  icon: widget.plugin.store.accounts
                                      .addressIconsMap[i[0]],
                                  balance: i,
                                  tokenSymbol: symbol,
                                  decimals: decimals,
                                  isMyVote: index >= 0,
                                  isShowDivider: i !=
                                      widget.plugin.store.gov.council.members!
                                          .last,
                                  trailing: _select
                                      ? GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                left: 30,
                                                top: 15,
                                                right: 10,
                                                bottom: 15),
                                            child: PluginRadioButton(
                                              value: _selectDatas!.indexWhere(
                                                      (element) =>
                                                          element[0] == i[0]) >=
                                                  0,
                                            ),
                                          ),
                                          onTap: () {
                                            print(_selectDatas!.indexWhere(
                                                (element) =>
                                                    element[0] == i[0]));
                                            setState(() {
                                              final valueIndex = _selectDatas!
                                                  .indexWhere((element) =>
                                                      element[0] == i[0]);
                                              if (valueIndex >= 0) {
                                                _selectDatas!
                                                    .removeAt(valueIndex);
                                              } else {
                                                _selectDatas!.add([i[0]]);
                                              }
                                            });
                                          },
                                        )
                                      : null,
                                );
                              }).toList(),
                            ),
                          ),
                          PluginTextTag(
                            padding: EdgeInsets.zero,
                            margin: EdgeInsets.only(left: 16, top: 15),
                            title: dic['up']!,
                          ),
                          Container(
                            color: Color(0xFFFFFFFF).withAlpha(25),
                            child: Column(
                              children: widget
                                  .plugin.store.gov.council.runnersUp!
                                  .map((i) {
                                final index = List.of(widget.plugin.store.gov
                                        .userCouncilVotes!['votes'])
                                    .indexWhere((element) {
                                  return element == i[0];
                                });
                                return CandidateItem(
                                  accInfo: widget.plugin.store.accounts
                                      .addressIndexMap[i[0]],
                                  icon: widget.plugin.store.accounts
                                      .addressIconsMap[i[0]],
                                  balance: i,
                                  tokenSymbol: symbol,
                                  decimals: decimals,
                                  isMyVote: index >= 0,
                                  isShowDivider: i !=
                                      widget.plugin.store.gov.council.runnersUp!
                                          .last,
                                  trailing: _select
                                      ? GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                left: 30,
                                                top: 15,
                                                right: 10,
                                                bottom: 15),
                                            child: PluginRadioButton(
                                              value: _selectDatas!.indexWhere(
                                                      (element) =>
                                                          element[0] == i[0]) >=
                                                  0,
                                            ),
                                          ),
                                          onTap: () {
                                            setState(() {
                                              if (_selectDatas!.indexWhere(
                                                      (element) =>
                                                          element[0] == i[0]) >=
                                                  0) {
                                                _selectDatas!.remove([i[0]]);
                                              } else {
                                                _selectDatas!.add([i[0]]);
                                              }
                                            });
                                          },
                                        )
                                      : null,
                                );
                              }).toList(),
                            ),
                          ),
                          PluginTextTag(
                            padding: EdgeInsets.zero,
                            margin: EdgeInsets.only(left: 16, top: 15),
                            title: dic['candidate']!,
                          ),
                          Container(
                            color: Color(0xFFFFFFFF).withAlpha(25),
                            child: widget.plugin.store.gov.council.candidates!
                                        .length >
                                    0
                                ? Column(
                                    children: widget
                                        .plugin.store.gov.council.candidates!
                                        .map((i) {
                                      final index = List.of(widget.plugin.store
                                              .gov.userCouncilVotes!['votes'])
                                          .indexWhere((element) {
                                        return element == i[0];
                                      });
                                      return CandidateItem(
                                        accInfo: widget.plugin.store.accounts
                                            .addressIndexMap[i],
                                        icon: widget.plugin.store.accounts
                                            .addressIconsMap[i],
                                        balance: [i],
                                        tokenSymbol: symbol,
                                        decimals: decimals,
                                        isMyVote: index >= 0,
                                        isShowDivider: i !=
                                            widget.plugin.store.gov.council
                                                .candidates!.last,
                                        trailing: _select
                                            ? GestureDetector(
                                                behavior:
                                                    HitTestBehavior.opaque,
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 30,
                                                      top: 15,
                                                      right: 10,
                                                      bottom: 15),
                                                  child: PluginRadioButton(
                                                    value: _selectDatas!
                                                            .indexWhere(
                                                                (element) =>
                                                                    element[
                                                                        0] ==
                                                                    i) >=
                                                        0,
                                                  ),
                                                ),
                                                onTap: () {
                                                  setState(() {
                                                    if (_selectDatas!
                                                            .indexWhere(
                                                                (element) =>
                                                                    element[
                                                                        0] ==
                                                                    i) >=
                                                        0) {
                                                      _selectDatas!.remove([i]);
                                                    } else {
                                                      _selectDatas!.add([i]);
                                                    }
                                                  });
                                                },
                                              )
                                            : null,
                                      );
                                    }).toList(),
                                  )
                                : Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Text(
                                      dic['candidate.empty']!,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                          ),
                        ],
                      )),
                      Visibility(
                        visible: _select,
                        child: Container(
                          color: Color(0xFFFFFFFF).withAlpha(25),
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 15),
                          child: PluginButton(
                            title: "${dic['vote']}(${_selectDatas!.length})",
                            onPressed: () async {
                              final res = await Navigator.of(context).pushNamed(
                                  CouncilVotePage.route,
                                  arguments: _selectDatas);
                              if (res != null) {
                                _refreshData();
                              }
                            },
                          ),
                        ),
                      )
                    ]));
        }));
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
    this.isMyVote = false,
    this.isShowDivider = true,
    this.trailing,
  });
  final Map? accInfo;
  // balance == [<candidate_address>, <0x_candidate_backing_amount>]
  final List? balance;
  final String? tokenSymbol;
  final int? decimals;
  final String? icon;
  final double? iconSize;
  final bool noTap;
  final Widget? trailing;
  final bool isMyVote;
  final bool isShowDivider;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          dense: true,
          leading: AddressIcon(balance![0], size: iconSize, svg: icon),
          title: isMyVote
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    UI.accountDisplayName(balance![0], accInfo,
                        expand: false,
                        style: Theme.of(context).textTheme.headline5?.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                    Container(
                      padding: EdgeInsets.only(left: 4),
                      child: Image.asset(
                        "packages/polkawallet_plugin_kusama/assets/images/gov/voted.png",
                        width: 24,
                      ),
                    )
                  ],
                )
              : UI.accountDisplayName(balance![0], accInfo,
                  style: Theme.of(context).textTheme.headline5?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w600)),
          subtitle: balance!.length == 1
              ? null
              : Text(
                  '${I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov')!['backing']}: ${Fmt.token(
                    BigInt.parse(balance![1].toString()),
                    decimals!,
                    length: 0,
                  )} $tokenSymbol',
                  style: Theme.of(context).textTheme.headline5?.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w300)),
          onTap: noTap
              ? null
              : () => Navigator.of(context).pushNamed(CandidateDetailPage.route,
                  arguments:
                      balance!.length == 1 ? ([balance![0], '0x0']) : balance),
          trailing: trailing,
        ),
        Visibility(
            visible: isShowDivider,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(height: 1),
            ))
      ],
    );
  }
}
