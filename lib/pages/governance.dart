import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_kusama/pages/governance/council/councilPage.dart';
import 'package:polkawallet_plugin_kusama/pages/governance/democracy/democracyPage.dart';
import 'package:polkawallet_plugin_kusama/pages/governance/treasury/treasuryPage.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/plugin/index.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/SkaletonList.dart';
import 'package:polkawallet_ui/pages/dAppWrapperPage.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginItemCard.dart';

class Gov extends StatelessWidget {
  Gov(this.plugin);

  final PolkawalletPlugin plugin;

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      if (plugin.sdk.api.connectedNode == null) {
        return SkaletonList(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          items: 4,
          itemMargin: EdgeInsets.only(bottom: 16),
          child: Container(
            padding: EdgeInsets.fromLTRB(9, 6, 6, 11),
            child: Column(
              children: <Widget>[
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 18,
                      color: Colors.white,
                    ),
                    SizedBox(width: 6),
                    Container(
                        width: 18,
                        height: 18,
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(const Radius.circular(5)),
                          color: Colors.white,
                        ))
                  ],
                ),
                SizedBox(height: 7),
                Container(
                  width: double.infinity,
                  height: 11,
                  color: Colors.white,
                ),
                SizedBox(height: 3),
                Container(
                  width: double.infinity,
                  height: 11,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        );
      }

      final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov');

      return Container(
          child: Column(
        children: [
          GestureDetector(
            child: PluginItemCard(
              margin: EdgeInsets.only(bottom: 16),
              title: dic!['democracy']!,
              describe: dic['democracy.brief']!,
              icon: Image.asset(
                  'packages/polkawallet_plugin_kusama/assets/images/public/icon_democracy.png',
                  width: 18),
            ),
            onTap: () => Navigator.of(context).pushNamed(DemocracyPage.route),
          ),
          GestureDetector(
            child: PluginItemCard(
              margin: EdgeInsets.only(bottom: 16),
              title: dic['council']!,
              describe: dic['council.brief']!,
              icon: Image.asset(
                  'packages/polkawallet_plugin_kusama/assets/images/public/icon_council.png',
                  width: 18),
            ),
            onTap: () => Navigator.of(context).pushNamed(CouncilPage.route),
          ),
          GestureDetector(
            child: PluginItemCard(
              margin: EdgeInsets.only(bottom: 16),
              title: dic['treasury']!,
              describe: dic['treasury.brief']!,
              icon: Image.asset(
                  'packages/polkawallet_plugin_kusama/assets/images/public/icon_treasury.png',
                  width: 18),
            ),
            onTap: () => Navigator.of(context).pushNamed(TreasuryPage.route),
          ),
          GestureDetector(
            child: PluginItemCard(
              margin: EdgeInsets.only(bottom: 16),
              title: 'Polkassembly',
              describe: dic['polkassembly']!,
              icon: Image.asset(
                  'packages/polkawallet_plugin_kusama/assets/images/public/icon_Polkassembly.png',
                  width: 18),
            ),
            onTap: () => Navigator.of(context).pushNamed(
              DAppWrapperPage.route,
              arguments: 'https://${plugin.basic.name}.polkassembly.io/',
              // "https://polkadot.js.org/apps/",
            ),
          )
        ],
      ));
    });
  }
}
