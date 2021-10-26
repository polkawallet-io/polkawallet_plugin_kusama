import 'package:get/get.dart';

class AccountsStore extends GetxController {
  Map<int, Map<String, String>> pubKeyAddressMap =
      Map<int, Map<String, String>>();

  Map<String?, Map?> addressIndexMap = Map<String?, Map?>();

  Map<String?, String?> addressIconsMap = Map<String?, String?>();

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
    update();
  }

  void setAddressIconsMap(List list) {
    list.forEach((i) {
      addressIconsMap[i[0]] = i[1];
    });
    update();
  }

  void setAddressIndex(List list) {
    list.forEach((i) {
      addressIndexMap[i['accountId']] = i;
    });
    update();
  }
}
