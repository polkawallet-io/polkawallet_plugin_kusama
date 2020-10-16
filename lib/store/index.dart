import 'package:polkawallet_plugin_kusama/store/accounts.dart';
import 'package:polkawallet_plugin_kusama/store/cache/storeCache.dart';
import 'package:polkawallet_plugin_kusama/store/staking/staking.dart';

class PluginStore {
  PluginStore(StoreCache cache) : staking = StakingStore(cache);
  final StakingStore staking;
  final AccountsStore accounts = AccountsStore();
}
