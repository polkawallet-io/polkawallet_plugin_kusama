import 'dart:async';

import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_kusama/pages/gov2/gov2Page.dart';
import 'package:polkawallet_plugin_kusama/pages/governanceNew/governancePage.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/connectionChecker.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginButton.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginPopLoadingWidget.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginScaffold.dart';
import 'package:polkawallet_ui/components/v3/plugin/roundedPluginCard.dart';

class GovEntryPage extends StatefulWidget {
  GovEntryPage(this.plugin, this.keyring, {Key? key}) : super(key: key);
  final PluginKusama plugin;
  final Keyring keyring;

  static const String route = '/governance/index';

  @override
  State<GovEntryPage> createState() => _GovEntryPageState();
}

class _GovEntryPageState extends State<GovEntryPage> {
  bool? _isV1Exist;
  bool? _isV2Exist;
  bool _loading = true;

  Future<void> _checkVersion() async {
    final isV1Exist = await widget.plugin.sdk.api.gov2.checkGovExist(1);
    final isV2Exist = await widget.plugin.sdk.api.gov2.checkGovExist(2);

    if (isV1Exist == true && isV2Exist == false) {
      Navigator.of(context).popAndPushNamed(GovernancePage.route);
      return;
    }

    if (isV1Exist == false && isV2Exist == true) {
      Navigator.of(context).popAndPushNamed(Gov2Page.route);
      return;
    }

    if (isV1Exist == false && isV2Exist == false) {
      Timer(Duration(seconds: 5), _checkVersion);
      return;
    }

    setState(() {
      _isV1Exist = isV1Exist;
      _isV2Exist = isV2Exist;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov')!;
    final dicCommon = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'common')!;
    final showEntry = _isV1Exist == true && _isV2Exist == true;
    return PluginScaffold(
      appBar: PluginAppBar(
        title: Text(dic['democracy']!),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            ConnectionChecker(widget.plugin, onConnected: _checkVersion),
            Visibility(
                visible: _loading,
                child: SizedBox(
                  height: 240,
                  child: PluginPopLoadingContainer(
                    loading: true,
                  ),
                )),
            Visibility(
                visible: !_loading && showEntry,
                child: RoundedPluginCard(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        height: 120,
                        child: Text(
                          'Referenda',
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(color: Colors.white),
                        ),
                      ),
                      PluginButton(
                        title: 'Enter',
                        onPressed: () =>
                            Navigator.of(context).pushNamed(Gov2Page.route),
                      ),
                    ],
                  ),
                )),
            Visibility(
                visible: !_loading && showEntry,
                child: RoundedPluginCard(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                          alignment: Alignment.center,
                          height: 120,
                          child: Text(
                            'Old Governance',
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.copyWith(color: Colors.white),
                          )),
                      PluginButton(
                        title: 'Enter',
                        onPressed: () => Navigator.of(context)
                            .pushNamed(GovernancePage.route),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
