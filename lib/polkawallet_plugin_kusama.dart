library polkawallet_plugin_kusama;

import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_kusama/common/constants.dart';
import 'package:polkawallet_plugin_kusama/pages/governance.dart';
import 'package:polkawallet_plugin_kusama/pages/staking.dart';
import 'package:polkawallet_sdk/api/types/networkParams.dart';
import 'package:polkawallet_sdk/plugin/homeNavItem.dart';
import 'package:polkawallet_sdk/polkawallet_sdk.dart';
import 'package:polkawallet_sdk/plugin/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';

enum NetworkName { kusama, polkadot }

class PluginKusama implements PolkawalletPlugin {
  /// the kusama plugin support two networks: kusama & polkadot,
  /// so we need to identify the active network to connect & display UI.
  NetworkName activeNetwork = NetworkName.kusama;
  List<NetworkParams> _getNodeList() {
    if (activeNetwork == NetworkName.polkadot) {
      return node_list_polkadot.map((e) => NetworkParams.fromJson(e)).toList();
    }
    return node_list_kusama.map((e) => NetworkParams.fromJson(e)).toList();
  }

  final name = 'kusama';

  final WalletSDK sdk = WalletSDK();

  List<HomeNavItem> get navItems {
    final color = activeNetwork == NetworkName.polkadot ? 'pink' : 'black';
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

  /// init the plugin runtime & connect to nodes
  Future<NetworkParams> start(Keyring keyring, {String network}) async {
    activeNetwork =
        network == 'polkadot' ? NetworkName.polkadot : NetworkName.kusama;

    sdk.init(keyring);

    return sdk.api.connectNodeAll(keyring, _getNodeList());
  }

  Future<void> dispose() async {
    // do nothing.
  }
}
