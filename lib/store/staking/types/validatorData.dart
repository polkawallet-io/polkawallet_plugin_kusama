class ValidatorData extends _ValidatorData {
  static ValidatorData fromJson(Map<String, dynamic> json) {
    ValidatorData data = ValidatorData();
    data.accountId = json['accountId'];
    if (json['exposure'] != null) {
      data.total = BigInt.parse(json['exposure']['total'].toString());
      data.bondOwn = BigInt.parse(json['exposure']['own'].toString());
      data.bondOther = data.total - data.bondOwn;

      data.isActive = json['isActive'];
      data.isElected = json['isElected'];
      data.isBlocking = json['isBlocking'];

      data.numNominators = json['numNominators'];
      data.rankBondTotal = json['rankBondTotal'];
      data.rankReward = json['rankReward'];

      data.stakedReturn = double.parse(json['stakedReturn'].toString());
      data.stakedReturnCmp = double.parse(json['stakedReturnCmp'].toString());

      data.commission = double.parse(json['commissionPer'].toString());
      data.nominators =
          List<Map<String, dynamic>>.from(json['exposure']['others']);
    }
    return data;
  }
}

abstract class _ValidatorData {
  String? accountId = '';

  BigInt total = BigInt.zero;
  BigInt bondOwn = BigInt.zero;
  BigInt bondOther = BigInt.zero;

  bool? isActive = false;
  bool? isElected = false;
  bool? isBlocking = false;

  int? numNominators = 0;
  int? rankBondTotal = 0;
  int? rankReward = 0;

  double stakedReturn = 0;
  double stakedReturnCmp = 0;

  double commission = 0;

  List<Map<String, dynamic>> nominators = [];
}
