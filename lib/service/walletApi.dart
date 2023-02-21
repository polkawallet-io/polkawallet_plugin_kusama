import 'dart:convert';

import 'package:http/http.dart';

class WalletApi {
  static const String _endpoint = 'https://api.polkawallet.io';
  static const String _configEndpoint = 'https://acala.polkawallet-cloud.com';

  static Future<Map?> getTokenPrice(List<String?> tokens) async {
    final url = '$_endpoint/price-server?from=market&token=${tokens.join(',')}';
    try {
      final res = await get(Uri.parse(url));
      final data =
          jsonDecode(utf8.decode(res.bodyBytes))['data']['price'] as List;
      return data
          .asMap()
          .map((k, v) => MapEntry(tokens[k], double.parse(v.toString())));
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

  static Future<Map?> getDemocracyReferendumInfo(int id,
      {String network = 'kusama'}) async {
    try {
      final res = await post(
          Uri.parse(
              'https://$network.api.subscan.io/api/scan/democracy/referendum'),
          headers: {"Content-Type": "application/json", "Accept": "*/*"},
          body: jsonEncode({'referendum_index': id}));
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
