import 'package:get/get.dart';
import 'package:polkawallet_plugin_kusama/store/cache/storeCache.dart';
import 'package:polkawallet_plugin_kusama/store/staking/types/txData.dart';
import 'package:polkawallet_plugin_kusama/store/staking/types/validatorData.dart';
import 'package:polkawallet_sdk/api/types/staking/accountBondedInfo.dart';
import 'package:polkawallet_sdk/api/types/staking/ownStashInfo.dart';
import 'package:polkawallet_sdk/api/types/txData.dart';

class StakingStore extends GetxController {
  StakingStore(this.cache);

  final StoreCache cache;

  List<ValidatorData> validatorsInfo = [];

  List<ValidatorData> electedInfo = [];

  List<ValidatorData> nextUpsInfo = [];

  Map overview = Map();

  Map? nominationsMap = Map();

  OwnStashInfoData? ownStashInfo;

  Map<String?, AccountBondedInfo> accountBondedMap =
      Map<String, AccountBondedInfo>();

  bool txsLoading = false;

  List<TxData> txs = <TxData>[];

  List<TxRewardData> txsRewards = <TxRewardData>[];

  Map<String, dynamic> rewardsChartDataCache = Map<String, dynamic>();

  Map? recommendedValidators = {};

  List<ValidatorData> get nominatingList {
    if (ownStashInfo == null ||
        ownStashInfo!.nominating == null ||
        ownStashInfo!.nominating!.length == 0) {
      return [];
    }
    return List.of(validatorsInfo
        .where((i) => ownStashInfo!.nominating!.indexOf(i.accountId!) >= 0));
  }

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

  void setValidatorsInfo(Map data, {bool shouldCache = true}) {
    if (data['validators'] == null) return;

    final inflation = data['inflation'];
    overview = {
      'stakedReturn': inflation != null ? inflation['stakedReturn'] : 0,
      'totalStaked': data['totalStaked'],
      'totalIssuance': data['totalIssuance'],
      'minNominated': data['minNominated'],
      'minNominatorBond': data['minNominatorBond'],
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
    update();
  }

  void setNominations(Map? data) {
    nominationsMap = data;
    update();
  }

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
    update();
  }

  void setAccountBondedMap(Map<String?, AccountBondedInfo> data) {
    accountBondedMap = data;
    update();
  }

  Future<void> setTxsLoading(bool loading) async {
    txsLoading = loading;
    update();
  }

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
    update();
  }

  Future<void> addTxsRewards(Map data, String? pubKey,
      {bool shouldCache = false}) async {
    if (data['list'] == null) return;
    List<TxRewardData> ls =
        List.of(data['list']).map((i) => TxRewardData.fromJson(i)).toList();

    txsRewards = ls;

    if (shouldCache) {
      final cached = cache.stakingRewardTxs.val;
      cached[pubKey] = data;
      cache.stakingRewardTxs.val = cached;
    }
    update();
  }

  void setRewardsChartData(String validatorId, Map data) {
    rewardsChartDataCache[validatorId] = data;
    update();
  }

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
    update();
  }

  Future<void> loadCache(String? pubKey) async {
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

  Future<void> setRecommendedValidatorList(Map? data) async {
    recommendedValidators = data;
    update();
  }
}
