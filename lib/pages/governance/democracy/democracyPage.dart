import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_kusama/pages/governance/democracy/democracy.dart';
import 'package:polkawallet_plugin_kusama/pages/governance/democracy/proposals.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/ui.dart';
import 'package:polkawallet_ui/components/topTaps.dart';

class DemocracyPage extends StatefulWidget {
  DemocracyPage(this.plugin, this.keyring);
  final PluginKusama plugin;
  final Keyring keyring;

  static const String route = '/gov/democracy/index';

  @override
  _DemocracyPageState createState() => _DemocracyPageState();
}

class _DemocracyPageState extends State<DemocracyPage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).getDic(i18n_full_dic_kusama, 'gov');
    final tabs = [dic['democracy.referendum'], dic['democracy.proposal']];

    return Scaffold(
        body: PageWrapperWithBackground(
      SafeArea(
        child: Container(
          padding: EdgeInsets.only(top: 20),
          color: Colors.transparent,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Theme.of(context).cardColor,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  TopTabs(
                    names: tabs,
                    activeTab: _tab,
                    onTab: (v) {
                      setState(() {
                        if (_tab != v) {
                          _tab = v;
                        }
                      });
                    },
                  ),
                ],
              ),
              Expanded(
                child: _tab == 0
                    ? Democracy(widget.plugin)
                    : Proposals(widget.plugin),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
