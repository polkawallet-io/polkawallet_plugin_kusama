import 'package:polkawallet_plugin_kusama/store/accounts.dart';
import 'package:polkawallet_plugin_kusama/store/cache/storeCache.dart';
import 'package:polkawallet_plugin_kusama/store/gov/governance.dart';
import 'package:polkawallet_plugin_kusama/store/staking/staking.dart';
import 'package:get/get.dart';

class PluginStore extends GetxController {
  PluginStore(StoreCache cache)
      : staking = StakingStore(cache),
        gov = GovernanceStore(cache);
  final StakingStore staking;
  final GovernanceStore gov;
  final AccountsStore accounts = AccountsStore();
}
