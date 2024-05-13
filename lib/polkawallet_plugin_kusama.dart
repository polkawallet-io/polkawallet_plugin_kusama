library polkawallet_plugin_kusama;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:polkawallet_plugin_kusama/common/constants.dart';
import 'package:polkawallet_plugin_kusama/pages/gov2/VotePage.dart';
import 'package:polkawallet_plugin_kusama/pages/gov2/gov2Page.dart';
import 'package:polkawallet_plugin_kusama/pages/gov2/govEntryPage.dart';
import 'package:polkawallet_plugin_kusama/pages/governanceNew/candidateDetailPage.dart';
import 'package:polkawallet_plugin_kusama/pages/governanceNew/councilPage.dart';
import 'package:polkawallet_plugin_kusama/pages/governanceNew/councilVotePage.dart';
import 'package:polkawallet_plugin_kusama/pages/governanceNew/governancePage.dart';
import 'package:polkawallet_plugin_kusama/pages/governanceNew/referendumVotePage.dart';
import 'package:polkawallet_plugin_kusama/pages/governanceNew/treasuryPage.dart';
import 'package:polkawallet_plugin_kusama/pages/parasNew/contributePage.dart';
import 'package:polkawallet_plugin_kusama/pages/parasNew/parasPage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/bondExtraPage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/controllerSelectPage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/payoutPage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/redeemPage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/rewardDetailPage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/setControllerPage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/setPayeePage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/stakePage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/stakingDetailPage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/unbondPage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/validators/nominatePage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/validators/validatorChartsPage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/validators/validatorDetailPage.dart';
import 'package:polkawallet_plugin_kusama/pages/stakingNew/RewardDetailPage.dart';
import 'package:polkawallet_plugin_kusama/pages/stakingNew/overViewPage.dart';
import 'package:polkawallet_plugin_kusama/pages/stakingNew/rebondPage.dart';
import 'package:polkawallet_plugin_kusama/pages/stakingNew/stakingHistoryPage.dart';
import 'package:polkawallet_plugin_kusama/pages/stakingNew/stakingPage.dart';
import 'package:polkawallet_plugin_kusama/service/index.dart';
import 'package:polkawallet_plugin_kusama/store/cache/storeCache.dart';
import 'package:polkawallet_plugin_kusama/store/index.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/api/types/networkParams.dart';
import 'package:polkawallet_sdk/plugin/homeNavItem.dart';
import 'package:polkawallet_sdk/plugin/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/pages/dAppWrapperPage.dart';
import 'package:polkawallet_ui/pages/v3/txConfirmPage.dart';
import 'package:polkawallet_ui/pages/walletExtensionSignPage.dart';

class PluginKusama extends PolkawalletPlugin {
  /// the kusama plugin support two networks: kusama & polkadot,
  /// so we need to identify the active network to connect & display UI.
  PluginKusama({name = 'kusama'})
      : basic = PluginBasicData(
          name: name,
          genesisHash: name == network_name_kusama
              ? genesis_hash_kusama
              : genesis_hash_polkadot,
          ss58: name == network_name_kusama ? 2 : 0,
          primaryColor:
              name == network_name_kusama ? kusama_black : Colors.pink,
          gradientColor:
              name == network_name_kusama ? Color(0xFF555555) : Colors.red,
          backgroundImage: AssetImage(
              'packages/polkawallet_plugin_kusama/assets/images/public/bg_$name.png'),
          icon: Image.asset(
              'packages/polkawallet_plugin_kusama/assets/images/public/$name.png'),
          iconDisabled: Image.asset(
              'packages/polkawallet_plugin_kusama/assets/images/public/${name}_gray.png'),
          jsCodeVersion: 36301,
          isTestNet: false,
          isXCMSupport: name == network_name_kusama,
        ),
        recoveryEnabled = name == network_name_kusama,
        _cache = name == network_name_kusama
            ? StoreCacheKusama()
            : StoreCachePolkadot();

  @override
  final PluginBasicData basic;

  @override
  final bool recoveryEnabled;

  @override
  List<NetworkParams> get nodeList {
    if (basic.name == network_name_polkadot) {
      return node_list_polkadot.map((e) => NetworkParams.fromJson(e)).toList();
    }
    return node_list_kusama.map((e) => NetworkParams.fromJson(e)).toList();
  }

  @override
  final Map<String, Widget> tokenIcons = {
    'KSM': Image.asset(
        'packages/polkawallet_plugin_kusama/assets/images/tokens/KSM.png'),
    'DOT': Image.asset(
        'packages/polkawallet_plugin_kusama/assets/images/tokens/DOT.png'),
  };

  @override
  List<HomeNavItem> getNavItems(BuildContext context, Keyring keyring) {
    return home_nav_items.map((e) {
      final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'common')!;
      return HomeNavItem(
          text: dic[e]!,
          icon: Container(),
          iconActive: Container(),
          content: Container(),
          onTap: () {
            Navigator.of(context).pushNamed('/$e/index');
          });
    }).toList();
  }

  @override
  Map<String, WidgetBuilder> getRoutes(Keyring keyring) {
    return {
      TxConfirmPage.route: (_) => TxConfirmPage(
          this,
          keyring,
          _service.getPassword as Future<String> Function(
              BuildContext, KeyPairData)),

      // staking pages
      StakePage.route: (_) => StakePage(this, keyring),
      BondExtraPage.route: (_) => BondExtraPage(this, keyring),
      ControllerSelectPage.route: (_) => ControllerSelectPage(this, keyring),
      SetControllerPage.route: (_) => SetControllerPage(this, keyring),
      UnBondPage.route: (_) => UnBondPage(this, keyring),
      SetPayeePage.route: (_) => SetPayeePage(this, keyring),
      RedeemPage.route: (_) => RedeemPage(this, keyring),
      PayoutPage.route: (_) => PayoutPage(this, keyring),
      NominatePage.route: (_) => NominatePage(this, keyring),
      StakingDetailPage.route: (_) => StakingDetailPage(this, keyring),
      RewardDetailPage.route: (_) => RewardDetailPage(this, keyring),
      ValidatorDetailPage.route: (_) => ValidatorDetailPage(this, keyring),
      ValidatorChartsPage.route: (_) => ValidatorChartsPage(this, keyring),
      StakingPage.route: (_) => StakingPage(this, keyring),
      StakingHistoryPage.route: (_) => StakingHistoryPage(this),
      OverViewPage.route: (_) => OverViewPage(this),
      RewardDetailNewPage.route: (_) => RewardDetailNewPage(this),
      RebondPage.route: (_) => RebondPage(this),

      // governance pages
      GovernancePage.route: (_) => GovernancePage(this, keyring),
      CouncilPage.route: (_) => CouncilPage(this),
      CandidateDetailPage.route: (_) => CandidateDetailPage(this, keyring),
      ReferendumVotePage.route: (_) => ReferendumVotePage(this, keyring),
      CouncilVotePage.route: (_) => CouncilVotePage(this, keyring),
      TreasuryPage.route: (_) => TreasuryPage(this, keyring),
      // gov2 pages
      GovEntryPage.route: (_) => GovEntryPage(this, keyring),
      Gov2Page.route: (_) => Gov2Page(this, keyring),
      VotePage.route: (_) => VotePage(this, keyring),

      DAppWrapperPage.route: (_) => DAppWrapperPage(this, keyring),
      WalletExtensionSignPage.route: (_) => WalletExtensionSignPage(
          this,
          keyring,
          _service.getPassword as Future<String> Function(
              BuildContext, KeyPairData)),

      // parachains
      ParasPage.route: (_) => ParasPage(this, keyring),
      ContributePage.route: (_) => ContributePage(this, keyring),
    };
  }

  @override
  Future<String>? loadJSCode() => null;

  late PluginStore _store;
  late PluginApi _service;
  PluginStore get store => _store;
  PluginApi get service => _service;

  final StoreCache _cache;

  @override
  Future<void> onWillStart(Keyring keyring) async {
    await GetStorage.init(basic.name == network_name_polkadot
        ? plugin_polkadot_storage_key
        : plugin_kusama_storage_key);

    _store = PluginStore(_cache);

    try {
      loadBalances(keyring.current);

      _store.staking.loadCache(keyring.current.pubKey);
      _store.gov.clearState();
      _store.gov.loadCache();
      print('kusama plugin cache data loaded');
    } catch (err) {
      print(err);
      print('load kusama cache data failed');
    }

    _service = PluginApi(this, keyring);
  }

  // @override
  // Future<void> onStarted(Keyring keyring) async {
  //   _service.staking.queryElectedInfo();
  // }

  @override
  Future<void> onAccountChanged(KeyPairData acc) async {
    _store.gov.setReferendumsV2(null);
    _store.staking.loadAccountCache(acc.pubKey);
  }
}
