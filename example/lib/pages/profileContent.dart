import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_kusama_example/pages/selectListPage.dart';
import 'package:polkawallet_plugin_kusama_example/utils/i18n.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_sdk/api/types/networkParams.dart';
import 'package:polkawallet_sdk/api/apiKeyring.dart';
import 'package:polkawallet_sdk/plugin/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';
import 'package:polkawallet_ui/components/roundedButton.dart';

class ProfileContent extends StatefulWidget {
  ProfileContent(
    this.network,
    this.keyring,
    this.locale,
    this.plugins,
    this.connectedNode,
    this.setNetwork,
    this.setConnectedNode,
    this.changeLang,
  );
  final PolkawalletPlugin network;
  final Keyring keyring;
  final Locale locale;
  final List<PolkawalletPlugin> plugins;
  final NetworkParams connectedNode;
  final Function(PolkawalletPlugin) setNetwork;
  final Function(NetworkParams) setConnectedNode;
  final Function(String) changeLang;
  @override
  _ProfileContentState createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  bool _loading = false;

  final _langOptions = [null, 'en', 'zh'];
  int _langSelected;

  String _getLang(String code) {
    final dic = I18n.of(context).getDic(i18n_full_dic, 'profile');
    switch (code) {
      case 'zh':
        return '简体中文';
      case 'en':
        return 'English';
      default:
        return dic['setting.lang.auto'];
    }
  }

  void _onChangeLang() {
    final langCurrent = widget.locale.toString();
    print('current: $langCurrent');
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: MediaQuery.of(context).copyWith().size.height / 3,
        child: WillPopScope(
          child: CupertinoPicker(
            backgroundColor: Colors.white,
            itemExtent: 58,
            scrollController: FixedExtentScrollController(
                initialItem: _langOptions.indexOf(langCurrent)),
            children: _langOptions.map((i) {
              return Padding(
                  padding: EdgeInsets.all(16), child: Text(_getLang(i)));
            }).toList(),
            onSelectedItemChanged: (v) {
              setState(() {
                _langSelected = v;
              });
            },
          ),
          onWillPop: () async {
            print(_langSelected);
            if (_langSelected == null) return true;
            String code = _langOptions[_langSelected];
            if (code != langCurrent) {
              widget.changeLang(code);
            }
            return true;
          },
        ),
      ),
    );
  }

  Future<void> _onChangeNetwork() async {
    final selected = await Navigator.of(context).pushNamed(SelectListPage.route,
        arguments: widget.plugins
            .map((e) => ListItemData(title: e.basic.name, subtitle: ''))
            .toList());
    if (selected != null) {
      final net = widget.plugins[selected];
      if (net.basic.name != widget.network.basic.name) {
        if (widget.connectedNode != null) {
          widget.setConnectedNode(null);
        }
        widget.setNetwork(net);

        /// we reuse the existing webView instance when we start a new plugin.
        await net.beforeStart(widget.keyring,
            webView: widget.network.sdk.webView);
        final res = await net.start(widget.keyring);
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
          await widget.network.sdk.api.connectNode(widget.keyring, [node]);
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
      final json = await widget.network.sdk.api.keyring.importAccount(
        widget.keyring,
        keyType: KeyType.mnemonic,
        key:
            // 'wing know chapter eight shed lens mandate lake twenty useless bless glory',
            'second throw patch mix leaf call scare surface enlist pet exhibit hammer',
        name: 'testName01',
        password: 'a123456',
      );
      final acc = await widget.network.sdk.api.keyring.addAccount(
        widget.keyring,
        keyType: KeyType.mnemonic,
        acc: json,
        password: 'a123456',
      );
      setState(() {
        _loading = false;
      });

      widget.network.changeAccount(acc);
    }
  }

  Future<void> _removeExternal() async {
    if (widget.keyring.externals.length > 0) {
      setState(() {
        _loading = true;
      });
      await widget.keyring.store
          .deleteAccount(widget.keyring.externals[0].pubKey);
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _importExternal() async {
    if (widget.keyring.externals.length == 0) {
      setState(() {
        _loading = true;
      });
      final KeyPairData acc =
          await widget.network.sdk.api.keyring.addContact(widget.keyring, {
        'name': 'external_test',
        'address': '14fpQHev6kcQxiW49e5Cg4VgY8QeKwLxwfbAHg81ro8r8AnD',
        'observation': true,
      });
      setState(() {
        _loading = false;
      });

      widget.network.changeAccount(acc);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: Text('change lang'),
          subtitle: Text(_getLang(widget.locale.toString())),
          trailing: Icon(Icons.arrow_forward_ios, size: 18),
          onTap: () => _onChangeLang(),
        ),
        Divider(),
        ListTile(
          title: Text('change network'),
          subtitle: Text(widget.network.basic.name),
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
            Text('tokenSymbol: ${widget.network.networkState.tokenSymbol[0]}'),
            Text(
                'tokenDecimals: ${widget.network.networkState.tokenDecimals[0]}'),
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
            Text('externals:'),
            Text(widget.keyring.externals
                .map((e) => e.address)
                .toList()
                .join(',')),
            RoundedButton(
              text: widget.keyring.keyPairs.length > 0
                  ? 'Remove Account'
                  : 'Import Account',
              onPressed: _loading
                  ? null
                  : widget.keyring.keyPairs.length > 0
                      ? () => _removeAccount()
                      : () => _importAccount(),
            ),
            RoundedButton(
              text: widget.keyring.externals.length > 0
                  ? 'Remove External'
                  : 'Import External',
              onPressed: _loading
                  ? null
                  : widget.keyring.externals.length > 0
                      ? () => _removeExternal()
                      : () => _importExternal(),
            )
          ],
        ),
      ],
    );
  }
}
