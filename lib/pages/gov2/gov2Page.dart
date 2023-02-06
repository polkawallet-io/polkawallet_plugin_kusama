import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_kusama/pages/gov2/referendumPanelV2.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
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
  Future<void> _loadData() async {
    widget.plugin.service.gov.updateReferendumV2();
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
                            groups[i].trackName,
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
