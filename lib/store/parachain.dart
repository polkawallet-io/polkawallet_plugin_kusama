import 'package:mobx/mobx.dart';
import 'package:polkawallet_sdk/api/types/parachain/auctionData.dart';
import 'package:polkawallet_sdk/api/types/parachain/parasOverviewData.dart';

part 'parachain.g.dart';

class ParachainStore extends _ParachainStore with _$ParachainStore {
  ParachainStore() : super();
}

abstract class _ParachainStore with Store {
  @observable
  ParasOverviewData overview = ParasOverviewData();

  @observable
  AuctionData auctionData = AuctionData();

  @observable
  Map fundsVisible = {};

  @observable
  Map userContributions = {};

  @action
  void setOverviewData(
      AuctionData data, Map visible, ParasOverviewData overviewData) {
    auctionData = data;
    fundsVisible = visible;
    overview = overviewData;
  }

  @action
  void setUserContributions(Map data) {
    userContributions = data;
  }
}
