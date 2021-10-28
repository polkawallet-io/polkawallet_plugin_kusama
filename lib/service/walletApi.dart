import 'dart:convert';

import 'package:http/http.dart';

class WalletApi {
  static const String _endpoint = 'https://api.polkawallet.io';

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
}
