import 'dart:convert';

import 'package:http/http.dart';

class WalletApi {
  static const String _endpoint = 'https://api.polkawallet.io';
  static const String _configEndpoint = 'https://acala.subdao.com';
  static const String _cdnEndpoint = 'https://cdn.polkawallet-cloud.com';

  static Future<Map?> getTokenPrice() async {
    final url =
        '$_cdnEndpoint/lastPrice.json?t=${DateTime.now().millisecondsSinceEpoch}';
    try {
      Response res = await get(Uri.parse(url));
      if (res == null) {
        return null;
      } else {
        return jsonDecode(utf8.decode(res.bodyBytes));
      }
    } catch (err) {
      print(err);
      return null;
    }
  }

  static Future<Map?> getRecommended() async {
    try {
      Response res = await get(Uri.parse('$_endpoint/recommended.json'));
      // ignore: unnecessary_null_comparison
      if (res == null) {
        return null;
      } else {
        return jsonDecode(res.body) as Map?;
      }
    } catch (err) {
      print(err);
      return null;
    }
  }

  static Future<Map?> getCrowdLoansConfig({bool isKSM = true}) async {
    try {
      final res = await get(Uri.parse(_configEndpoint +
          (isKSM ? '/wallet/paras.json' : '/wallet/parasDot.json')));
      // ignore: unnecessary_null_comparison
      if (res == null) {
        return null;
      } else {
        return jsonDecode(res.body) as Map;
      }
    } catch (err) {
      print(err);
      return null;
    }
  }
}
