import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:polkawallet_plugin_kusama/pages/gov2/referendumPanelV2.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_sdk/api/types/gov/genExternalLinksParams.dart';
import 'package:polkawallet_sdk/api/types/gov/referendumV2Data.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_ui/components/txButton.dart';
import 'package:polkawallet_ui/components/v3/infoItemRow.dart';
import 'package:polkawallet_ui/components/v3/plugin/govExternalLinks.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginButton.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginPopLoadingWidget.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginScaffold.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginTabCard.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginTextTag.dart';
import 'package:polkawallet_ui/pages/txConfirmPage.dart';
import 'package:polkawallet_ui/utils/consts.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/index.dart';

class Gov2Page extends StatefulWidget {
  Gov2Page(this.plugin, this.keyring, {Key? key}) : super(key: key);
  final PluginKusama plugin;
  final Keyring keyring;

  static const String route = '/gov2/index';

  @override
  State<Gov2Page> createState() => _Gov2PageState();
}

class _Gov2PageState extends State<Gov2Page> {
  final _refreshKey = new GlobalKey<RefreshIndicatorState>();

  final Map<String, List> _links = {};

  Future<void> _loadData() async {
    final data = await widget.plugin.service.gov.updateReferendumV2();
    _getExternalLinks(data.ongoing);
  }

  Future<List?> _getExternalLinks(List<ReferendumGroup> groups) async {
    final allIds = [];
    groups.forEach((g) {
      allIds.addAll(g.referenda.map((e) => e.key));
    });

    final List? res = await Future.wait(allIds.map((id) => widget
        .plugin.sdk.api.gov2
        .getExternalLinks(GenExternalLinksParams.fromJson(
            {'data': id, 'type': 'referenda'}))));
    if (res != null) {
      setState(() {
        _links.addAll(res.asMap().map((k, v) => MapEntry(allIds[k], v)));
      });
    }
    return res;
  }

  void _onUnlock(List<ReferendumVote> list) {
    _unlockTx('Clear Locks', list);
  }

  void _submitCancelVote(ReferendumVote vote) {
    _unlockTx('Cancel Vote', [vote]);
  }

  void _unlockTx(String? txTitle, List<ReferendumVote> list) async {
    final txs = [];
    list.forEach((e) {
      txs.addAll([
        'api.tx.convictionVoting.removeVote("${e.trackId}", "${e.key}")',
        'api.tx.convictionVoting.unlock("${e.trackId}", {Id: "${widget.keyring.current.address}"})'
      ]);
    });

    final params = TxConfirmParams(
      txTitle: txTitle,
      module: 'utility',
      call: 'batch',
      txDisplay: {
        "actions": ['convictionVoting.removeVote', 'convictionVoting.unlock'],
      },
      params: [],
      rawParams: '[[${txs.join(',')}]]',
      isPlugin: true,
    );
    final res = await Navigator.of(context)
        .pushNamed(TxConfirmPage.route, arguments: params);
    if (res != null) {
      _refreshKey.currentState?.show();
    }
  }

  String? _getLockAmount(Map vote, int decimals) {
    if (vote['Standard'] != null) {
      return Fmt.priceCeilBigInt(
          Fmt.balanceInt(vote['Standard']['balance'].toString()), decimals,
          lengthMax: 4);
    }
    if (vote['Split'] != null) {
      return Fmt.priceCeilBigInt(
          Fmt.balanceInt(vote['Split']['aye'].toString()) +
              Fmt.balanceInt(vote['Split']['nay'].toString()),
          decimals,
          lengthMax: 4);
    }
    if (vote['SplitAbstain'] != null) {
      return Fmt.priceCeilBigInt(
          Fmt.balanceInt(vote['SplitAbstain']['abstain'].toString()) +
              Fmt.balanceInt(vote['SplitAbstain']['aye'].toString()) +
              Fmt.balanceInt(vote['SplitAbstain']['nay'].toString()),
          decimals,
          lengthMax: 4);
    }
    return null;
  }

  String _getLockAmountDisplay(Map vote, int decimals, String symbol) {
    final isStandard = vote['Standard'] != null;
    final data =
        vote['Standard'] ?? vote['Split'] ?? vote['SplitAbstain'] ?? {};
    bool isAmount(String key) {
      return isStandard ? key == 'balance' : true;
    }

    return (data as Map)
        .map((k, v) => MapEntry(k,
            '$k: ${isAmount(k) ? '${Fmt.priceCeilBigInt(Fmt.balanceInt(v.toString()), decimals, lengthMax: 4)} $symbol' : v.toString()}'))
        .values
        .join('\n');
  }

  Widget buildHeaderView(List<ReferendumVote> locks) {
    if (locks.length == 0) {
      return Container();
    }

    final blockDuration = BigInt.parse(
            widget.plugin.networkConst['babe']['expectedBlockTime'].toString())
        .toInt();
    final bestNumber = widget.plugin.store.gov.bestNumber;
    final decimals = widget.plugin.networkState.tokenDecimals![0];
    final symbol = widget.plugin.networkState.tokenSymbol![0];

    final List<ReferendumVote> redeemableList = [];
    double maxLockAmount = 0, stillLockedAmount = 0;
    for (int index = 0; index < locks.length; index++) {
      final amount = locks[index]
          .vote
          .values
          .toList()[0]
          .map((k, e) {
            return MapEntry(
                k,
                e.runtimeType == String
                    ? Fmt.balanceDouble(
                        e.toString(),
                        decimals,
                      )
                    : 0.0);
          })
          .values
          .reduce((v, e) => v + e);
      if (amount > maxLockAmount) {
        maxLockAmount = amount;
      }
      if (locks[index].isRedeemable) {
        redeemableList.add(locks[index]);
      } else {
        if (amount > stillLockedAmount) {
          stillLockedAmount = amount;
        }
      }
    }
    final redeemable = maxLockAmount - stillLockedAmount;

    final style =
        Theme.of(context).textTheme.headline5?.copyWith(color: Colors.white);
    return Column(
      children: [
        PluginTextTag(
          title: 'My Votes',
        ),
        Container(
            height: redeemable > 0 ? 147 : 127,
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
                color: PluginColorsDark.cardColor,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8))),
            child: Stack(
              children: [
                Container(
                    height: 127,
                    child: Swiper(
                      itemCount: locks.length,
                      itemWidth: double.infinity,
                      loop: false,
                      itemBuilder: (BuildContext context, int index) {
                        var unlockAt = locks[index].endBlock;
                        var endLeft;
                        try {
                          endLeft = BigInt.parse(unlockAt) - bestNumber;
                        } catch (e) {
                          endLeft = BigInt.parse("0x$unlockAt") - bestNumber;
                        }
                        final amount =
                            _getLockAmount(locks[index].vote, decimals);
                        return Container(
                            padding: EdgeInsets.only(
                                left: 17, top: 16, right: 16, bottom: 12),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          '#${locks[index].key}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayMedium
                                              ?.copyWith(
                                                  color: Colors.white,
                                                  fontSize: UI.getTextSize(
                                                      22, context),
                                                  fontWeight: FontWeight.bold),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(left: 8),
                                          child: Text(locks[index].status,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium
                                                  ?.copyWith(
                                                      color: Colors.white)),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                            child: Text('Voted', style: style)),
                                        GestureDetector(
                                          child: Icon(Icons.info_outline,
                                              color: PluginColorsDark.green,
                                              size: 16),
                                          onTap: () {
                                            showCupertinoModalPopup(
                                                context: context,
                                                builder: (_) {
                                                  return CupertinoActionSheet(
                                                    title: Text(
                                                        'Voted for #${locks[index].key}'),
                                                    message: Text(
                                                        _getLockAmountDisplay(
                                                            locks[index].vote,
                                                            decimals,
                                                            symbol)),
                                                    actions:
                                                        locks[index].isEnded ==
                                                                false
                                                            ? [
                                                                CupertinoActionSheetAction(
                                                                    isDestructiveAction:
                                                                        true,
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                      _submitCancelVote(
                                                                          locks[
                                                                              index]);
                                                                    },
                                                                    child: Text(
                                                                        'Cancel Vote')),
                                                                CupertinoActionSheetAction(
                                                                    onPressed: () =>
                                                                        Navigator.of(context)
                                                                            .pop(),
                                                                    child: Text(
                                                                        'OK')),
                                                              ]
                                                            : [
                                                                CupertinoActionSheetAction(
                                                                    onPressed: () =>
                                                                        Navigator.of(context)
                                                                            .pop(),
                                                                    child: Text(
                                                                        'OK'))
                                                              ],
                                                  );
                                                });
                                          },
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(left: 4),
                                          child: Text('$amount $symbol',
                                              style: style),
                                        ),
                                      ],
                                    ),
                                    InfoItemRow(
                                        'Locking End',
                                        endLeft < BigInt.zero
                                            ? 'Ended'
                                            : locks[index].isEnded
                                                ? '${Fmt.blockToTime(endLeft.toInt(), blockDuration)}'
                                                : locks[index].status,
                                        labelStyle: style,
                                        contentStyle: style),
                                  ],
                                )),
                                Container(width: 74)
                              ],
                            ));
                      },
                      pagination: SwiperPagination(
                          alignment: Alignment.topRight,
                          margin: EdgeInsets.only(top: 24, right: 16),
                          builder: SwiperCustomPagination(builder:
                              (BuildContext context,
                                  SwiperPluginConfig config) {
                            return CustomP(
                                config.activeIndex, config.itemCount);
                          })),
                    )),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                        padding: EdgeInsets.only(
                            left: 17, top: 16, right: 16, bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                                child: InfoItemRow('Redeemable',
                                    '${Fmt.priceFloor(redeemable, lengthMax: 4)} $symbol',
                                    labelStyle: style, contentStyle: style)),
                            redeemable > 0
                                ? Container(
                                    width: 74,
                                    height: double.infinity,
                                    padding: EdgeInsets.only(left: 15),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        PluginButton(
                                          height: 30,
                                          title: 'Clear',
                                          onPressed: () {
                                            _onUnlock(redeemableList);
                                          },
                                        )
                                      ],
                                    ))
                                : SizedBox(width: 74)
                          ],
                        )))
              ],
            ))
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.plugin.sdk.api.connectedNode != null) {
      widget.plugin.service.gov.subscribeBestNumber();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.plugin.service.gov.getReferendumVoteConvictionsV2();

      _loadData();
    });
  }

  @override
  void dispose() {
    widget.plugin.service.gov.unsubscribeBestNumber();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nativeToken = widget.plugin.networkState.tokenSymbol![0];
    final decimals = widget.plugin.networkState.tokenDecimals![0];
    return PluginScaffold(
      appBar: PluginAppBar(title: Text('Referenda')),
      body: Observer(
        builder: (_) {
          final data = widget.plugin.store.gov.referendumsV2;
          final bestNumber = widget.plugin.store.gov.bestNumber;
          return data == null
              ? PluginPopLoadingContainer(loading: true)
              : RefreshIndicator(
                  key: _refreshKey,
                  child: ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: data.ongoing.length + 1,
                      itemBuilder: (_, index) {
                        if (index == 0) {
                          return buildHeaderView(data.userVotes);
                        }
                        final i = index - 1;
                        final referendums = data.ongoing[i].referenda;
                        return Column(
                          children: [
                            PluginTabCard(
                              [
                                'Track ${data.ongoing[i].trackName}',
                              ],
                              (_) => null,
                              0,
                              margin: EdgeInsets.zero,
                            ),
                            ...referendums
                                .map((e) => ReferendumPanelV2(
                                    symbol: nativeToken,
                                    decimals: decimals,
                                    data: e,
                                    bestNumber: bestNumber,
                                    blockDuration: int.parse(widget
                                        .plugin
                                        .networkConst['babe']
                                            ['expectedBlockTime']
                                        .toString()),
                                    links: Visibility(
                                      visible: _links[e.key] != null,
                                      child:
                                          GovExternalLinks(_links[e.key] ?? []),
                                    ),
                                    onRefresh: () =>
                                        _refreshKey.currentState?.show()))
                                .toList()
                          ],
                        );
                      }),
                  onRefresh: _loadData);
        },
      ),
    );
  }
}

class CustomP extends StatelessWidget {
  var _currentIndex;
  var _count;
  CustomP(this._currentIndex, this._count);
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 8,
        child: _count == 1
            ? Container()
            : ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) => Container(
                  width: 6,
                ),
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    height: 8,
                    width: _currentIndex == index ? 15 : 8,
                    decoration: BoxDecoration(
                        color: _currentIndex == index
                            ? PluginColorsDark.primary
                            : PluginColorsDark.headline1,
                        borderRadius: BorderRadius.circular(4)),
                  );
                },
                itemCount: _count,
              ));
  }
}
