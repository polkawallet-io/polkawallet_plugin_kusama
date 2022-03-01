import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_kusama/pages/governanceNew/councilPage.dart';
import 'package:polkawallet_plugin_kusama/pages/stakingNew/stakingView.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/outlinedButtonSmall.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginScaffold.dart';
import 'package:polkawallet_ui/pages/dAppWrapperPage.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginTabCard.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginTxButton.dart';
import 'package:polkawallet_ui/components/v3/roundedCard.dart';
import 'package:polkawallet_ui/pages/v3/txConfirmPage.dart';
import 'package:polkawallet_ui/utils/format.dart';

class GovernancePage extends StatefulWidget {
  GovernancePage(this.plugin, this.keyring, {Key? key}) : super(key: key);
  final PluginKusama plugin;
  final Keyring keyring;

  static const String route = '/gov/governance';

  @override
  State<GovernancePage> createState() => _GovernancePageState();
}

class _GovernancePageState extends State<GovernancePage> {
  List _locks = [];
  int _tabIndex = 0;
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      new GlobalKey<RefreshIndicatorState>();

  Future<void> _queryDemocracyLocks() async {
    final List? locks = await widget.plugin.sdk.api.gov
        .getDemocracyLocks(widget.keyring.current.address!);
    if (mounted && locks != null) {
      setState(() {
        _locks = locks;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _refreshKey.currentState!.show();
    });
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
      isPlugin: true,
    );
    final res = await Navigator.of(context)
        .pushNamed(TxConfirmPage.route, arguments: params);
    if (res != null) {
      _refreshKey.currentState!.show();
    }
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
      final amount = Fmt.balanceDouble(
        locks[index]!['balance'].toString(),
        decimals,
      );
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

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov')!;
    return PluginScaffold(
      appBar: PluginAppBar(
        title: Text(I18n.of(context)!
            .getDic(i18n_full_dic_kusama, 'common')!['governance']!),
      ),
      body: Observer(builder: (_) {
        return RefreshIndicator(
            key: _refreshKey,
            onRefresh: _queryDemocracyLocks,
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.all(16),
              itemCount: 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return buildHeaderView(_locks);
                }
                return StickyHeader(
                    header: Container(
                        color: Color.fromARGB(255, 37, 39, 44),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GridView.count(
                              crossAxisSpacing: 25,
                              mainAxisSpacing: 12,
                              crossAxisCount: 3,
                              childAspectRatio: 103 / 64,
                              padding: EdgeInsets.only(top: 20, bottom: 16),
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              children: [
                                GridViewItemBtn(
                                  Image.asset(
                                    'packages/polkawallet_plugin_kusama/assets/images/gov/gov_council.png',
                                    width: 36,
                                  ),
                                  dic['council']!,
                                  onTap: () => Navigator.of(context)
                                      .pushNamed(CouncilPage.route),
                                ),
                                GridViewItemBtn(
                                    Image.asset(
                                      'packages/polkawallet_plugin_kusama/assets/images/gov/gov_treasury.png',
                                      width: 36,
                                    ),
                                    dic['treasury']!),
                                GridViewItemBtn(
                                  Image.asset(
                                    'packages/polkawallet_plugin_kusama/assets/images/gov/gov_polkassembly.png',
                                    width: 36,
                                  ),
                                  'Polkassembly',
                                  onTap: () => Navigator.of(context).pushNamed(
                                    DAppWrapperPage.route,
                                    arguments:
                                        'https://${widget.plugin.basic.name}.polkassembly.io/',
                                  ),
                                ),
                              ],
                            ),
                            PluginTabCard(
                              [
                                "${dic['referenda']}",
                                "${dic['democracy.proposal']}",
                                "Externals"
                              ],
                              (index) {
                                setState(() {
                                  _tabIndex = index;
                                });
                              },
                              _tabIndex,
                              margin: EdgeInsets.zero,
                            )
                          ],
                        )),
                    content: ListView.builder(
                        itemCount: 150,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Container(
                            height: 50,
                            child: Text('List tile #$index'),
                          );
                        }));
              },
            ));
      }),
    );
  }
}
