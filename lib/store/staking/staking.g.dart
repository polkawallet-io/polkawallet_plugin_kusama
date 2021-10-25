// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staking.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$StakingStore on _StakingStore, Store {
  Computed<List<ValidatorData>>? _$nominatingListComputed;

  @override
  List<ValidatorData> get nominatingList => (_$nominatingListComputed ??=
          Computed<List<ValidatorData>>(() => super.nominatingList,
              name: '_StakingStore.nominatingList'))
      .value;
  Computed<BigInt>? _$accountUnlockingTotalComputed;

  @override
  BigInt get accountUnlockingTotal => (_$accountUnlockingTotalComputed ??=
          Computed<BigInt>(() => super.accountUnlockingTotal,
              name: '_StakingStore.accountUnlockingTotal'))
      .value;

  final _$validatorsInfoAtom = Atom(name: '_StakingStore.validatorsInfo');

  @override
  List<ValidatorData> get validatorsInfo {
    _$validatorsInfoAtom.reportRead();
    return super.validatorsInfo;
  }

  @override
  set validatorsInfo(List<ValidatorData> value) {
    _$validatorsInfoAtom.reportWrite(value, super.validatorsInfo, () {
      super.validatorsInfo = value;
    });
  }

  final _$electedInfoAtom = Atom(name: '_StakingStore.electedInfo');

  @override
  List<ValidatorData> get electedInfo {
    _$electedInfoAtom.reportRead();
    return super.electedInfo;
  }

  @override
  set electedInfo(List<ValidatorData> value) {
    _$electedInfoAtom.reportWrite(value, super.electedInfo, () {
      super.electedInfo = value;
    });
  }

  final _$nextUpsInfoAtom = Atom(name: '_StakingStore.nextUpsInfo');

  @override
  List<ValidatorData> get nextUpsInfo {
    _$nextUpsInfoAtom.reportRead();
    return super.nextUpsInfo;
  }

  @override
  set nextUpsInfo(List<ValidatorData> value) {
    _$nextUpsInfoAtom.reportWrite(value, super.nextUpsInfo, () {
      super.nextUpsInfo = value;
    });
  }

  final _$overviewAtom = Atom(name: '_StakingStore.overview');

  @override
  Map<dynamic, dynamic> get overview {
    _$overviewAtom.reportRead();
    return super.overview;
  }

  @override
  set overview(Map<dynamic, dynamic> value) {
    _$overviewAtom.reportWrite(value, super.overview, () {
      super.overview = value;
    });
  }

  final _$nominationsMapAtom = Atom(name: '_StakingStore.nominationsMap');

  @override
  Map<dynamic, dynamic>? get nominationsMap {
    _$nominationsMapAtom.reportRead();
    return super.nominationsMap;
  }

  @override
  set nominationsMap(Map<dynamic, dynamic>? value) {
    _$nominationsMapAtom.reportWrite(value, super.nominationsMap, () {
      super.nominationsMap = value;
    });
  }

  final _$ownStashInfoAtom = Atom(name: '_StakingStore.ownStashInfo');

  @override
  OwnStashInfoData? get ownStashInfo {
    _$ownStashInfoAtom.reportRead();
    return super.ownStashInfo;
  }

  @override
  set ownStashInfo(OwnStashInfoData? value) {
    _$ownStashInfoAtom.reportWrite(value, super.ownStashInfo, () {
      super.ownStashInfo = value;
    });
  }

  final _$accountBondedMapAtom = Atom(name: '_StakingStore.accountBondedMap');

  @override
  Map<String?, AccountBondedInfo> get accountBondedMap {
    _$accountBondedMapAtom.reportRead();
    return super.accountBondedMap;
  }

  @override
  set accountBondedMap(Map<String?, AccountBondedInfo> value) {
    _$accountBondedMapAtom.reportWrite(value, super.accountBondedMap, () {
      super.accountBondedMap = value;
    });
  }

  final _$txsLoadingAtom = Atom(name: '_StakingStore.txsLoading');

  @override
  bool get txsLoading {
    _$txsLoadingAtom.reportRead();
    return super.txsLoading;
  }

  @override
  set txsLoading(bool value) {
    _$txsLoadingAtom.reportWrite(value, super.txsLoading, () {
      super.txsLoading = value;
    });
  }

  final _$txsAtom = Atom(name: '_StakingStore.txs');

  @override
  ObservableList<TxData> get txs {
    _$txsAtom.reportRead();
    return super.txs;
  }

  @override
  set txs(ObservableList<TxData> value) {
    _$txsAtom.reportWrite(value, super.txs, () {
      super.txs = value;
    });
  }

  final _$txsRewardsAtom = Atom(name: '_StakingStore.txsRewards');

  @override
  ObservableList<TxRewardData> get txsRewards {
    _$txsRewardsAtom.reportRead();
    return super.txsRewards;
  }

  @override
  set txsRewards(ObservableList<TxRewardData> value) {
    _$txsRewardsAtom.reportWrite(value, super.txsRewards, () {
      super.txsRewards = value;
    });
  }

  final _$rewardsChartDataCacheAtom =
      Atom(name: '_StakingStore.rewardsChartDataCache');

  @override
  ObservableMap<String, dynamic> get rewardsChartDataCache {
    _$rewardsChartDataCacheAtom.reportRead();
    return super.rewardsChartDataCache;
  }

  @override
  set rewardsChartDataCache(ObservableMap<String, dynamic> value) {
    _$rewardsChartDataCacheAtom.reportWrite(value, super.rewardsChartDataCache,
        () {
      super.rewardsChartDataCache = value;
    });
  }

  final _$recommendedValidatorsAtom =
      Atom(name: '_StakingStore.recommendedValidators');

  @override
  Map<dynamic, dynamic>? get recommendedValidators {
    _$recommendedValidatorsAtom.reportRead();
    return super.recommendedValidators;
  }

  @override
  set recommendedValidators(Map<dynamic, dynamic>? value) {
    _$recommendedValidatorsAtom.reportWrite(value, super.recommendedValidators,
        () {
      super.recommendedValidators = value;
    });
  }

  final _$setTxsLoadingAsyncAction = AsyncAction('_StakingStore.setTxsLoading');

  @override
  Future<void> setTxsLoading(bool loading) {
    return _$setTxsLoadingAsyncAction.run(() => super.setTxsLoading(loading));
  }

  final _$addTxsAsyncAction = AsyncAction('_StakingStore.addTxs');

  @override
  Future<void> addTxs(Map<dynamic, dynamic>? data, String? pubKey,
      {bool shouldCache = false, dynamic reset = false}) {
    return _$addTxsAsyncAction.run(() =>
        super.addTxs(data, pubKey, shouldCache: shouldCache, reset: reset));
  }

  final _$addTxsRewardsAsyncAction = AsyncAction('_StakingStore.addTxsRewards');

  @override
  Future<void> addTxsRewards(Map<dynamic, dynamic> data, String? pubKey,
      {bool shouldCache = false}) {
    return _$addTxsRewardsAsyncAction
        .run(() => super.addTxsRewards(data, pubKey, shouldCache: shouldCache));
  }

  final _$loadAccountCacheAsyncAction =
      AsyncAction('_StakingStore.loadAccountCache');

  @override
  Future<void> loadAccountCache(String? pubKey) {
    return _$loadAccountCacheAsyncAction
        .run(() => super.loadAccountCache(pubKey));
  }

  final _$loadCacheAsyncAction = AsyncAction('_StakingStore.loadCache');

  @override
  Future<void> loadCache(String? pubKey) {
    return _$loadCacheAsyncAction.run(() => super.loadCache(pubKey));
  }

  final _$setRecommendedValidatorListAsyncAction =
      AsyncAction('_StakingStore.setRecommendedValidatorList');

  @override
  Future<void> setRecommendedValidatorList(Map<dynamic, dynamic>? data) {
    return _$setRecommendedValidatorListAsyncAction
        .run(() => super.setRecommendedValidatorList(data));
  }

  final _$_StakingStoreActionController =
      ActionController(name: '_StakingStore');

  @override
  void setValidatorsInfo(Map<dynamic, dynamic> data,
      {bool shouldCache = true}) {
    final _$actionInfo = _$_StakingStoreActionController.startAction(
        name: '_StakingStore.setValidatorsInfo');
    try {
      return super.setValidatorsInfo(data, shouldCache: shouldCache);
    } finally {
      _$_StakingStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setNominations(Map<dynamic, dynamic>? data) {
    final _$actionInfo = _$_StakingStoreActionController.startAction(
        name: '_StakingStore.setNominations');
    try {
      return super.setNominations(data);
    } finally {
      _$_StakingStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setOwnStashInfo(String? pubKey, Map<dynamic, dynamic> data,
      {bool shouldCache = true}) {
    final _$actionInfo = _$_StakingStoreActionController.startAction(
        name: '_StakingStore.setOwnStashInfo');
    try {
      return super.setOwnStashInfo(pubKey, data, shouldCache: shouldCache);
    } finally {
      _$_StakingStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setAccountBondedMap(Map<String?, AccountBondedInfo> data) {
    final _$actionInfo = _$_StakingStoreActionController.startAction(
        name: '_StakingStore.setAccountBondedMap');
    try {
      return super.setAccountBondedMap(data);
    } finally {
      _$_StakingStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setRewardsChartData(String validatorId, Map<dynamic, dynamic> data) {
    final _$actionInfo = _$_StakingStoreActionController.startAction(
        name: '_StakingStore.setRewardsChartData');
    try {
      return super.setRewardsChartData(validatorId, data);
    } finally {
      _$_StakingStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
validatorsInfo: ${validatorsInfo},
electedInfo: ${electedInfo},
nextUpsInfo: ${nextUpsInfo},
overview: ${overview},
nominationsMap: ${nominationsMap},
ownStashInfo: ${ownStashInfo},
accountBondedMap: ${accountBondedMap},
txsLoading: ${txsLoading},
txs: ${txs},
txsRewards: ${txsRewards},
rewardsChartDataCache: ${rewardsChartDataCache},
recommendedValidators: ${recommendedValidators},
nominatingList: ${nominatingList},
accountUnlockingTotal: ${accountUnlockingTotal}
    ''';
  }
}
