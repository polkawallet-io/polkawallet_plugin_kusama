import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginIconButton.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginScaffold.dart';

class StakingPage extends StatefulWidget {
  StakingPage(this.plugin, this.keyring, {Key? key}) : super(key: key);
  final PluginKusama plugin;
  final Keyring keyring;

  static final String route = '/staking/stakingPage';

  @override
  State<StakingPage> createState() => _StakingPageState();
}

class _StakingPageState extends State<StakingPage> {
  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'common')!;
    return PluginScaffold(
        appBar: PluginAppBar(
          title: Text(dic['staking']!),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 16),
              child: PluginIconButton(
                // onPressed: () =>
                //     Navigator.of(context).pushNamed(LoanHistoryPage.route),
                icon: Icon(
                  Icons.history,
                  size: 22,
                  color: Color(0xFF17161F),
                ),
              ),
            )
          ],
        ),
        body: Container());
  }
}
