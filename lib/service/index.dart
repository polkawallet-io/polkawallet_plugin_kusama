import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/service/gov.dart';
import 'package:polkawallet_plugin_kusama/service/staking.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';

class PluginApi {
  PluginApi(PluginKusama plugin, Keyring keyring)
      : staking = ApiStaking(plugin, keyring),
        gov = ApiGov(plugin, keyring);
  final ApiStaking staking;
  final ApiGov gov;
}
