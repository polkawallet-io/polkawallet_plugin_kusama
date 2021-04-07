library polkawallet_plugin_chainx;

import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:polkawallet_plugin_chainx/common/constants.dart';
import 'package:polkawallet_plugin_chainx/pages/governance.dart';
import 'package:polkawallet_plugin_chainx/pages/governance/council/candidateDetailPage.dart';
import 'package:polkawallet_plugin_chainx/pages/governance/council/candidateListPage.dart';
import 'package:polkawallet_plugin_chainx/pages/governance/council/councilPage.dart';
import 'package:polkawallet_plugin_chainx/pages/governance/council/councilVotePage.dart';
import 'package:polkawallet_plugin_chainx/pages/governance/council/motionDetailPage.dart';
import 'package:polkawallet_plugin_chainx/pages/governance/democracy/democracyPage.dart';
import 'package:polkawallet_plugin_chainx/pages/governance/democracy/proposalDetailPage.dart';
import 'package:polkawallet_plugin_chainx/pages/governance/democracy/referendumVotePage.dart';
import 'package:polkawallet_plugin_chainx/pages/governance/treasury/spendProposalPage.dart';
import 'package:polkawallet_plugin_chainx/pages/governance/treasury/submitProposalPage.dart';
import 'package:polkawallet_plugin_chainx/pages/governance/treasury/submitTipPage.dart';
import 'package:polkawallet_plugin_chainx/pages/governance/treasury/tipDetailPage.dart';
import 'package:polkawallet_plugin_chainx/pages/governance/treasury/treasuryPage.dart';
import 'package:polkawallet_plugin_chainx/pages/staking.dart';
import 'package:polkawallet_plugin_chainx/pages/staking/actions/stakePage.dart';
import 'package:polkawallet_plugin_chainx/pages/staking/actions/claimPageWrapper.dart';
import 'package:polkawallet_plugin_chainx/pages/staking/validators/validatorDetailPage.dart';
import 'package:polkawallet_plugin_chainx/service/index.dart';
import 'package:polkawallet_plugin_chainx/store/cache/storeCache.dart';
import 'package:polkawallet_plugin_chainx/store/index.dart';
import 'package:polkawallet_plugin_chainx/utils/i18n/index.dart';
import 'package:polkawallet_sdk/api/types/networkParams.dart';
import 'package:polkawallet_sdk/plugin/homeNavItem.dart';
import 'package:polkawallet_sdk/plugin/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/pages/dAppWrapperPage.dart';
import 'package:polkawallet_ui/pages/txConfirmPage.dart';
import 'package:polkawallet_ui/pages/walletExtensionSignPage.dart';

class PluginChainX extends PolkawalletPlugin {
  PluginChainX({name = 'chainx'})
      : basic = PluginBasicData(
          name: name,
          ss58: 44,
          primaryColor: chainx_yellow,
          gradientColor: Colors.yellow,
          backgroundImage: AssetImage('packages/polkawallet_plugin_chainx/assets/images/public/bg.png'),
          icon: Image.asset('packages/polkawallet_plugin_chainx/assets/images/public/$name.png'),
          iconDisabled: Image.asset('packages/polkawallet_plugin_chainx/assets/images/public/${name}_gray.png'),
          jsCodeVersion: 11301,
          isTestNet: false,
        ),
        recoveryEnabled = true,
        _cache = StoreCacheChainX();

  @override
  final PluginBasicData basic;

  @override
  final bool recoveryEnabled;

  @override
  List<NetworkParams> get nodeList {
    return _randomList(node_list_chainx).map((e) => NetworkParams.fromJson(e)).toList();
  }

  @override
  final Map<String, Widget> tokenIcons = {
    'PCX': Image.asset('packages/polkawallet_plugin_chainx/assets/images/tokens/PCX.png'),
  };

  @override
  List<HomeNavItem> getNavItems(BuildContext context, Keyring keyring) {
    final color = 'yellow';
    return home_nav_items.map((e) {
      final dic = I18n.of(context).getDic(i18n_full_dic_chainx, 'common');
      return HomeNavItem(
        text: dic[e],
        icon: Image(image: AssetImage('assets/images/public/$e.png', package: 'polkawallet_plugin_chainx')),
        iconActive: Image(image: AssetImage('assets/images/public/${e}_$color.png', package: 'polkawallet_plugin_chainx')),
        content: e == 'staking' ? Staking(this, keyring) : Gov(this),
      );
    }).toList();
  }

  @override
  Map<String, WidgetBuilder> getRoutes(Keyring keyring) {
    return {
      TxConfirmPage.route: (_) => TxConfirmPage(this, keyring, _service.getPassword),

      // staking pages
      StakePage.route: (_) => StakePage(this, keyring),
      ClaimPageWrapper.route: (_) => ClaimPageWrapper(this, keyring),
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
      WalletExtensionSignPage.route: (_) => WalletExtensionSignPage(this, keyring, _service.getPassword),
    };
  }

  @override
  Future<String> loadJSCode() => rootBundle.loadString('packages/polkawallet_plugin_chainx/lib/js_service_chainx/dist/main.js');

  PluginStore _store;
  PluginApi _service;
  PluginStore get store => _store;
  PluginApi get service => _service;

  final StoreCache _cache;

  @override
  Future<void> onWillStart(Keyring keyring) async {
    await GetStorage.init(plugin_chainx_storage_key);

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
