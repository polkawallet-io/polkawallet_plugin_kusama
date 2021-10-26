import 'package:get/get.dart';
import 'package:polkawallet_plugin_kusama/store/cache/storeCache.dart';

import 'package:polkawallet_sdk/api/types/gov/proposalInfoData.dart';
import 'package:polkawallet_sdk/api/types/gov/councilInfoData.dart';
import 'package:polkawallet_sdk/api/types/gov/referendumInfoData.dart';
import 'package:polkawallet_sdk/api/types/gov/treasuryOverviewData.dart';
import 'package:polkawallet_sdk/api/types/gov/treasuryTipData.dart';

class GovernanceStore extends GetxController {
  GovernanceStore(this.cache);

  final StoreCache cache;

  int? cacheCouncilTimestamp = 0;

  BigInt bestNumber = BigInt.zero;

  CouncilInfoData council = CouncilInfoData();

  List<CouncilMotionData> councilMotions = [];

  Map<String, Map<String, dynamic>>? councilVotes;

  Map<String, dynamic>? userCouncilVotes;

  List<ReferendumInfo>? referendums;

  List? voteConvictions;

  List<ProposalInfoData> proposals = [];

  TreasuryOverviewData treasuryOverview = TreasuryOverviewData();

  List<TreasuryTipData>? treasuryTips;

  void setCouncilInfo(Map info, {bool shouldCache = true}) {
    council = CouncilInfoData.fromJson(info as Map<String, dynamic>);

    if (shouldCache) {
      cacheCouncilTimestamp = DateTime.now().millisecondsSinceEpoch;
      cache.councilInfo.val = {
        'data': info,
        'cacheTime': cacheCouncilTimestamp
      };
    }
    update();
  }

  void setCouncilVotes(Map votes) {
    councilVotes = Map<String, Map<String, dynamic>>.from(votes);
    update();
  }

  void setUserCouncilVotes(Map votes) {
    userCouncilVotes = Map<String, dynamic>.from(votes);
    update();
  }

  void setBestNumber(BigInt number) {
    bestNumber = number;
    update();
  }

  void setReferendums(List<ReferendumInfo> ls) {
    referendums = ls;
    update();
  }

  void setReferendumVoteConvictions(List? ls) {
    voteConvictions = ls;
    update();
  }

  void setProposals(List<ProposalInfoData> ls) {
    proposals = ls;
    update();
  }

  Future<void> loadCache() async {
    if (cache.councilInfo.val['data'] != null) {
      setCouncilInfo(cache.councilInfo.val['data'], shouldCache: false);
      cacheCouncilTimestamp = cache.councilInfo.val['cacheTime'];
    } else {
      setCouncilInfo(Map<String, dynamic>(), shouldCache: false);
    }
    update();
  }

  void setTreasuryOverview(TreasuryOverviewData data) {
    treasuryOverview = data;
    update();
  }

  void setTreasuryTips(List<TreasuryTipData> data) {
    treasuryTips = data;
    update();
  }

  void setCouncilMotions(List<CouncilMotionData> data) {
    councilMotions = data;
    update();
  }

  void clearState() {
    referendums = [];
    proposals = [];
    councilMotions = [];
    treasuryOverview = TreasuryOverviewData();
    treasuryTips = [];
    update();
  }
}
