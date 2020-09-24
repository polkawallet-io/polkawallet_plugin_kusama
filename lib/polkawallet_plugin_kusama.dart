library polkawallet_plugin_kusama;

import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_kusama/common/constants.dart';
import 'package:polkawallet_plugin_kusama/pages/governance.dart';
import 'package:polkawallet_plugin_kusama/pages/staking.dart';
import 'package:polkawallet_sdk/api/types/networkParams.dart';
import 'package:polkawallet_sdk/plugin/homeNavItem.dart';
import 'package:polkawallet_sdk/polkawallet_sdk.dart';

enum Network { kusama, polkadot }

class PluginKusama implements PolkawalletPlugin {
  /// the kusama plugin support two networks: kusama & polkadot,
  /// so we need to identify the active network to connect & display UI.
  Network _activeNetwork = Network.kusama;
  List<NetworkParams> _getNodeList() {
    if (_activeNetwork == Network.polkadot) {
      return node_list_polkadot.map((e) => NetworkParams.fromJson(e)).toList();
    }
    return node_list_kusama.map((e) => NetworkParams.fromJson(e)).toList();
  }

  final name = 'kusama';

  final WalletSDK sdk = WalletSDK();

  List<HomeNavItem> get navItems {
    final color = _activeNetwork == Network.polkadot ? 'pink' : 'black';
    return home_nav_items.map((e) {
      final networkName = e.toLowerCase();
      return HomeNavItem(
        text: e,
        icon: Image(
            image: AssetImage('assets/images/public/$networkName.png',
                package: 'polkawallet_plugin_kusama')),
        iconActive: Image(
            image: AssetImage('assets/images/public/${networkName}_$color.png',
                package: 'polkawallet_plugin_kusama')),
        content: e == 'Staking' ? Staking() : Gov(),
      );
    }).toList();
  }

  /// init the plugin runtime & connect to nodes
  Future<NetworkParams> start({String network}) async {
    _activeNetwork = network == 'polkadot' ? Network.polkadot : Network.kusama;

    await sdk.init();

    return sdk.api.connectNodeAll(_getNodeList());
  }

  Future<void> dispose() async {
    // do nothing.
  }
}
