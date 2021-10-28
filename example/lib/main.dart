import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama_example/pages/assetsContent.dart';
import 'package:polkawallet_plugin_kusama_example/pages/homePage.dart';
import 'package:polkawallet_plugin_kusama_example/pages/profileContent.dart';
import 'package:polkawallet_plugin_kusama_example/pages/selectListPage.dart';
import 'package:polkawallet_sdk/api/types/networkParams.dart';
import 'package:polkawallet_sdk/plugin/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/passwordInputDialog.dart';
import 'package:polkawallet_ui/pages/accountListPage.dart';
import 'package:polkawallet_ui/pages/qrSenderPage.dart';
import 'package:polkawallet_ui/pages/scanPage.dart';
import 'package:polkawallet_ui/pages/txConfirmPage.dart';

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

  Locale _locale;

  NetworkParams _connectedNode;

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

  void _changeLang(String code) {
    Locale res;
    switch (code) {
      case 'zh':
        res = const Locale('zh', '');
        break;
      case 'en':
        res = const Locale('en', '');
        break;
      default:
        res = null;
    }
    setState(() {
      _locale = res;
    });
  }

  void _setNetwork(PolkawalletPlugin network) {
    setState(() {
      _network = network;
      _theme = _getAppTheme(network.basic.primaryColor);
    });
  }

  void _setConnectedNode(NetworkParams node) {
    setState(() {
      _connectedNode = node;
    });
  }

  Future<void> _startPlugin() async {
    await _keyring.init([2]);

    await _network.beforeStart(_keyring);
    final connected = await _network.start(_keyring);
    _setConnectedNode(connected);
  }

  // void _showResult(BuildContext context, String title, res) {
  //   showCupertinoDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return CupertinoAlertDialog(
  //         title: Text(title),
  //         content: SelectableText(res, textAlign: TextAlign.left),
  //         actions: [
  //           CupertinoButton(
  //             child: Text('OK'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           )
  //         ],
  //       );
  //     },
  //   );
  // }

  Future<String> getPassword(BuildContext context, KeyPairData acc) async {
    final password = await showCupertinoDialog(
      context: context,
      builder: (_) {
        return PasswordInputDialog(
          _network.sdk.api,
          title: Text('unlock'),
          account: acc,
        );
      },
    );
    return password;
  }

  Map<String, Widget Function(BuildContext)> _getRoutes() {
    final res = _network != null ? _network.getRoutes(_keyring) : {};
    return {
      SelectListPage.route: (_) => SelectListPage(),
      TxConfirmPage.route: (_) =>
          TxConfirmPage(_network, _keyring, getPassword),
      QrSenderPage.route: (_) => QrSenderPage(_network, _keyring),
      ScanPage.route: (_) => ScanPage(_network, _keyring),
      AccountListPage.route: (_) => AccountListPage(_network, _keyring),
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
        _locale,
        widget.plugins,
        _connectedNode,
        _setNetwork,
        _setConnectedNode,
        _changeLang);
    final AssetsContent assets = AssetsContent(_network, _keyring);
    return MaterialApp(
      title: 'Polkawallet Plugin Kusama Demo',
      theme: _theme ?? _getAppTheme(widget.plugins[0].basic.primaryColor),
      localizationsDelegates: [
        AppLocalizationsDelegate(_locale ?? Locale('en', '')),
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('zh', ''),
      ],
      home: MyHomePage(
        network: _network,
        keyring: _keyring,
        assetsContent: assets,
        profileContent: profile,
      ),
      routes: _getRoutes(),
    );
  }
}
