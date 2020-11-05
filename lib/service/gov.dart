import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/store/index.dart';
import 'package:polkawallet_plugin_kusama/utils/format.dart';
import 'package:polkawallet_sdk/api/api.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';

class ApiGov {
  ApiGov(this.plugin, this.keyring)
      : api = plugin.sdk.api,
        store = plugin.store;

  final PluginKusama plugin;
  final Keyring keyring;
  final PolkawalletApi api;
  final PluginStore store;
}
