import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_kusama/pages/gov2/referendumPanelV2.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_sdk/api/types/gov/genExternalLinksParams.dart';
import 'package:polkawallet_sdk/api/types/gov/referendumV2Data.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_ui/components/v3/plugin/govExternalLinks.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginPopLoadingWidget.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginScaffold.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginTabCard.dart';

class Gov2Page extends StatefulWidget {
  Gov2Page(this.plugin, this.keyring, {Key? key}) : super(key: key);
  final PluginKusama plugin;
  final Keyring keyring;

  static const String route = '/gov2/index';

  @override
  State<Gov2Page> createState() => _Gov2PageState();
}

class _Gov2PageState extends State<Gov2Page> {
  final Map<String, List> _links = {};

  Future<void> _loadData() async {
    final list = await widget.plugin.service.gov.updateReferendumV2();
    _getExternalLinks(list);
    widget.plugin.service.gov.getReferendumVoteConvictions();
  }

  Future<List?> _getExternalLinks(List<ReferendumGroup> groups) async {
    final allIds = [];
    groups.forEach((g) {
      allIds.addAll(g.referenda.map((e) => e.key));
    });

    final List? res = await Future.wait(allIds.map((id) => widget
        .plugin.sdk.api.gov
        .getExternalLinks(GenExternalLinksParams.fromJson(
            {'data': id, 'type': 'referenda'}))));
    if (res != null) {
      setState(() {
        _links.addAll(res.asMap().map((k, v) => MapEntry(allIds[k], v)));
      });
    }
    return res;
  }

  @override
  void initState() {
    super.initState();
    if (widget.plugin.sdk.api.connectedNode != null) {
      widget.plugin.service.gov.subscribeBestNumber();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
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
          final groups = widget.plugin.store.gov.referendumsV2;
          final bestNumber = widget.plugin.store.gov.bestNumber;
          return groups == null
              ? PluginPopLoadingContainer(loading: true)
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: groups.length,
                  itemBuilder: (_, i) {
                    final referendums = groups[i].referenda;
                    return Column(
                      children: [
                        PluginTabCard(
                          [
                            'Track ${groups[i].trackName}',
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
                                  blockDuration: int.parse(widget.plugin
                                      .networkConst['babe']['expectedBlockTime']
                                      .toString()),
                                  links: Visibility(
                                    visible: _links[e.key] != null,
                                    child:
                                        GovExternalLinks(_links[e.key] ?? []),
                                  ),
                                ))
                            .toList()
                      ],
                    );
                  });
        },
      ),
    );
  }
}
