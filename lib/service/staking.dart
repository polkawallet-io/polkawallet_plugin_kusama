import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/store/index.dart';
import 'package:polkawallet_plugin_kusama/utils/format.dart';
import 'package:polkawallet_sdk/api/api.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';

class ApiStaking {
  ApiStaking(this.plugin, this.keyring)
      : api = plugin.sdk.api,
        store = plugin.store;

  final PluginKusama plugin;
  final Keyring keyring;
  final PolkawalletApi api;
  final PluginStore store;

  Future<List> fetchAccountRewardsEraOptions() async {
    final List res = await api.staking.getAccountRewardsEraOptions();
    return res;
  }

  // this query takes extremely long time
  Future<Map> fetchAccountRewards(int eras) async {
    if (store.staking.ownStashInfo != null &&
        store.staking.ownStashInfo.stakingLedger != null) {
      int bonded = store.staking.ownStashInfo.stakingLedger['active'];
      List unlocking = store.staking.ownStashInfo.stakingLedger['unlocking'];
      if (bonded > 0 || unlocking.length > 0) {
        String address = store.staking.ownStashInfo.stashId;
        print('fetching staking rewards...');
        Map res = await api.staking.queryAccountRewards(address, eras);
        return res;
      }
    }
    return {};
  }

  Future<Map> fetchStakingOverview() async {
    final overview = await api.staking.queryOverview();
    if (overview == null) return null;
    store.staking.setOverview(overview);

    fetchElectedInfo();

    List validatorAddressList = overview['validators'];
    validatorAddressList.addAll(overview['waiting']);
    final indexes = await api.account.queryIndexInfo(validatorAddressList);
    store.accounts.setAddressIndex(indexes);

    final icons = await api.account.getAddressIcons(validatorAddressList);
    store.accounts.setAddressIconsMap(icons);
    return overview;
  }

  Future<Map> updateStakingTxs(int page) async {
    store.staking.setTxsLoading(true);

    Map res = await api.subScan.fetchTxsAsync(
      'staking',
      page: page,
      sender: keyring.current.address,
      network: plugin.name,
    );

    if (page == 0) {
      store.staking.clearTxs();
    }
    await store.staking
        .addTxs(res, keyring.current.pubKey, shouldCache: page == 0);

    store.staking.setTxsLoading(false);

    return res;
  }

  Future<Map> updateStakingRewards() async {
    final address = store.staking.ownStashInfo?.stashId ??
        store.staking.ownStashInfo.account.accountId;
    final res = await api.subScan.fetchRewardTxsAsync(
      page: 0,
      sender: keyring.current.address,
      network: plugin.name,
    );

    await store.staking
        .addTxsRewards(res, keyring.current.pubKey, shouldCache: true);
    return res;
  }

  // this query takes a long time
  Future<void> fetchElectedInfo() async {
    // fetch all validators details
    var res = await api.staking.queryElectedInfo();
    store.staking.setValidatorsInfo(res);
  }

  Future<Map> queryValidatorRewards(String accountId) async {
    int timestamp = DateTime.now().second;
    Map cached = store.staking.rewardsChartDataCache[accountId];
    if (cached != null && cached['timestamp'] > timestamp - 1800) {
      return cached;
    }
    print('fetching rewards chart data');
    Map data = await api.staking.loadValidatorRewardsData(accountId);
    if (data != null) {
      // format rewards data & set cache
      Map chartData = PluginFmt.formatRewardsChartData(data);
      chartData['timestamp'] = timestamp;
      store.staking.setRewardsChartData(accountId, chartData);
    }
    return data;
  }

  Future<Map> queryOwnStashInfo() async {
    Map data = await api.staking.queryOwnStashInfo(keyring.current.address);
    store.staking.setOwnStashInfo(keyring.current.pubKey, data);

    final List<String> addressesNeedIcons =
        store.staking.ownStashInfo?.nominating != null
            ? store.staking.ownStashInfo.nominating.toList()
            : [];
    final List<String> addressesNeedDecode = [];
    if (store.staking.ownStashInfo?.stashId != null) {
      addressesNeedIcons.add(store.staking.ownStashInfo.stashId);
      addressesNeedDecode.add(store.staking.ownStashInfo.stashId);
    }
    if (store.staking.ownStashInfo?.controllerId != null) {
      addressesNeedIcons.add(store.staking.ownStashInfo.controllerId);
      addressesNeedDecode.add(store.staking.ownStashInfo.controllerId);
    }

    final icons = await api.account.getAddressIcons(addressesNeedIcons);
    store.accounts.setAddressIconsMap(icons);

    // get stash&controller's pubKey
    final pubKeys = await api.account.decodeAddress(addressesNeedIcons);
    store.accounts.setPubKeyAddressMap(
        Map<String, Map>.from({api.connectedNode.ss58.toString(): pubKeys}));

    return data;
  }
}
