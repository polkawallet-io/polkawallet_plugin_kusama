import 'package:mobx/mobx.dart';
import 'package:polkawallet_plugin_kusama/store/cache/storeCache.dart';

import 'package:polkawallet_sdk/api/types/gov/proposalInfoData.dart';
import 'package:polkawallet_sdk/api/types/gov/councilInfoData.dart';
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
  int cacheCouncilTimestamp = 0;

  @observable
  int bestNumber = 0;

  @observable
  CouncilInfoData council = CouncilInfoData();

  @observable
  List<CouncilMotionData> councilMotions = [];

  @observable
  Map<String, Map<String, dynamic>> councilVotes;

  @observable
  Map<String, dynamic> userCouncilVotes;

  @observable
  List<ReferendumInfo> referendums;

  @observable
  List voteConvictions;

  @observable
  List<ProposalInfoData> proposals = [];

  @observable
  TreasuryOverviewData treasuryOverview = TreasuryOverviewData();

  @observable
  List<TreasuryTipData> treasuryTips;

  @action
  void setCouncilInfo(Map info, {bool shouldCache = true}) {
    council = CouncilInfoData.fromJson(info);

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
  void setBestNumber(int number) {
    bestNumber = number;
  }

  @action
  void setReferendums(List<ReferendumInfo> ls) {
    referendums = ls;
  }

  @action
  void setReferendumVoteConvictions(List ls) {
    voteConvictions = ls;
  }

  @action
  void setProposals(List<ProposalInfoData> ls) {
    proposals = ls;
  }

  @action
  Future<void> loadCache() async {
    final data = cache.councilInfo.val;
    if (data != null) {
      setCouncilInfo(data['data'], shouldCache: false);
      cacheCouncilTimestamp = data['cacheTime'];
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
    proposals = [];
    council = CouncilInfoData();
    councilMotions = [];
    treasuryOverview = TreasuryOverviewData();
    treasuryTips = [];
  }
}
