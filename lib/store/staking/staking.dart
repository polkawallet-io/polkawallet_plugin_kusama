import 'package:mobx/mobx.dart';
import 'package:polkawallet_sdk/api/types/staking/accountBondedInfo.dart';
import 'package:polkawallet_sdk/api/types/staking/ownStashInfo.dart';
import 'package:polkawallet_sdk/api/types/txData.dart';
import 'package:polkawallet_plugin_chainx/store/cache/storeCache.dart';
import 'package:polkawallet_plugin_chainx/store/staking/types/txData.dart';
import 'package:polkawallet_plugin_chainx/store/staking/types/validatorData.dart';
import 'package:polkawallet_plugin_chainx/store/staking/types/nominationData.dart';
import 'package:polkawallet_plugin_chainx/store/staking/types/userInterestData.dart';

part 'staking.g.dart';

class StakingStore extends _StakingStore with _$StakingStore {
  StakingStore(StoreCache cache) : super(cache);
}

abstract class _StakingStore with Store {
  _StakingStore(this.cache);

  final StoreCache cache;

  @observable
  List<ValidatorData> validatorsInfo = List<ValidatorData>();

  @observable
  Map overview = Map();

  @observable
  Map nominationsMap = Map();

  @observable
  List<UserInterestData> userInterests = List<UserInterestData>();

  @observable
  List<NominationData> validNominations = List<NominationData>();

  @observable
  OwnStashInfoData ownStashInfo;

  @observable
  Map<String, AccountBondedInfo> accountBondedMap = Map<String, AccountBondedInfo>();

  @observable
  bool txsLoading = false;

  @observable
  int txsCount = 0;

  @observable
  ObservableList<TxData> txs = ObservableList<TxData>();

  @observable
  ObservableList<TxRewardData> txsRewards = ObservableList<TxRewardData>();

  @observable
  ObservableMap<String, dynamic> rewardsChartDataCache = ObservableMap<String, dynamic>();

  @observable
  ObservableMap<String, dynamic> stakesChartDataCache = ObservableMap<String, dynamic>();

  @observable
  Map recommendedValidators = {};

  @computed
  List<ValidatorData> get nominatingList {
    if (ownStashInfo == null || ownStashInfo.nominating == null || ownStashInfo.nominating.length == 0) {
      return [];
    }
    return List.of(validatorsInfo.where((i) => ownStashInfo.nominating.indexOf(i.accountId) >= 0));
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
    if (data['validators'] == null) return;

    print('setValidatorsInfo func: $data');

    // all validators
    final validatorsAll = List.of(data['validators']).map((i) => ValidatorData.fromJson(i)).toList();
    validatorsInfo = validatorsAll;

    // cache data
    if (shouldCache) {
      cache.validatorsInfo.val = data;
    }
  }

  bool filterNomination(NominationData nmn, List<UserInterestData> userInterests) {
    if (userInterests.length == 0) return false;
    List<Dividended> interestNode = userInterests[0].interests.where((i) => i.validator == nmn.validatorId);
    bool blInterestNode = interestNode.length > 0 && BigInt.parse(interestNode[0].interest) != BigInt.zero ? true : false;
    BigInt chunks = BigInt.zero;

    nmn.unbondedChunks?.forEach((chunk) => {chunks += BigInt.parse(chunk.value)});

    if (BigInt.parse(nmn.nomination) == BigInt.zero) return false;
    if (chunks == BigInt.zero) return false;
    if (!blInterestNode) return false;
    return true;
  }

  @action
  void setNominations(Map data, String currentAccount) {
    userInterests = List.of(data['allDividended']).map((i) => UserInterestData.fromJson(i)).where((dvd) => dvd.account == currentAccount).toList();
    validNominations = List.of(data['allNominations']).map((i) => NominationData.fromJson(i)).where((nmn) => filterNomination(nmn, userInterests)).toList();
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
  Future<void> addTxs(Map data, String pubKey, {bool shouldCache = false, reset = false}) async {
    if (data == null || data['extrinsics'] == null) return;
    txsCount = data['count'];

    List<TxData> ls = List.of(data['extrinsics']).map((i) => TxData.fromJson(i)).toList();

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
  Future<void> addTxsRewards(Map data, String pubKey, {bool shouldCache = false}) async {
    if (data['list'] == null) return;
    List<TxRewardData> ls = List.of(data['list']).map((i) => TxRewardData.fromJson(i)).toList();

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
      ownStashInfo = OwnStashInfoData.fromJson(cache.stakingOwnStash.val[pubKey]);
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
    if (cache.validatorsInfo.val.keys.length > 0) {
      setValidatorsInfo(cache.validatorsInfo.val, shouldCache: false);
    } else {
      setValidatorsInfo(
        {'validators': [], 'waitingIds': []},
        shouldCache: false,
      );
    }

    loadAccountCache(pubKey);
  }

  @action
  Future<void> setRecommendedValidatorList(Map data) async {
    recommendedValidators = data;
  }
}
