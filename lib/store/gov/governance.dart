import 'package:mobx/mobx.dart';
import 'package:polkawallet_plugin_kusama/store/cache/storeCache.dart';
import 'package:polkawallet_sdk/api/types/gov/councilInfoData.dart';
import 'package:polkawallet_sdk/api/types/gov/proposalInfoData.dart';
import 'package:polkawallet_sdk/api/types/gov/referendumInfoData.dart';
import 'package:polkawallet_sdk/api/types/gov/treasuryOverviewData.dart';
import 'package:polkawallet_sdk/api/types/gov/treasuryTipData.dart';

part 'governance.g.dart';

class GovernanceStore extends _GovernanceStore with _$GovernanceStore {
  GovernanceStore(StoreCache cache) : super(cache);
}

abstract class _GovernanceStore with Store {
  _GovernanceStore(this.cache);

  final StoreCache cache;

  @observable
  int? cacheCouncilTimestamp = 0;

  @observable
  BigInt bestNumber = BigInt.zero;

  @observable
  CouncilInfoData council = CouncilInfoData();

  @observable
  List<CouncilMotionData> councilMotions = [];

  @observable
  Map<String, Map<String, dynamic>>? councilVotes;

  @observable
  Map<String, dynamic>? userCouncilVotes;

  @observable
  List<ReferendumInfo>? referendums;

  @observable
  Map referendumStatus = {};

  @observable
  List? voteConvictions;

  @observable
  List<ProposalInfoData> proposals = [];

  @observable
  TreasuryOverviewData treasuryOverview = TreasuryOverviewData();

  @observable
  List<TreasuryTipData>? treasuryTips;

  @observable
  ProposalInfoData? external;

  @action
  void setExternal(ProposalInfoData? data) {
    external = data;
  }

  @action
  void setCouncilInfo(Map info, {bool shouldCache = true}) {
    council = CouncilInfoData.fromJson(info as Map<String, dynamic>);

    if (shouldCache) {
      cacheCouncilTimestamp = DateTime.now().millisecondsSinceEpoch;
      cache.councilInfo.val = {
        'data': info,
        'cacheTime': cacheCouncilTimestamp
      };
    }
  }

  @action
  void setCouncilVotes(Map votes) {
    councilVotes = Map<String, Map<String, dynamic>>.from(votes);
  }

  @action
  void setUserCouncilVotes(Map votes) {
    userCouncilVotes = Map<String, dynamic>.from(votes);
  }

  @action
  void setBestNumber(BigInt number) {
    bestNumber = number;
  }

  @action
  void setReferendums(List<ReferendumInfo> ls) {
    referendums = ls;
  }

  @action
  void setReferendumStatus(Map data) {
    referendumStatus = data;
  }

  @action
  void setReferendumVoteConvictions(List? ls) {
    voteConvictions = ls;
  }

  @action
  void setProposals(List<ProposalInfoData> ls) {
    proposals = ls;
  }

  @action
  Future<void> loadCache() async {
    if (cache.councilInfo.val['data'] != null) {
      setCouncilInfo(cache.councilInfo.val['data'], shouldCache: false);
      cacheCouncilTimestamp = cache.councilInfo.val['cacheTime'];
    } else {
      setCouncilInfo(Map<String, dynamic>(), shouldCache: false);
    }
  }

  @action
  void setTreasuryOverview(TreasuryOverviewData data) {
    treasuryOverview = data;
  }

  @action
  void setTreasuryTips(List<TreasuryTipData> data) {
    treasuryTips = data;
  }

  @action
  void setCouncilMotions(List<CouncilMotionData> data) {
    councilMotions = data;
  }

  @action
  void clearState() {
    referendums = [];
    referendumStatus = {};
    proposals = [];
    councilMotions = [];
    treasuryOverview = TreasuryOverviewData();
    treasuryTips = [];
  }
}
