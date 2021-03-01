class Dividended {
  String validator;
  String interest;

  static Dividended fromJson(Map<String, dynamic> json) {
    Dividended data = Dividended();
    data.validator = json['validator'];
    data.interest = json['interest'];
    return data;
  }
}

class UserInterestData extends _UserInterestData {
  static UserInterestData fromJson(Map<String, dynamic> json) {
    UserInterestData data = UserInterestData();
    data.account = json['account'];
    var list = json['interests'] as List;
    data.interests = list.map((i) => Dividended.fromJson(i)).toList();
    return data;
  }
}

abstract class _UserInterestData {
  String account;
  List<Dividended> interests;
}
