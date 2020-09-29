import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_kusama_example/pages/selectListPage.dart';
import 'package:polkawallet_sdk/api/types/networkParams.dart';
import 'package:polkawallet_sdk/plugin/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';

class AssetsContent extends StatefulWidget {
  AssetsContent(
    this.network,
    this.keyring,
    this.plugins,
    this.connectedNode,
    this.setNetwork,
    this.setConnectedNode,
  );
  final PolkawalletPlugin network;
  final Keyring keyring;
  final List<PolkawalletPlugin> plugins;
  final NetworkParams connectedNode;
  final Function(PolkawalletPlugin) setNetwork;
  final Function(NetworkParams) setConnectedNode;
  @override
  _AssetsContentState createState() => _AssetsContentState();
}

class _AssetsContentState extends State<AssetsContent> {
  Future<void> _onChangeNetwork() async {
    final selected = await Navigator.of(context).pushNamed(SelectListPage.route,
        arguments: widget.plugins
            .map((e) => ListItemData(title: e.name, subtitle: ''))
            .toList());
    if (selected != null) {
      final net = widget.plugins[selected];
      if (net.name != widget.network.name) {
        if (widget.connectedNode != null) {
          widget.setConnectedNode(null);
        }
        widget.setNetwork(net);

        /// we reuse the existing webView instance when we start a new plugin.
        final res = await net.start(widget.keyring,
            webView: widget.network.sdk.webView);
        widget.setConnectedNode(res);
      }
    }
  }

  Future<void> _onChangeNode() async {
    final selected = await Navigator.of(context).pushNamed(SelectListPage.route,
        arguments: widget.network.nodeList
            .map((e) => ListItemData(title: e.name, subtitle: e.endpoint))
            .toList());
    if (selected != null) {
      if (widget.connectedNode != null) {
        widget.setConnectedNode(null);
      }
      final node = widget.network.nodeList[selected];
      final res =
          await widget.network.sdk.api.connectNode(widget.keyring, node);
      widget.setConnectedNode(res);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: Text('change network'),
          subtitle: Text(widget.network.name),
          trailing: Icon(Icons.arrow_forward_ios, size: 18),
          onTap: () => _onChangeNetwork(),
        ),
        Divider(),
        ListTile(
          title: Text('change node'),
          subtitle: Text(widget.connectedNode?.name ?? 'connecting...'),
          trailing: Icon(Icons.arrow_forward_ios, size: 18),
          onTap: () => _onChangeNode(),
        ),
        Divider(),
        Text('assets content'),
      ],
    );
  }
}
