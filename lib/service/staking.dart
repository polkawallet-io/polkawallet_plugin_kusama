import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/service/walletApi.dart';
import 'package:polkawallet_plugin_kusama/store/index.dart';
import 'package:polkawallet_plugin_kusama/utils/format.dart';
import 'package:polkawallet_sdk/api/api.dart';
import 'package:polkawallet_sdk/api/subscan.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';

class ApiStaking {
  ApiStaking(this.plugin, this.keyring)
      : api = plugin.sdk.api,
        store = plugin.store;

  final PluginKusama plugin;
  final Keyring keyring;
  final PolkawalletApi api;
  final PluginStore? store;

  Future<List?> fetchAccountRewardsEraOptions() async {
    final List? res = await api.staking.getAccountRewardsEraOptions();
    return res;
  }

  // this query takes extremely long time
  Future<Map?> fetchAccountRewards(int? eras) async {
    if (store!.staking.ownStashInfo != null &&
        store!.staking.ownStashInfo!.stakingLedger != null) {
      int bonded = int.parse(
          store!.staking.ownStashInfo!.stakingLedger!['active'].toString());
      List? unlocking =
          store!.staking.ownStashInfo!.stakingLedger!['unlocking'];
      if (bonded > 0 || unlocking!.length > 0) {
        String address = store!.staking.ownStashInfo!.stashId!;
        print('fetching staking rewards...');
        Map? res = await api.staking.queryAccountRewards(address, eras!);
        return res;
      }
    }
    return {};
  }

  Future<Map> updateStakingTxs(int page, {int size = tx_list_page_size}) async {
    store!.staking.setTxsLoading(true);

    final res = await Future.wait([
      api.subScan.fetchTxsAsync(
        'staking',
        page: page,
        size: size,
        sender: keyring.current.address,
        network: plugin.basic.name!,
      ),
      api.subScan.fetchTxsAsync(
        'utility',
        call: 'batchAll',
        page: page,
        size: size,
        sender: keyring.current.address,
        network: plugin.basic.name!,
      ),
    ]);
    final list = res[0];
    // ignore: unnecessary_null_comparison
    if (res[1] != null && res[1]['extrinsics'] != null) {
      final batchTxs = List.of(res[1]['extrinsics']);
      batchTxs.retainWhere((e) => (e['params'] as String).contains('Staking'));
      final allTxs = [...res[0]['extrinsics'], ...batchTxs];
      allTxs.sort((a, b) => a['block_num'] < b['block_num'] ? 1 : -1);
      res[0]['extrinsics'] = allTxs;
    }
    await store!.staking.addTxs(
      list,
      keyring.current.pubKey,
      shouldCache: page == 0,
      reset: page == 0,
    );

    store!.staking.setTxsLoading(false);

    return list;
  }

  Future<Map> updateStakingRewards() async {
    final res = await api.subScan.fetchRewardTxsAsync(
      page: 0,
      size: 20,
      sender: keyring.current.address,
      network: plugin.basic.name!,
    );
    await store!.staking
        .addTxsRewards(res, keyring.current.pubKey, shouldCache: true);
    return res;
  }

  // this query takes a long time
  Future<void> queryElectedInfo() async {
    // fetch all validators details
    final dynamic res = await api.staking.queryElectedInfo();
    store!.staking.setValidatorsInfo(res);

    queryNominationsCount();

    List validatorAddressList = res['validatorIds'];
    validatorAddressList.addAll(res['waitingIds']);
    plugin.service.gov.updateIconsAndIndices(validatorAddressList);
  }

  Future<void> queryNominations() async {
    // fetch nominators for all validators
    final res = await api.staking.queryNominations();
    store!.staking.setNominations(res);
  }

  Future<void> queryNominationsCount() async {
    // fetch nominators for all validators
    final res = await api.staking.queryNominationsCount();
    store!.staking.setNominationsCount(res);
  }

  Future<Map?> queryValidatorRewards(String accountId) async {
    print('fetching rewards chart data');
    Map? data = await api.staking.loadValidatorRewardsData(accountId);
    if (data != null) {
      // format rewards data & set cache
      Map chartData = PluginFmt.formatRewardsChartData(data);
      store!.staking.setRewardsChartData(accountId, chartData);
    }
    return data;
  }

  Future<Map> queryOwnStashInfo() async {
    final dynamic data =
        await api.service.staking.queryOwnStashInfo(keyring.current.address!);
    store!.staking.setOwnStashInfo(keyring.current.pubKey, data);

    final List<String?> addressesNeedIcons =
        store!.staking.ownStashInfo?.nominating != null
            ? store!.staking.ownStashInfo!.nominating!.toList()
            : [];
    final List<String?> addressesNeedDecode = [];
    if (store!.staking.ownStashInfo?.stashId != null) {
      addressesNeedIcons.add(store!.staking.ownStashInfo!.stashId);
      addressesNeedDecode.add(store!.staking.ownStashInfo!.stashId);
    }
    if (store!.staking.ownStashInfo?.controllerId != null) {
      addressesNeedIcons.add(store!.staking.ownStashInfo!.controllerId);
      addressesNeedDecode.add(store!.staking.ownStashInfo!.controllerId);
    }

    final iconsAndPubKeys = await Future.wait([
      api.account.getAddressIcons(addressesNeedIcons),
      api.account.decodeAddress(addressesNeedDecode as List<String>)
    ]);
    if (iconsAndPubKeys[0] != null && iconsAndPubKeys[1] != null) {
      store!.accounts.setAddressIconsMap(iconsAndPubKeys[0] as List);
      store!.accounts.setPubKeyAddressMap(Map<String, Map>.from(
          {api.connectedNode!.ss58.toString(): iconsAndPubKeys[1]}));
    }

    return data;
  }

  Future<void> queryAccountBondedInfo() async {
    final List<String> accounts =
        keyring.allAccounts.map((e) => e.pubKey!).toList();
    if (accounts.length > store!.staking.accountBondedMap.keys.length) {
      final data = await api.staking.queryBonded(accounts);
      store!.staking.setAccountBondedMap(data);
    }
  }

  Future<void> queryMarketPrices() async {
    final Map? res = await WalletApi.getTokenPrice();
    final Map<String, double> prices = {...((res?['prices'] as Map?) ?? {})};

    store!.staking.setMarketPrices(prices);
  }
}
