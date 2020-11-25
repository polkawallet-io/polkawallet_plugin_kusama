import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_kusama/pages/governance/democracy/referendumPanel.dart';
import 'package:polkawallet_plugin_kusama/pages/governance/govExternalLinks.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/api/types/gov/genExternalLinksParams.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/listTail.dart';
import 'package:polkawallet_ui/components/txButton.dart';
import 'package:polkawallet_ui/pages/txConfirmPage.dart';

class Democracy extends StatefulWidget {
  Democracy(this.plugin);

  final PluginKusama plugin;
  @override
  _DemocracyState createState() => _DemocracyState();
}

class _DemocracyState extends State<Democracy> {
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      new GlobalKey<RefreshIndicatorState>();

  final Map<int, List> _links = {};

  Future<List> _getExternalLinks(int id) async {
    if (_links[id] != null) return _links[id];

    final List res = await widget.plugin.sdk.api.gov.getExternalLinks(
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
    widget.plugin.service.gov.getReferendumVoteConvictions();
    await widget.plugin.service.gov.queryReferendums();
  }

  Future<void> _submitCancelVote(int id) async {
    final govDic = I18n.of(context).getDic(i18n_full_dic_kusama, 'gov');
    final params = TxConfirmParams(
      module: 'democracy',
      call: 'removeVote',
      txTitle: govDic['vote.remove'],
      txDisplay: {"id": id},
      params: [id],
    );
    final res = await Navigator.of(context)
        .pushNamed(TxConfirmPage.route, arguments: params);
    if (res ?? false) {
      _refreshKey.currentState.show();
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.plugin.sdk.api.connectedNode != null) {
      widget.plugin.service.gov.subscribeBestNumber();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshKey.currentState.show();
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
        final decimals = widget.plugin.networkState.tokenDecimals;
        final symbol = widget.plugin.networkState.tokenSymbol;
        final list = widget.plugin.store.gov.referendums;
        final bestNumber = widget.plugin.store.gov.bestNumber;
        return RefreshIndicator(
          key: _refreshKey,
          onRefresh: _fetchReferendums,
          child: list == null || list.length == 0
              ? Center(child: ListTail(isEmpty: true, isLoading: false))
              : ListView.builder(
                  itemCount: list.length + 1,
                  itemBuilder: (BuildContext context, int i) {
                    return i == list.length
                        ? Center(
                            child: ListTail(
                            isEmpty: false,
                            isLoading: false,
                          ))
                        : ReferendumPanel(
                            data: list[i],
                            bestNumber: bestNumber,
                            symbol: symbol,
                            decimals: decimals,
                            blockDuration: widget.plugin.networkConst['babe']
                                ['expectedBlockTime'],
                            onCancelVote: _submitCancelVote,
                            links: FutureBuilder(
                              future: _getExternalLinks(list[i].index),
                              builder: (_, AsyncSnapshot snapshot) {
                                if (snapshot.hasData) {
                                  return GovExternalLinks(snapshot.data);
                                }
                                return Container();
                              },
                            ));
                  },
                ),
        );
      },
    );
  }
}
