import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:polkawallet_plugin_kusama/pages/governance/democracy/referendumPanel.dart';
import 'package:polkawallet_plugin_kusama/pages/governance/govExternalLinks.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/api/types/gov/genExternalLinksParams.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/listTail.dart';
import 'package:polkawallet_ui/components/outlinedButtonSmall.dart';
import 'package:polkawallet_ui/components/roundedCard.dart';
import 'package:polkawallet_ui/components/txButton.dart';
import 'package:polkawallet_ui/pages/txConfirmPage.dart';

class Democracy extends StatefulWidget {
  Democracy(this.plugin, this.keyring);

  final PluginKusama plugin;
  final Keyring keyring;

  @override
  _DemocracyState createState() => _DemocracyState();
}

class _DemocracyState extends State<Democracy> {
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      new GlobalKey<RefreshIndicatorState>();

  final Map<BigInt?, List> _links = {};

  List _unlocks = [];

  Future<void> _queryDemocracyUnlocks() async {
    final List? unlocks = await widget.plugin.sdk.api.gov
        .getDemocracyUnlocks(widget.keyring.current.address!);
    if (mounted && unlocks != null) {
      setState(() {
        _unlocks = unlocks;
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
    if (widget.plugin.sdk.api.connectedNode == null) {
      return;
    }
    widget.plugin.service!.gov.getReferendumVoteConvictions();
    await widget.plugin.service!.gov.queryReferendums();

    _queryDemocracyUnlocks();
  }

  Future<void> _submitCancelVote(int id) async {
    final govDic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov')!;
    final params = TxConfirmParams(
      module: 'democracy',
      call: 'removeVote',
      txTitle: govDic['vote.remove'],
      txDisplay: {"id": id},
      params: [id],
    );
    final res = await Navigator.of(context)
        .pushNamed(TxConfirmPage.route, arguments: params);
    if (res != null) {
      _refreshKey.currentState!.show();
    }
  }

  void _onUnlock() async {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov')!;
    final txs = _unlocks
        .map(
            (e) => 'api.tx.democracy.removeVote(${BigInt.parse(e.toString())})')
        .toList();
    txs.add('api.tx.democracy.unlock("${widget.keyring.current.address}")');
    final res = await Navigator.of(context).pushNamed(TxConfirmPage.route,
        arguments: TxConfirmParams(
          txTitle: dic['democracy.unlock'],
          module: 'utility',
          call: 'batch',
          txDisplay: {
            "actions": ['democracy.removeVote', 'democracy.unlock'],
          },
          params: [],
          rawParams: '[[${txs.join(',')}]]',
        ));
    if (res != null) {
      _refreshKey.currentState!.show();
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.plugin.sdk.api.connectedNode != null) {
      widget.plugin.service!.gov.subscribeBestNumber();
    }

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _refreshKey.currentState!.show();
    });
  }

  @override
  void dispose() {
    widget.plugin.service!.gov.unsubscribeBestNumber();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov');
    return GetBuilder(
      init: widget.plugin.store,
      builder: (_) {
        final decimals = widget.plugin.networkState.tokenDecimals![0];
        final symbol = widget.plugin.networkState.tokenSymbol![0];
        final list = widget.plugin.store!.gov.referendums!;
        final bestNumber = widget.plugin.store!.gov.bestNumber;

        final count = list.length;
        return RefreshIndicator(
          key: _refreshKey,
          onRefresh: _fetchReferendums,
          child: ListView.builder(
            itemCount: list.length + 2,
            itemBuilder: (BuildContext context, int i) {
              if (i == 0) {
                return _unlocks.length > 0
                    ? RoundedCard(
                        margin: EdgeInsets.fromLTRB(16, 8, 16, 0),
                        padding: EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(dic!['democracy.expire']!),
                            OutlinedButtonSmall(
                              active: true,
                              content: dic['democracy.unlock'],
                              onPressed: _onUnlock,
                              margin: EdgeInsets.all(0),
                            )
                          ],
                        ),
                      )
                    : Container();
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
                        isLoading: false,
                      )),
                    )
                  : ReferendumPanel(
                      data: list[i - 1],
                      bestNumber: bestNumber,
                      symbol: symbol,
                      decimals: decimals,
                      blockDuration: BigInt.parse(widget
                              .plugin.networkConst['babe']['expectedBlockTime']
                              .toString())
                          .toInt(),
                      onCancelVote: _submitCancelVote,
                      links: FutureBuilder(
                        future: _getExternalLinks(list[i - 1].index),
                        builder: (_, AsyncSnapshot snapshot) {
                          if (snapshot.hasData) {
                            return GovExternalLinks(snapshot.data);
                          }
                          return Container();
                        },
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
}
