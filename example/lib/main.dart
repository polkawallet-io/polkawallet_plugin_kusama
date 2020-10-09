import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_kusama_example/pages/assetsContent.dart';
import 'package:polkawallet_plugin_kusama_example/pages/profileContent.dart';
import 'package:polkawallet_plugin_kusama_example/pages/selectListPage.dart';

import 'package:polkawallet_sdk/api/types/networkParams.dart';
import 'package:polkawallet_sdk/api/types/networkStateData.dart';
import 'package:polkawallet_sdk/plugin/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama_example/pages/homePage.dart';

void main() {
  final _plugins = [
    PluginKusama(name: 'polkadot'),
    PluginKusama(),
  ];

  runApp(MyApp(_plugins));
}

class MyApp extends StatefulWidget {
  MyApp(this.plugins);
  final List<PolkawalletPlugin> plugins;
  @override
  _MyAppState createState() => _MyAppState(plugins[0]);
}

class _MyAppState extends State<MyApp> {
  _MyAppState(PolkawalletPlugin defaultPlugin) : this._network = defaultPlugin;

  PolkawalletPlugin _network;
  final _keyring = Keyring();

  ThemeData _theme;

  NetworkParams _connectedNode;

  NetworkStateData _networkState = NetworkStateData();

  ThemeData _getAppTheme(MaterialColor color) {
    return ThemeData(
      primarySwatch: color,
      textTheme: TextTheme(
          headline1: TextStyle(
            fontSize: 24,
          ),
          headline2: TextStyle(
            fontSize: 22,
          ),
          headline3: TextStyle(
            fontSize: 20,
          ),
          headline4: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          button: TextStyle(
            color: Colors.white,
            fontSize: 18,
          )),
    );
  }

  void _setNetwork(PolkawalletPlugin network) {
    setState(() {
      _network = network;
      _theme = _getAppTheme(network.primaryColor);
    });
  }

  void _setConnectedNode(NetworkParams node) {
    if (node != null) {
      _queryNetworkState();
      _subscribeBalance();
    }
    setState(() {
      _connectedNode = node;
    });
  }

  Future<void> _queryNetworkState() async {
    final res = await _network.sdk.api.setting.queryNetworkProps();
    if (res != null) {
      setState(() {
        _networkState = res;
      });
    }
  }

  void _subscribeBalance() async {
    // if (_keyring.keyPairs.length > 0) {
    //   _network.subscribeBalances(_keyring.keyPairs[0]);
    // }
    final acc = KeyPairData();
    acc.address = '1CTthuNVHUxWJkejKUGAoKaW1ffbXaUUHpEQvfizWP2CMQe';
    _network.subscribeBalances(acc);
  }

  Future<void> _startPlugin() async {
    await _keyring.init();

    final connected = await _network.start(_keyring);
    _setConnectedNode(connected);
  }

  void _showResult(BuildContext context, String title, res) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: SelectableText(res, textAlign: TextAlign.left),
          actions: [
            CupertinoButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  Map<String, Widget Function(BuildContext)> _createRoutes() {
    final res = _network != null
        ? _network.routes
            .map((key, value) => MapEntry('${_network.name}$key', value))
        : {};
    return {
      SelectListPage.route: (_) => SelectListPage(),
      ...res,
    };
  }

  @override
  void initState() {
    super.initState();
    _startPlugin();
  }

  @override
  Widget build(BuildContext context) {
    final ProfileContent profile = ProfileContent(
        _network,
        _keyring,
        widget.plugins,
        _connectedNode,
        _networkState,
        _setNetwork,
        _setConnectedNode);
    final AssetsContent assets =
        AssetsContent(_network, _keyring, _networkState);
    return MaterialApp(
      title: 'Polkawallet Plugin Kusama Demo',
      theme: _theme ?? _getAppTheme(widget.plugins[0].primaryColor),
      home: MyHomePage(
        network: _network,
        assetsContent: assets,
        profileContent: profile,
      ),
      routes: _createRoutes(),
    );
  }
}
