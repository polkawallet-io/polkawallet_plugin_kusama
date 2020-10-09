import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_kusama_example/pages/selectListPage.dart';
import 'package:polkawallet_sdk/api/types/networkParams.dart';
import 'package:polkawallet_sdk/api/types/networkStateData.dart';
import 'package:polkawallet_sdk/api/apiKeyring.dart';
import 'package:polkawallet_sdk/plugin/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';

class ProfileContent extends StatefulWidget {
  ProfileContent(
    this.network,
    this.keyring,
    this.plugins,
    this.connectedNode,
    this.networkState,
    this.setNetwork,
    this.setConnectedNode,
  );
  final PolkawalletPlugin network;
  final Keyring keyring;
  final List<PolkawalletPlugin> plugins;
  final NetworkParams connectedNode;
  final NetworkStateData networkState;
  final Function(PolkawalletPlugin) setNetwork;
  final Function(NetworkParams) setConnectedNode;
  @override
  _ProfileContentState createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  bool _loading = false;

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
        widget.keyring.setSS58(res.ss58);
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

  Future<void> _removeAccount() async {
    if (widget.keyring.keyPairs.length > 0) {
      setState(() {
        _loading = true;
      });
      await widget.keyring.store
          .deleteAccount(widget.keyring.keyPairs[0].pubKey);
      setState(() {
        _loading = false;
      });

      widget.network.sdk.api.account.unsubscribeBalance();
    }
  }

  Future<void> _importAccount() async {
    if (widget.keyring.keyPairs.length == 0) {
      setState(() {
        _loading = true;
      });
      final KeyPairData acc =
          await widget.network.sdk.api.keyring.importAccount(
        widget.keyring,
        keyType: KeyType.mnemonic,
        key:
            'wing know chapter eight shed lens mandate lake twenty useless bless glory',
        name: 'testName01',
        password: 'a123456',
      );
      setState(() {
        _loading = false;
      });

      widget.network.subscribeBalances(acc);
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
        Column(
          children: [
            Text('network state'),
            Text('tokenSymbol: ${widget.networkState.tokenSymbol}'),
            Text('tokenDecimals: ${widget.networkState.tokenDecimals}'),
          ],
        ),
        Divider(),
        Column(
          children: [
            Text('keyPairs:'),
            Text(widget.keyring.keyPairs
                .map((e) => e.address)
                .toList()
                .join(',')),
            RaisedButton(
              child: Text(widget.keyring.keyPairs.length > 0
                  ? 'Remove Account'
                  : 'Import Account'),
              onPressed: _loading
                  ? null
                  : widget.keyring.keyPairs.length > 0
                      ? () => _removeAccount()
                      : () => _importAccount(),
            )
          ],
        ),
      ],
    );
  }
}
