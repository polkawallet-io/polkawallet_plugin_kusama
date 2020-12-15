import 'package:mobx/mobx.dart';
import 'package:polkawallet_sdk/api/types/staking/accountBondedInfo.dart';
import 'package:polkawallet_sdk/api/types/staking/ownStashInfo.dart';
import 'package:polkawallet_sdk/api/types/txData.dart';
import 'package:polkawallet_plugin_kusama/store/cache/storeCache.dart';
import 'package:polkawallet_plugin_kusama/store/staking/types/txData.dart';
import 'package:polkawallet_plugin_kusama/store/staking/types/validatorData.dart';

part 'staking.g.dart';

class StakingStore extends _StakingStore with _$StakingStore {
  StakingStore(StoreCache cache) : super(cache);
}

abstract class _StakingStore with Store {
  _StakingStore(this.cache);

  final StoreCache cache;

  @observable
  ObservableMap<String, dynamic> overview = ObservableMap<String, dynamic>();

  @observable
  BigInt staked = BigInt.zero;

  @observable
  int nominatorCount = 0;

  @observable
  List<ValidatorData> validatorsInfo = List<ValidatorData>();

  @observable
  OwnStashInfoData ownStashInfo;

  @observable
  Map<String, AccountBondedInfo> accountBondedMap =
      Map<String, AccountBondedInfo>();

  @observable
  bool txsLoading = false;

  @observable
  int txsCount = 0;

  @observable
  ObservableList<TxData> txs = ObservableList<TxData>();

  @observable
  ObservableList<TxRewardData> txsRewards = ObservableList<TxRewardData>();

  @observable
  ObservableMap<String, dynamic> rewardsChartDataCache =
      ObservableMap<String, dynamic>();

  @observable
  ObservableMap<String, dynamic> stakesChartDataCache =
      ObservableMap<String, dynamic>();

  @observable
  Map recommendedValidators = {};

  @computed
  List<ValidatorData> get nextUpsInfo {
    if (overview['waiting'] != null) {
      List<ValidatorData> list = List.of(overview['waiting']).map((i) {
        ValidatorData validator = ValidatorData();
        validator.accountId = i;
        return validator;
      }).toList();
      return list;
    }
    return [];
  }

  @computed
  List<ValidatorData> get validatorsAll {
    List<ValidatorData> res = validatorsInfo.toList();
    res.addAll(nextUpsInfo);
    return res;
  }

  @computed
  List<ValidatorData> get nominatingList {
    if (ownStashInfo == null ||
        ownStashInfo.nominating == null ||
        ownStashInfo.nominating.length == 0) {
      return [];
    }
    return List.of(validatorsInfo
        .where((i) => ownStashInfo.nominating.indexOf(i.accountId) >= 0));
  }

  @computed
  Map<String, List> get nominationsAll {
    if (overview['nominators'] == null) {
      return {};
    }
    return Map<String, List>.from(overview['nominators']);
  }

  @computed
  BigInt get accountUnlockingTotal {
    BigInt res = BigInt.zero;
    if (ownStashInfo == null || ownStashInfo.stakingLedger == null) {
      return res;
    }

    List.of(ownStashInfo.stakingLedger['unlocking']).forEach((i) {
      res += BigInt.parse(i['value'].toString());
    });
    return res;
  }

  @action
  void setValidatorsInfo(Map data, {bool shouldCache = true}) {
    BigInt totalStaked = BigInt.zero;
    var nominators = {};
    List<ValidatorData> ls = List<ValidatorData>();

    data['info'].forEach((i) {
      i['points'] = overview['eraPoints'] != null
          ? overview['eraPoints']['individual'][i['accountId']]
          : 0;
      ValidatorData data = ValidatorData.fromJson(i);
      totalStaked += data.total;
      data.nominators.forEach((n) {
        nominators[n['who']] = true;
      });
      ls.add(data);
    });
    ls.sort((a, b) => a.total > b.total ? -1 : 1);
    validatorsInfo = ls;
    staked = totalStaked;
    nominatorCount = nominators.keys.length;

    // cache data
    if (shouldCache) {
      cache.validatorsInfo.val = data;
    }
  }

  @action
  void setOverview(Map data, {bool shouldCache = true}) {
    data.keys.forEach((key) => overview[key] = data[key]);

    // show validator's address before we got elected detail info
    if (validatorsInfo.length == 0 && data['validators'] != null) {
      List<ValidatorData> list = List.of(data['validators']).map((i) {
        ValidatorData validator = ValidatorData();
        validator.accountId = i;
        return validator;
      }).toList();
      validatorsInfo = list;
    }

    if (shouldCache) {
      // saving nominators data into GetStorage may cause error,
      // so we remove it before saving.
      data.remove('nominators');
      cache.stakingOverview.val = data;
    }
  }

  @action
  void setOwnStashInfo(String pubKey, Map data, {bool shouldCache = true}) {
    ownStashInfo = OwnStashInfoData.fromJson(data);

    if (shouldCache) {
      final cached = cache.stakingOwnStash.val;
      cached[pubKey] = data;
      cache.stakingOwnStash.val = cached;
    }
  }

  @action
  void setAccountBondedMap(Map<String, AccountBondedInfo> data) {
    accountBondedMap = data;
  }

  @action
  Future<void> setTxsLoading(bool loading) async {
    txsLoading = loading;
  }

  @action
  Future<void> addTxs(Map data, String pubKey,
      {bool shouldCache = false, reset = false}) async {
    if (data == null || data['extrinsics'] == null) return;
    txsCount = data['count'];

    List<TxData> ls =
        List.of(data['extrinsics']).map((i) => TxData.fromJson(i)).toList();

    if (reset) {
      txs.clear();
    }
    txs.addAll(ls);

    if (shouldCache) {
      final cached = cache.stakingTxs.val;
      cached[pubKey] = data;
      cache.stakingTxs.val = cached;
    }
  }

  @action
  Future<void> addTxsRewards(Map data, String pubKey,
      {bool shouldCache = false}) async {
    if (data['list'] == null) return;
    List<TxRewardData> ls =
        List.of(data['list']).map((i) => TxRewardData.fromJson(i)).toList();

    txsRewards = ObservableList.of(ls);

    if (shouldCache) {
      final cached = cache.stakingRewardTxs.val;
      cached[pubKey] = data;
      cache.stakingRewardTxs.val = cached;
    }
  }

  @action
  void setRewardsChartData(String validatorId, Map data) {
    rewardsChartDataCache[validatorId] = data;
  }

  @action
  void setStakesChartData(String validatorId, Map data) {
    stakesChartDataCache[validatorId] = data;
  }

  @action
  Future<void> loadAccountCache(String pubKey) async {
    // return if currentAccount not exist
    if (pubKey == null || pubKey.isEmpty) {
      return;
    }

    if (cache.stakingOwnStash.val[pubKey] != null) {
      ownStashInfo =
          OwnStashInfoData.fromJson(cache.stakingOwnStash.val[pubKey]);
    } else {
      ownStashInfo = null;
    }
    if (cache.stakingTxs.val[pubKey] != null) {
      addTxs(cache.stakingTxs.val[pubKey], pubKey);
    } else {
      txs.clear();
    }
    if (cache.stakingRewardTxs.val[pubKey] != null) {
      addTxsRewards(cache.stakingRewardTxs.val[pubKey], pubKey);
    } else {
      txsRewards.clear();
    }
  }

  @action
  Future<void> loadCache(String pubKey) async {
    if (cache.stakingOverview.val.keys.length > 0) {
      setOverview(cache.stakingOverview.val, shouldCache: false);
    } else {
      overview = ObservableMap<String, dynamic>();
    }

    if (cache.validatorsInfo.val.keys.length > 0) {
      setValidatorsInfo(cache.validatorsInfo.val, shouldCache: false);
    } else {
      setValidatorsInfo({'info': []}, shouldCache: false);
    }

    loadAccountCache(pubKey);
  }

  @action
  Future<void> setRecommendedValidatorList(Map data) async {
    recommendedValidators = data;
  }
}
