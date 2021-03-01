class Dividended {
  String validator;
  String interest;
}

class UserInterestData extends _UserInterestData {
  static UserInterestData fromJson(Map<String, dynamic> json) {
    UserInterestData data = UserInterestData();
    data.account = json['account'];
    data.interests = List<Dividended>.from(json['interests'] ?? []);
    return data;
  }
}

abstract class _UserInterestData {
  String account;
  List<Dividended> interests;
}
