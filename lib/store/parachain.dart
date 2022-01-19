import 'package:mobx/mobx.dart';
import 'package:polkawallet_sdk/api/types/parachain/auctionData.dart';

part 'parachain.g.dart';

class ParachainStore extends _ParachainStore with _$ParachainStore {
  ParachainStore() : super();
}

abstract class _ParachainStore with Store {
  @observable
  AuctionData auctionData = AuctionData();

  @observable
  Map fundsVisible = {};

  @observable
  Map userContributions = {};

  @action
  void setAuctionData(AuctionData data, Map visible) {
    auctionData = data;
    fundsVisible = visible;
  }

  @action
  void setUserContributions(Map data) {
    userContributions = data;
  }
}
