import 'package:mobx/mobx.dart';
import 'package:polkawallet_plugin_kusama/store/cache/storeCache.dart';
import 'package:polkawallet_plugin_kusama/store/staking/types/txData.dart';
import 'package:polkawallet_plugin_kusama/store/staking/types/validatorData.dart';
import 'package:polkawallet_sdk/api/types/staking/accountBondedInfo.dart';
import 'package:polkawallet_sdk/api/types/staking/ownStashInfo.dart';
import 'package:polkawallet_sdk/api/types/txData.dart';

part 'staking.g.dart';

class StakingStore extends _StakingStore with _$StakingStore {
  StakingStore(StoreCache cache) : super(cache);
}

abstract class _StakingStore with Store {
  _StakingStore(this.cache);

  final StoreCache cache;

  @observable
  List<ValidatorData> validatorsInfo = [];

  @observable
  List<ValidatorData> electedInfo = [];

  @observable
  List<ValidatorData> nextUpsInfo = [];

  @observable
  Map overview = Map();

  @observable
  Map? nominationsMap = Map();

  @observable
  Map? nominationsCount = Map();

  @observable
  OwnStashInfoData? ownStashInfo;

  @observable
  Map<String?, AccountBondedInfo> accountBondedMap =
      Map<String, AccountBondedInfo>();

  @observable
  bool txsLoading = false;

  @observable
  ObservableList<TxData> txs = ObservableList<TxData>();

  @observable
  ObservableList<TxRewardData> txsRewards = ObservableList<TxRewardData>();

  @observable
  ObservableMap<String, dynamic> rewardsChartDataCache =
      ObservableMap<String, dynamic>();

  @observable
  ObservableMap<String?, double> marketPrices = ObservableMap();

  // @observable
  // Map? recommendedValidators = {};

  @computed
  List<ValidatorData> get nominatingList {
    if (ownStashInfo == null ||
        ownStashInfo!.nominating == null ||
        ownStashInfo!.nominating!.length == 0) {
      return [];
    }
    return List.of(validatorsInfo
        .where((i) => ownStashInfo!.nominating!.indexOf(i.accountId!) >= 0));
  }

  @computed
  BigInt get accountUnlockingTotal {
    BigInt res = BigInt.zero;
    if (ownStashInfo == null || ownStashInfo!.stakingLedger == null) {
      return res;
    }

    List.of(ownStashInfo!.stakingLedger!['unlocking']).forEach((i) {
      res += BigInt.parse(i['value'].toString());
    });
    return res;
  }

  @action
  void setMarketPrices(Map<String?, double> data) {
    marketPrices.addAll(data);
  }

  @action
  void setValidatorsInfo(Map data, {bool shouldCache = true}) {
    if (data['validators'] == null) return;

    final inflation = data['inflation'];
    overview = {
      'stakedReturn': inflation != null ? inflation['stakedReturn'] : 0,
      'totalStaked': data['totalStaked'],
      'totalIssuance': data['totalIssuance'],
      'minNominated': data['minNominated'],
      'minNominatorBond': data['minNominatorBond'],
      'counterForNominators': data['counterForNominators'],
      'lastReward': data['lastReward'],
    };

    // all validators
    final validatorsAll = List.of(data['validators'])
        .map((i) => ValidatorData.fromJson(i))
        .toList();
    validatorsInfo = validatorsAll;

    List<ValidatorData> elected = [];
    List<ValidatorData> waiting = [];
    validatorsAll.forEach((e) {
      if (e.isActive!) {
        elected.add(e);
      } else {
        waiting.add(e);
      }
    });

    // elected validators
    // final elected = validatorsAll.toList();
    // elected.removeWhere((e) => !e.isElected);
    electedInfo = elected;

    // waiting validators
    nextUpsInfo = waiting;
    // nextUpsInfo = List.of(data['waitingIds']).map((i) {
    //   final e = ValidatorData();
    //   e.accountId = i;
    //   return e;
    // }).toList();

    // cache data
    if (shouldCache) {
      cache.validatorsInfo.val = data;
    }
  }

  @action
  void setNominations(Map? data) {
    nominationsMap = data;
  }

  @action
  void setNominationsCount(Map? data) {
    nominationsCount = data;
  }

  @action
  void setOwnStashInfo(String? pubKey, Map data, {bool shouldCache = true}) {
    ownStashInfo = OwnStashInfoData.fromJson(data as Map<String, dynamic>);

    if (shouldCache) {
      final cached = cache.stakingOwnStash.val;
      cached[pubKey] = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'data': data
      };
      cache.stakingOwnStash.val = cached;
    }
  }

  @action
  void setAccountBondedMap(Map<String?, AccountBondedInfo> data) {
    accountBondedMap = data;
  }

  @action
  Future<void> setTxsLoading(bool loading) async {
    txsLoading = loading;
  }

  @action
  Future<void> addTxs(Map? data, String? pubKey,
      {bool shouldCache = false, reset = false}) async {
    if (data == null || data['extrinsics'] == null) return;

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
  Future<void> addTxsRewards(Map? data, String? pubKey,
      {bool shouldCache = false}) async {
    if (data == null || data['list'] == null) {
      txsRewards = ObservableList.of([]);
    } else {
      List<TxRewardData> ls =
          List.of(data['list']).map((i) => TxRewardData.fromJson(i)).toList();
      ls.retainWhere((element) => double.parse(element.amount ?? "0") != 0);

      txsRewards = ObservableList.of(ls);
    }

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
  Future<void> loadAccountCache(String? pubKey) async {
    // return if currentAccount not exist
    if (pubKey == null || pubKey.isEmpty) {
      return;
    }

    final stashInfo = cache.stakingOwnStash.val[pubKey];
    if (stashInfo != null &&
        stashInfo['timestamp'] != null &&
        stashInfo['timestamp'] + 24 * 3600 * 1000 >
            DateTime.now().millisecondsSinceEpoch) {
      ownStashInfo = OwnStashInfoData.fromJson(stashInfo['data']);
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
  Future<void> loadCache(String? pubKey) async {
    if (cache.validatorsInfo.val.keys.length > 0) {
      setValidatorsInfo(cache.validatorsInfo.val, shouldCache: false);
    } else {
      setValidatorsInfo(
        {'validators': [], 'waitingIds': []},
        shouldCache: false,
      );
    }

    // reset bondedMap
    accountBondedMap = {};

    loadAccountCache(pubKey);
  }

  // @action
  // Future<void> setRecommendedValidatorList(Map? data) async {
  //   recommendedValidators = data;
  // }
}
