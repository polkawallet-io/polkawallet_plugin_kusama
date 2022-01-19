import 'package:polkawallet_plugin_kusama/store/accounts.dart';
import 'package:polkawallet_plugin_kusama/store/cache/storeCache.dart';
import 'package:polkawallet_plugin_kusama/store/gov/governance.dart';
import 'package:polkawallet_plugin_kusama/store/parachain.dart';
import 'package:polkawallet_plugin_kusama/store/staking/staking.dart';

class PluginStore {
  PluginStore(StoreCache cache)
      : staking = StakingStore(cache),
        gov = GovernanceStore(cache);
  final StakingStore staking;
  final GovernanceStore gov;
  final AccountsStore accounts = AccountsStore();
  final ParachainStore paras = ParachainStore();
}
