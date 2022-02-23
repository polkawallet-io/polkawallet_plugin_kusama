import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_kusama/pages/stakingNew/RewardDetailPage.dart';
import 'package:polkawallet_plugin_kusama/pages/stakingNew/stakingHistoryPage.dart';
import 'package:polkawallet_plugin_kusama/pages/stakingNew/stakingPage.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';

import 'pages/stakingNew/overViewPage.dart';

Map<String, WidgetBuilder> getNewUiRoutes(
    PluginKusama plugin, Keyring keyring) {
  return {
    StakingPage.route: (_) => StakingPage(plugin, keyring),
    StakingHistoryPage.route: (_) => StakingHistoryPage(plugin),
    OverViewPage.route: (_) => OverViewPage(plugin),
    RewardDetailPage.route: (_) => RewardDetailPage(plugin),
  };
}
