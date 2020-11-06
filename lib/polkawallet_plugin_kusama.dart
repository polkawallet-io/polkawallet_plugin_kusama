library polkawallet_plugin_kusama;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_kusama/common/constants.dart';
import 'package:polkawallet_plugin_kusama/pages/governance.dart';
import 'package:polkawallet_plugin_kusama/pages/staking.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/bondExtraPage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/bondPage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/payoutPage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/redeemPage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/rewardDetailPage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/setControllerPage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/setPayeePage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/stakingDetailPage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/unbondPage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/validators/nominatePage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/validators/validatorDetailPage.dart';
import 'package:polkawallet_plugin_kusama/service/index.dart';
import 'package:polkawallet_plugin_kusama/store/cache/storeCache.dart';
import 'package:polkawallet_plugin_kusama/store/index.dart';
import 'package:polkawallet_sdk/api/types/balanceData.dart';
import 'package:polkawallet_sdk/api/types/networkParams.dart';
import 'package:polkawallet_sdk/api/types/networkStateData.dart';
import 'package:polkawallet_sdk/plugin/homeNavItem.dart';
import 'package:polkawallet_sdk/polkawallet_sdk.dart';
import 'package:polkawallet_sdk/plugin/index.dart';
import 'package:polkawallet_sdk/plugin/store/balances.dart';
import 'package:polkawallet_sdk/service/webViewRunner.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';

class PluginKusama extends PolkawalletPlugin {
  /// the kusama plugin support two networks: kusama & polkadot,
  /// so we need to identify the active network to connect & display UI.
  PluginKusama({name = 'kusama'})
      : name = name,
        cache = name == 'kusama' ? StoreCacheKusama() : StoreCachePolkadot();

  PluginStore _store;
  PluginApi _service;
  PluginStore get store => _store;
  PluginApi get service => _service;

  final StoreCache cache;

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
  final balances = BalancesStore();

  @override
  Map networkConst = {};

  @override
  NetworkStateData networkState = NetworkStateData();

  @override
  List<HomeNavItem> getNavItems(Keyring keyring) {
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
        content: e == 'Staking' ? Staking(this, keyring) : Gov(),
      );
    }).toList();
  }

  @override
  Map<String, WidgetBuilder> getRoutes(Keyring keyring) {
    return {
      BondPage.route: (_) => BondPage(this, keyring),
      BondExtraPage.route: (_) => BondExtraPage(this, keyring),
      SetControllerPage.route: (_) => SetControllerPage(this, keyring),
      UnBondPage.route: (_) => UnBondPage(this, keyring),
      SetPayeePage.route: (_) => SetPayeePage(this, keyring),
      RedeemPage.route: (_) => RedeemPage(this, keyring),
      PayoutPage.route: (_) => PayoutPage(this, keyring),
      NominatePage.route: (_) => NominatePage(this, keyring),
      StakingDetailPage.route: (_) => StakingDetailPage(this, keyring),
      RewardDetailPage.route: (_) => RewardDetailPage(this, keyring),
      ValidatorDetailPage.route: (_) => ValidatorDetailPage(this, keyring),
    };
  }

  /// init the plugin runtime & connect to node
  @override
  Future<NetworkParams> start(Keyring keyring, {WebViewRunner webView}) async {
    await sdk.init(keyring, webView: webView);

    _store = PluginStore(cache);
    _service = PluginApi(this, keyring);

    final res = await sdk.api.connectNode(keyring, nodeList);
    networkState = await sdk.api.setting.queryNetworkProps();
    networkConst = await sdk.api.setting.queryNetworkConst();

    _service.staking.fetchStakingOverview();
    return res;
  }

  @override
  void subscribeBalances(KeyPairData keyPair) {
    sdk.api.account.subscribeBalance(keyPair.address, (BalanceData data) {
      balances.setBalance(data);
    });
  }
}
