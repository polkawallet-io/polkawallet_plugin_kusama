library polkawallet_plugin_kusama;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_kusama/common/constants.dart';
import 'package:polkawallet_plugin_kusama/pages/governance.dart';
import 'package:polkawallet_plugin_kusama/pages/staking.dart';
import 'package:polkawallet_sdk/api/types/networkParams.dart';
import 'package:polkawallet_sdk/plugin/homeNavItem.dart';
import 'package:polkawallet_sdk/polkawallet_sdk.dart';
import 'package:polkawallet_sdk/plugin/index.dart';
import 'package:polkawallet_sdk/service/webViewRunner.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';

class PluginKusama extends PolkawalletPlugin {
  /// the kusama plugin support two networks: kusama & polkadot,
  /// so we need to identify the active network to connect & display UI.
  PluginKusama({this.name = 'kusama'});

  @override
  final String name;

  @override
  final WalletSDK sdk = WalletSDK();

  @override
  MaterialColor get primaryColor =>
      name == 'polkadot' ? Colors.pink : kusama_black;

  @override
  List<NetworkParams> get nodeList {
    if (name == 'polkadot') {
      return node_list_polkadot.map((e) => NetworkParams.fromJson(e)).toList();
    }
    return node_list_kusama.map((e) => NetworkParams.fromJson(e)).toList();
  }

  @override
  List<HomeNavItem> get navItems {
    final color = name == 'polkadot' ? 'pink' : 'black';
    return home_nav_items.map((e) {
      final nav = e.toLowerCase();
      return HomeNavItem(
        text: e,
        icon: Image(
            image: AssetImage('assets/images/public/$nav.png',
                package: 'polkawallet_plugin_kusama')),
        iconActive: Image(
            image: AssetImage('assets/images/public/${nav}_$color.png',
                package: 'polkawallet_plugin_kusama')),
        content: e == 'Staking' ? Staking() : Gov(),
      );
    }).toList();
  }

  @override
  Map<String, WidgetBuilder> get routes {
    return {};
  }

  /// init the plugin runtime & connect to nodes
  @override
  Future<NetworkParams> start(Keyring keyring, {WebViewRunner webView}) async {
    await sdk.init(keyring, webView: webView);
    final res = await sdk.api.connectNodeAll(keyring, nodeList);
    return res;
  }
}
