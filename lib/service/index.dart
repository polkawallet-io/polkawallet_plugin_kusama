import 'package:flutter/cupertino.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/service/gov.dart';
import 'package:polkawallet_plugin_kusama/service/staking.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/passwordInputDialog.dart';
import 'package:polkawallet_ui/utils/i18n.dart';

class PluginApi {
  PluginApi(PluginKusama plugin, Keyring keyring)
      : staking = ApiStaking(plugin, keyring),
        gov = ApiGov(plugin, keyring),
        plugin = plugin;
  final ApiStaking staking;
  final ApiGov gov;

  final PluginKusama plugin;

  Future<String?> getPassword(BuildContext context, KeyPairData acc) async {
    final password = await showCupertinoDialog(
      context: context,
      builder: (_) {
        return PasswordInputDialog(
          plugin.sdk.api,
          title: Text(
              I18n.of(context)!.getDic(i18n_full_dic_ui, 'common')!['unlock']!),
          account: acc,
        );
      },
    );
    return password;
  }

  Future<String> getRuntimeModuleName(List<String> modules) async {
    final res = await Future.wait(modules.map((e) => plugin.sdk.webView!
        .evalJavascript('(api.tx.$e != undefined ? {} : null)',
            wrapPromise: false)));
    print(res);
    return modules[res.indexWhere((e) => e != null)];
  }
}
