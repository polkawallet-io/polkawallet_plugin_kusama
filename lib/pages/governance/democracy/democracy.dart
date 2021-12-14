import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_kusama/pages/governance/democracy/referendumPanel.dart';
import 'package:polkawallet_plugin_kusama/pages/governance/govExternalLinks.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/api/types/gov/genExternalLinksParams.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/listTail.dart';
import 'package:polkawallet_ui/components/outlinedButtonSmall.dart';
import 'package:polkawallet_ui/components/v3/roundedCard.dart';
import 'package:polkawallet_ui/components/txButton.dart';
import 'package:polkawallet_ui/pages/v3/txConfirmPage.dart';
import 'package:polkawallet_ui/utils/format.dart';

class Democracy extends StatefulWidget {
  Democracy(this.plugin, this.keyring);

  final PluginKusama plugin;
  final Keyring keyring;

  @override
  _DemocracyState createState() => _DemocracyState();
}

class _DemocracyState extends State<Democracy> {
  bool isLoading = false;
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      new GlobalKey<RefreshIndicatorState>();

  final Map<BigInt?, List> _links = {};

  List _locks = [];

  Future<void> _queryDemocracyLocks() async {
    final List? locks = await widget.plugin.sdk.api.gov
        .getDemocracyLocks(widget.keyring.current.address!);
    if (mounted && locks != null) {
      setState(() {
        _locks = locks;
      });
    }
  }

  Future<List?> _getExternalLinks(BigInt? id) async {
    if (_links[id] != null) return _links[id];

    final List? res = await widget.plugin.sdk.api.gov.getExternalLinks(
      GenExternalLinksParams.fromJson(
          {'data': id.toString(), 'type': 'referendum'}),
    );
    if (res != null) {
      setState(() {
        _links[id] = res;
      });
    }
    return res;
  }

  Future<void> _fetchReferendums() async {
    setState(() {
      isLoading = true;
    });

    if (widget.plugin.sdk.api.connectedNode == null) {
      return;
    }
    widget.plugin.service.gov.getReferendumVoteConvictions();
    final ls = await widget.plugin.service.gov.queryReferendums();
    ls.forEach((e) {
      _getExternalLinks(e.index);
    });

    _queryDemocracyLocks();
    setState(() {
      isLoading = false;
    });
  }

  void _submitCancelVote(int id) {
    final govDic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov')!;
    _unlockTx(govDic['vote.remove'], ["$id"]);
  }

  void _onUnlock(List<String> ids) {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov')!;
    _unlockTx(dic['democracy.unlock'], ids);
  }

  void _unlockTx(String? txTitle, List<String> ids) async {
    final txs = ids
        .map((e) => 'api.tx.democracy.removeVote(${BigInt.parse(e)})')
        .toList();
    txs.add('api.tx.democracy.unlock("${widget.keyring.current.address}")');
    final params = TxConfirmParams(
      txTitle: txTitle,
      module: 'utility',
      call: 'batch',
      txDisplay: {
        "actions": ['democracy.removeVote', 'democracy.unlock'],
      },
      params: [],
      rawParams: '[[${txs.join(',')}]]',
    );
    final res = await Navigator.of(context)
        .pushNamed(TxConfirmPage.route, arguments: params);
    if (res != null) {
      _refreshKey.currentState!.show();
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.plugin.sdk.api.connectedNode != null) {
      widget.plugin.service.gov.subscribeBestNumber();
    }

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _refreshKey.currentState!.show();
    });
  }

  @override
  void dispose() {
    widget.plugin.service.gov.unsubscribeBestNumber();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final decimals = widget.plugin.networkState.tokenDecimals![0];
        final symbol = widget.plugin.networkState.tokenSymbol![0];
        final list = widget.plugin.store.gov.referendums!;
        final bestNumber = widget.plugin.store.gov.bestNumber;

        final count = list.length;
        return RefreshIndicator(
          key: _refreshKey,
          onRefresh: _fetchReferendums,
          child: ListView.builder(
            itemCount: list.length + 2,
            itemBuilder: (BuildContext context, int i) {
              if (i == 0) {
                return buildHeaderView(_locks);
                // return Visibility(
                //     visible: _unlocks.length > 0,
                //     child: RoundedCard(
                //       margin: EdgeInsets.fromLTRB(16, 8, 16, 0),
                //       padding: EdgeInsets.all(16),
                //       child: Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: [
                //           Text(dic!['democracy.expire']!),
                //           OutlinedButtonSmall(
                //             active: true,
                //             content: dic['democracy.unlock'],
                //             onPressed: _onUnlock,
                //             margin: EdgeInsets.all(0),
                //           )
                //         ],
                //       ),
                //     ));
              }
              bool isLock = false;
              if (_locks.length > 0 && list.length > 0 && i < list.length + 1) {
                _locks.forEach((element) {
                  if (BigInt.parse(element['referendumId']) ==
                      list[i - 1].index) {
                    isLock = true;
                  }
                });
              }
              return i == list.length + 1
                  ? Container(
                      margin: EdgeInsets.only(
                          top: count == 0
                              ? MediaQuery.of(context).size.width / 2
                              : 0),
                      child: Center(
                          child: ListTail(
                        isEmpty: count == 0,
                        isLoading: isLoading,
                        isShowLoadText: true,
                      )),
                    )
                  : ReferendumPanel(
                      data: list[i - 1],
                      isLock: isLock,
                      bestNumber: bestNumber,
                      symbol: symbol,
                      decimals: decimals,
                      blockDuration: BigInt.parse(widget
                              .plugin.networkConst['babe']['expectedBlockTime']
                              .toString())
                          .toInt(),
                      onCancelVote: _submitCancelVote,
                      links: Visibility(
                        visible: _links[list[i - 1].index] != null,
                        child:
                            GovExternalLinks(_links[list[i - 1].index] ?? []),
                      ),
                      onRefresh: () {
                        _refreshKey.currentState!.show();
                      },
                    );
            },
          ),
        );
      },
    );
  }

  Widget buildHeaderView(List<dynamic> locks) {
    if (locks.length == 0) {
      return Container();
    }
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov')!;
    final bestNumber = widget.plugin.store.gov.bestNumber;
    final decimals = widget.plugin.networkState.tokenDecimals![0];
    final symbol = widget.plugin.networkState.tokenSymbol![0];
    double maxLockAmount = 0, maxUnlockAmount = 0;
    final List<String> unLockIds = [];
    for (int index = 0; index < locks.length; index++) {
      var unlockAt = locks[index]['unlockAt'];
      final amount = double.parse(Fmt.balance(
        locks[index]!['balance'].toString(),
        decimals,
      ));
      if (unlockAt != "0") {
        BigInt endLeft;
        try {
          endLeft = BigInt.parse("${unlockAt.toString()}") - bestNumber;
        } catch (e) {
          endLeft = BigInt.parse("0x${unlockAt.toString()}") - bestNumber;
        }
        if (endLeft.toInt() <= 0) {
          unLockIds.add(locks[index]!['referendumId']);
          if (amount > maxUnlockAmount) {
            maxUnlockAmount = amount;
          }
          continue;
        }
      }
      if (amount > maxLockAmount) {
        maxLockAmount = amount;
      }
    }
    final redeemable = maxUnlockAmount - maxLockAmount;
    return RoundedCard(
      margin: EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
              margin: EdgeInsets.only(bottom: 5),
              child: Row(
                children: [
                  Expanded(
                      child: Center(
                          child: Text(dic['democracy.referendum.number']!))),
                  Expanded(
                      child: Center(
                          child: Text(dic['democracy.referendum.balance']!))),
                  Expanded(
                      child: Center(
                          child: Text(dic['democracy.referendum.period']!)))
                ],
              )),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: locks.length,
            itemBuilder: (context, index) {
              var unlockAt = locks[index]['unlockAt'];
              final int blockDuration = BigInt.parse(widget
                      .plugin.networkConst['babe']['expectedBlockTime']
                      .toString())
                  .toInt();
              if (unlockAt == "0") {
                widget.plugin.store.gov.referendums!.forEach((element) {
                  if (element.userVoted != null &&
                      element.index ==
                          BigInt.parse(locks[index]['referendumId'])) {
                    unlockAt = element.status!['end'];
                    if (element.userVoted!['vote']['conviction'] != 'None') {
                      final String conviction =
                          (element.userVoted!['vote']['conviction'] as String)
                              .substring(6, 7);
                      final con = widget.plugin.store.gov.voteConvictions!
                          .where((element) =>
                              element['value'] == int.parse(conviction))
                          .first["period"];
                      unlockAt =
                          unlockAt + double.parse(con).toInt() * 24 * 600;
                    }
                  }
                });
              }
              var endLeft;
              try {
                endLeft = BigInt.parse("${unlockAt.toString()}") - bestNumber;
              } catch (e) {
                endLeft = BigInt.parse("0x${unlockAt.toString()}") - bestNumber;
              }
              String amount = Fmt.balance(
                locks[index]!['balance'].toString(),
                decimals,
              );

              return Container(
                margin: EdgeInsets.only(top: 5),
                child: Row(
                  children: [
                    Expanded(
                        child: Center(
                      child: Text("#${int.parse(locks[index]['referendumId'])}",
                          style: Theme.of(context).textTheme.headline4),
                    )),
                    Expanded(
                        child: Center(
                      child: Text('$amount $symbol'),
                    )),
                    Expanded(
                      child: Center(
                          child: Text(
                              endLeft.toInt() <= 0
                                  ? ""
                                  : '${Fmt.blockToTime(endLeft.toInt(), blockDuration)}',
                              style: TextStyle(color: Colors.grey))),
                    ),
                  ],
                ),
              );
            },
          ),
          Visibility(
              visible: redeemable > 0,
              child: Column(
                children: [
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          '${dic['democracy.unlock']}:${Fmt.priceFloor(redeemable, lengthMax: 4)} $symbol'),
                      OutlinedButtonSmall(
                        content: dic['democracy.referendum.clear']!,
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        active: true,
                        onPressed: () {
                          _onUnlock(unLockIds);
                        },
                      ),
                    ],
                  )
                ],
              ))
        ],
      ),
    );
  }
}
