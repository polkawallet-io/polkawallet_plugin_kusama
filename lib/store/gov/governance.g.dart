// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'governance.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$GovernanceStore on _GovernanceStore, Store {
  final _$cacheCouncilTimestampAtom =
      Atom(name: '_GovernanceStore.cacheCouncilTimestamp');

  @override
  int? get cacheCouncilTimestamp {
    _$cacheCouncilTimestampAtom.reportRead();
    return super.cacheCouncilTimestamp;
  }

  @override
  set cacheCouncilTimestamp(int? value) {
    _$cacheCouncilTimestampAtom.reportWrite(value, super.cacheCouncilTimestamp,
        () {
      super.cacheCouncilTimestamp = value;
    });
  }

  final _$bestNumberAtom = Atom(name: '_GovernanceStore.bestNumber');

  @override
  BigInt get bestNumber {
    _$bestNumberAtom.reportRead();
    return super.bestNumber;
  }

  @override
  set bestNumber(BigInt value) {
    _$bestNumberAtom.reportWrite(value, super.bestNumber, () {
      super.bestNumber = value;
    });
  }

  final _$councilAtom = Atom(name: '_GovernanceStore.council');

  @override
  CouncilInfoData get council {
    _$councilAtom.reportRead();
    return super.council;
  }

  @override
  set council(CouncilInfoData value) {
    _$councilAtom.reportWrite(value, super.council, () {
      super.council = value;
    });
  }

  final _$councilMotionsAtom = Atom(name: '_GovernanceStore.councilMotions');

  @override
  List<CouncilMotionData> get councilMotions {
    _$councilMotionsAtom.reportRead();
    return super.councilMotions;
  }

  @override
  set councilMotions(List<CouncilMotionData> value) {
    _$councilMotionsAtom.reportWrite(value, super.councilMotions, () {
      super.councilMotions = value;
    });
  }

  final _$councilVotesAtom = Atom(name: '_GovernanceStore.councilVotes');

  @override
  Map<String, Map<String, dynamic>>? get councilVotes {
    _$councilVotesAtom.reportRead();
    return super.councilVotes;
  }

  @override
  set councilVotes(Map<String, Map<String, dynamic>>? value) {
    _$councilVotesAtom.reportWrite(value, super.councilVotes, () {
      super.councilVotes = value;
    });
  }

  final _$userCouncilVotesAtom =
      Atom(name: '_GovernanceStore.userCouncilVotes');

  @override
  Map<String, dynamic>? get userCouncilVotes {
    _$userCouncilVotesAtom.reportRead();
    return super.userCouncilVotes;
  }

  @override
  set userCouncilVotes(Map<String, dynamic>? value) {
    _$userCouncilVotesAtom.reportWrite(value, super.userCouncilVotes, () {
      super.userCouncilVotes = value;
    });
  }

  final _$referendumsAtom = Atom(name: '_GovernanceStore.referendums');

  @override
  List<ReferendumInfo>? get referendums {
    _$referendumsAtom.reportRead();
    return super.referendums;
  }

  @override
  set referendums(List<ReferendumInfo>? value) {
    _$referendumsAtom.reportWrite(value, super.referendums, () {
      super.referendums = value;
    });
  }

  final _$referendumStatusAtom =
      Atom(name: '_GovernanceStore.referendumStatus');

  @override
  Map<dynamic, dynamic> get referendumStatus {
    _$referendumStatusAtom.reportRead();
    return super.referendumStatus;
  }

  @override
  set referendumStatus(Map<dynamic, dynamic> value) {
    _$referendumStatusAtom.reportWrite(value, super.referendumStatus, () {
      super.referendumStatus = value;
    });
  }

  final _$voteConvictionsAtom = Atom(name: '_GovernanceStore.voteConvictions');

  @override
  List<dynamic>? get voteConvictions {
    _$voteConvictionsAtom.reportRead();
    return super.voteConvictions;
  }

  @override
  set voteConvictions(List<dynamic>? value) {
    _$voteConvictionsAtom.reportWrite(value, super.voteConvictions, () {
      super.voteConvictions = value;
    });
  }

  final _$proposalsAtom = Atom(name: '_GovernanceStore.proposals');

  @override
  List<ProposalInfoData> get proposals {
    _$proposalsAtom.reportRead();
    return super.proposals;
  }

  @override
  set proposals(List<ProposalInfoData> value) {
    _$proposalsAtom.reportWrite(value, super.proposals, () {
      super.proposals = value;
    });
  }

  final _$treasuryOverviewAtom =
      Atom(name: '_GovernanceStore.treasuryOverview');

  @override
  TreasuryOverviewData get treasuryOverview {
    _$treasuryOverviewAtom.reportRead();
    return super.treasuryOverview;
  }

  @override
  set treasuryOverview(TreasuryOverviewData value) {
    _$treasuryOverviewAtom.reportWrite(value, super.treasuryOverview, () {
      super.treasuryOverview = value;
    });
  }

  final _$treasuryTipsAtom = Atom(name: '_GovernanceStore.treasuryTips');

  @override
  List<TreasuryTipData>? get treasuryTips {
    _$treasuryTipsAtom.reportRead();
    return super.treasuryTips;
  }

  @override
  set treasuryTips(List<TreasuryTipData>? value) {
    _$treasuryTipsAtom.reportWrite(value, super.treasuryTips, () {
      super.treasuryTips = value;
    });
  }

  final _$externalAtom = Atom(name: '_GovernanceStore.external');

  @override
  ProposalInfoData? get external {
    _$externalAtom.reportRead();
    return super.external;
  }

  @override
  set external(ProposalInfoData? value) {
    _$externalAtom.reportWrite(value, super.external, () {
      super.external = value;
    });
  }

  final _$loadCacheAsyncAction = AsyncAction('_GovernanceStore.loadCache');

  @override
  Future<void> loadCache() {
    return _$loadCacheAsyncAction.run(() => super.loadCache());
  }

  final _$_GovernanceStoreActionController =
      ActionController(name: '_GovernanceStore');

  @override
  void setExternal(ProposalInfoData? data) {
    final _$actionInfo = _$_GovernanceStoreActionController.startAction(
        name: '_GovernanceStore.setExternal');
    try {
      return super.setExternal(data);
    } finally {
      _$_GovernanceStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCouncilInfo(Map<dynamic, dynamic> info, {bool shouldCache = true}) {
    final _$actionInfo = _$_GovernanceStoreActionController.startAction(
        name: '_GovernanceStore.setCouncilInfo');
    try {
      return super.setCouncilInfo(info, shouldCache: shouldCache);
    } finally {
      _$_GovernanceStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCouncilVotes(Map<dynamic, dynamic> votes) {
    final _$actionInfo = _$_GovernanceStoreActionController.startAction(
        name: '_GovernanceStore.setCouncilVotes');
    try {
      return super.setCouncilVotes(votes);
    } finally {
      _$_GovernanceStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setUserCouncilVotes(Map<dynamic, dynamic> votes) {
    final _$actionInfo = _$_GovernanceStoreActionController.startAction(
        name: '_GovernanceStore.setUserCouncilVotes');
    try {
      return super.setUserCouncilVotes(votes);
    } finally {
      _$_GovernanceStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setBestNumber(BigInt number) {
    final _$actionInfo = _$_GovernanceStoreActionController.startAction(
        name: '_GovernanceStore.setBestNumber');
    try {
      return super.setBestNumber(number);
    } finally {
      _$_GovernanceStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setReferendums(List<ReferendumInfo> ls) {
    final _$actionInfo = _$_GovernanceStoreActionController.startAction(
        name: '_GovernanceStore.setReferendums');
    try {
      return super.setReferendums(ls);
    } finally {
      _$_GovernanceStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setReferendumStatus(Map<dynamic, dynamic> data) {
    final _$actionInfo = _$_GovernanceStoreActionController.startAction(
        name: '_GovernanceStore.setReferendumStatus');
    try {
      return super.setReferendumStatus(data);
    } finally {
      _$_GovernanceStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setReferendumVoteConvictions(List<dynamic>? ls) {
    final _$actionInfo = _$_GovernanceStoreActionController.startAction(
        name: '_GovernanceStore.setReferendumVoteConvictions');
    try {
      return super.setReferendumVoteConvictions(ls);
    } finally {
      _$_GovernanceStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setProposals(List<ProposalInfoData> ls) {
    final _$actionInfo = _$_GovernanceStoreActionController.startAction(
        name: '_GovernanceStore.setProposals');
    try {
      return super.setProposals(ls);
    } finally {
      _$_GovernanceStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setTreasuryOverview(TreasuryOverviewData data) {
    final _$actionInfo = _$_GovernanceStoreActionController.startAction(
        name: '_GovernanceStore.setTreasuryOverview');
    try {
      return super.setTreasuryOverview(data);
    } finally {
      _$_GovernanceStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setTreasuryTips(List<TreasuryTipData> data) {
    final _$actionInfo = _$_GovernanceStoreActionController.startAction(
        name: '_GovernanceStore.setTreasuryTips');
    try {
      return super.setTreasuryTips(data);
    } finally {
      _$_GovernanceStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCouncilMotions(List<CouncilMotionData> data) {
    final _$actionInfo = _$_GovernanceStoreActionController.startAction(
        name: '_GovernanceStore.setCouncilMotions');
    try {
      return super.setCouncilMotions(data);
    } finally {
      _$_GovernanceStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearState() {
    final _$actionInfo = _$_GovernanceStoreActionController.startAction(
        name: '_GovernanceStore.clearState');
    try {
      return super.clearState();
    } finally {
      _$_GovernanceStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
cacheCouncilTimestamp: ${cacheCouncilTimestamp},
bestNumber: ${bestNumber},
council: ${council},
councilMotions: ${councilMotions},
councilVotes: ${councilVotes},
userCouncilVotes: ${userCouncilVotes},
referendums: ${referendums},
referendumStatus: ${referendumStatus},
voteConvictions: ${voteConvictions},
proposals: ${proposals},
treasuryOverview: ${treasuryOverview},
treasuryTips: ${treasuryTips},
external: ${external}
    ''';
  }
}
