import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_kusama/pages/governance/council/council.dart';
import 'package:polkawallet_plugin_kusama/pages/governance/council/motions.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/topTaps.dart';
import 'package:polkawallet_ui/ui.dart';

class CouncilPage extends StatefulWidget {
  CouncilPage(this.plugin, this.keyring);
  final PluginKusama plugin;
  final Keyring keyring;

  static const String route = '/gov/council/index';

  @override
  _GovernanceState createState() => _GovernanceState();
}

class _GovernanceState extends State<CouncilPage> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (widget.plugin.sdk.api.connectedNode == null) {
        return;
      }
      widget.plugin.service.gov.queryCouncilInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov')!;
    final tabs = [dic['council'], dic['council.motions']];
    return Scaffold(
      body: PageWrapperWithBackground(SafeArea(
        child: Container(
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
                  Expanded(child: Container(width: 8))
                ],
              ),
              TopTabs(
                names: tabs as List<String>?,
                activeTab: _tab,
                onTab: (v) {
                  setState(() {
                    if (_tab != v) {
                      _tab = v;
                    }
                  });
                },
              ),
              Observer(
                builder: (_) {
                  return Expanded(
                    child: widget.plugin.store.gov.council.members == null
                        ? CupertinoActivityIndicator()
                        : _tab == 0
                            ? Council(widget.plugin)
                            : Motions(widget.plugin),
                  );
                },
              ),
            ],
          ),
        ),
      )),
    );
  }
}
