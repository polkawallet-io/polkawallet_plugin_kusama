class BondedChunksData {
  String lockedUntil;
  String value;

  static BondedChunksData fromJson(Map<String, dynamic> json) {
    BondedChunksData data = BondedChunksData();
    data.lockedUntil = json['lockedUntil'];
    data.value = json['value'];
    return data;
  }
}

class NominationData extends _NominationData {
  static NominationData fromJson(Map<String, dynamic> json) {
    NominationData data = NominationData();
    data.validatorId = json['validatorId'];
    data.account = json['account'];
    data.nomination = BigInt.from(json['nomination']);
    data.lastVoteWeight = BigInt.from(json['lastVoteWeight']);
    data.lastVoteWeightUpdate = BigInt.from(json['lastVoteWeightUpdate']);
    data.unbondedChunks = List<BondedChunksData>.from((json['unbondedChunks'] as List).map((i) => BondedChunksData.fromJson(i)));
    return data;
  }
}

abstract class _NominationData {
  String validatorId;
  String account;
  BigInt nomination;
  BigInt lastVoteWeight;
  BigInt lastVoteWeightUpdate;
  List<BondedChunksData> unbondedChunks;
}
