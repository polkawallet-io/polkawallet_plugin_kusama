library polkawallet_plugin_kusama;

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:polkawallet_plugin_kusama/common/constants.dart';
import 'package:polkawallet_plugin_kusama/pages/governance.dart';
import 'package:polkawallet_plugin_kusama/pages/governance/council/candidateDetailPage.dart';
import 'package:polkawallet_plugin_kusama/pages/governance/council/candidateListPage.dart';
import 'package:polkawallet_plugin_kusama/pages/governance/council/councilPage.dart';
import 'package:polkawallet_plugin_kusama/pages/governance/council/councilVotePage.dart';
import 'package:polkawallet_plugin_kusama/pages/governance/council/motionDetailPage.dart';
import 'package:polkawallet_plugin_kusama/pages/governance/democracy/democracyPage.dart';
import 'package:polkawallet_plugin_kusama/pages/governance/democracy/proposalDetailPage.dart';
import 'package:polkawallet_plugin_kusama/pages/governance/democracy/referendumVotePage.dart';
import 'package:polkawallet_plugin_kusama/pages/governance/treasury/spendProposalPage.dart';
import 'package:polkawallet_plugin_kusama/pages/governance/treasury/submitProposalPage.dart';
import 'package:polkawallet_plugin_kusama/pages/governance/treasury/submitTipPage.dart';
import 'package:polkawallet_plugin_kusama/pages/governance/treasury/tipDetailPage.dart';
import 'package:polkawallet_plugin_kusama/pages/governance/treasury/treasuryPage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/bondExtraPage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/controllerSelectPage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/payoutPage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/rebondPage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/redeemPage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/rewardDetailPage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/setControllerPage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/setPayeePage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/stakePage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/stakingDetailPage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/unbondPage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/validators/nominatePage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/validators/validatorDetailPage.dart';
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
import 'package:polkawallet_ui/pages/txConfirmPage.dart';
import 'package:polkawallet_ui/pages/walletExtensionSignPage.dart';

class PluginKusama extends PolkawalletPlugin {
  /// the kusama plugin support two networks: kusama & polkadot,
  /// so we need to identify the active network to connect & display UI.
  PluginKusama({name = 'kusama'})
      : basic = PluginBasicData(
          name: name,
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
          jsCodeVersion: 20101,
          isTestNet: false,
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
      return _randomList(node_list_polkadot)
          .map((e) => NetworkParams.fromJson(e))
          .toList();
    }
    return _randomList(node_list_kusama)
        .map((e) => NetworkParams.fromJson(e))
        .toList();
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
      final dic = I18n.of(context).getDic(i18n_full_dic_kusama, 'common');
      return HomeNavItem(
        text: dic[e],
        icon: SvgPicture.asset(
          'packages/polkawallet_plugin_kusama/assets/images/public/nav_$e.svg',
          color: Theme.of(context).disabledColor,
        ),
        iconActive: SvgPicture.asset(
          'packages/polkawallet_plugin_kusama/assets/images/public/nav_$e.svg',
          color: basic.primaryColor,
        ),
        content: e == 'staking' ? Staking(this, keyring) : Gov(this),
      );
    }).toList();
  }

  @override
  Map<String, WidgetBuilder> getRoutes(Keyring keyring) {
    return {
      TxConfirmPage.route: (_) =>
          TxConfirmPage(this, keyring, _service.getPassword),

      // staking pages
      StakePage.route: (_) => StakePage(this, keyring),
      BondExtraPage.route: (_) => BondExtraPage(this, keyring),
      ControllerSelectPage.route: (_) => ControllerSelectPage(this, keyring),
      SetControllerPage.route: (_) => SetControllerPage(this, keyring),
      UnBondPage.route: (_) => UnBondPage(this, keyring),
      RebondPage.route: (_) => RebondPage(this, keyring),
      SetPayeePage.route: (_) => SetPayeePage(this, keyring),
      RedeemPage.route: (_) => RedeemPage(this, keyring),
      PayoutPage.route: (_) => PayoutPage(this, keyring),
      NominatePage.route: (_) => NominatePage(this, keyring),
      StakingDetailPage.route: (_) => StakingDetailPage(this, keyring),
      RewardDetailPage.route: (_) => RewardDetailPage(this, keyring),
      ValidatorDetailPage.route: (_) => ValidatorDetailPage(this, keyring),

      // governance pages
      DemocracyPage.route: (_) => DemocracyPage(this, keyring),
      ReferendumVotePage.route: (_) => ReferendumVotePage(this, keyring),
      CouncilPage.route: (_) => CouncilPage(this, keyring),
      CouncilVotePage.route: (_) => CouncilVotePage(this),
      CandidateListPage.route: (_) => CandidateListPage(this, keyring),
      CandidateDetailPage.route: (_) => CandidateDetailPage(this, keyring),
      MotionDetailPage.route: (_) => MotionDetailPage(this, keyring),
      ProposalDetailPage.route: (_) => ProposalDetailPage(this, keyring),
      TreasuryPage.route: (_) => TreasuryPage(this, keyring),
      SpendProposalPage.route: (_) => SpendProposalPage(this, keyring),
      SubmitProposalPage.route: (_) => SubmitProposalPage(this, keyring),
      SubmitTipPage.route: (_) => SubmitTipPage(this, keyring),
      TipDetailPage.route: (_) => TipDetailPage(this, keyring),
      DAppWrapperPage.route: (_) => DAppWrapperPage(this, keyring),
      WalletExtensionSignPage.route: (_) =>
          WalletExtensionSignPage(this, keyring, _service.getPassword),
    };
  }

  @override
  Future<String> loadJSCode() => null;

  PluginStore _store;
  PluginApi _service;
  PluginStore get store => _store;
  PluginApi get service => _service;

  final StoreCache _cache;

  @override
  Future<void> onWillStart(Keyring keyring) async {
    await GetStorage.init(basic.name == network_name_polkadot
        ? plugin_polkadot_storage_key
        : plugin_kusama_storage_key);

    _store = PluginStore(_cache);
    _store.staking.loadCache(keyring.current.pubKey);
    _store.gov.clearState();
    _store.gov.loadCache();

    _service = PluginApi(this, keyring);
  }

  @override
  Future<void> onStarted(Keyring keyring) async {
    _service.staking.queryElectedInfo();
  }

  @override
  Future<void> onAccountChanged(KeyPairData acc) async {
    _store.staking.loadAccountCache(acc.pubKey);
  }

  List _randomList(List input) {
    final data = input.toList();
    final res = List();
    final _random = Random();
    for (var i = 0; i < input.length; i++) {
      final item = data[_random.nextInt(data.length)];
      res.add(item);
      data.remove(item);
    }
    return res;
  }
}
