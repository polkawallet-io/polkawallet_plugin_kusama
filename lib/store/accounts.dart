import 'package:mobx/mobx.dart';

part 'accounts.g.dart';

class AccountsStore extends _AccountsStore with _$AccountsStore {}

abstract class _AccountsStore with Store {
  @observable
  ObservableMap<int, Map<String, String>> pubKeyAddressMap =
      ObservableMap<int, Map<String, String>>();

  @observable
  ObservableMap<String?, Map?> addressIndexMap = ObservableMap<String?, Map?>();

  @observable
  ObservableMap<String?, String?> addressIconsMap =
      ObservableMap<String?, String?>();

  @action
  void setPubKeyAddressMap(Map<String, Map> data) {
    data.keys.forEach((ss58) {
      // get old data map
      Map<String, String> addresses =
          Map.of(pubKeyAddressMap[int.parse(ss58)] ?? {});
      // set new data
      Map.of(data[ss58]!).forEach((k, v) {
        addresses[k] = v;
      });
      // update state
      pubKeyAddressMap[int.parse(ss58)] = addresses;
    });
  }

  @action
  void setAddressIconsMap(List list) {
    list.forEach((i) {
      addressIconsMap[i[0]] = i[1];
    });
  }

  @action
  void setAddressIndex(List list) {
    list.forEach((i) {
      addressIndexMap[i['accountId']] = i;
    });
  }
}
