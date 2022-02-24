import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_kusama/pages/stakingNew/overView.dart';
import 'package:polkawallet_plugin_kusama/pages/stakingNew/validator.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/store/staking/types/validatorData.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginScaffold.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginTabCard.dart';

class OverViewPage extends StatefulWidget {
  OverViewPage(this.plugin, {Key? key}) : super(key: key);
  final PluginKusama plugin;

  static final String route = '/staking/overView';

  @override
  State<OverViewPage> createState() => _OverViewPageState();
}

class _OverViewPageState extends State<OverViewPage> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'staking')!;
    List<ValidatorData> ls = _tabIndex == 0
        ? widget.plugin.store.staking.electedInfo.toList()
        : widget.plugin.store.staking.nextUpsInfo.toList();
    // sort list
    ls.sort((a, b) => a.rankReward! < b.rankReward! ? 1 : -1);
    if (_tabIndex == 1) {
      ls.sort((a, b) {
        final aLength =
            widget.plugin.store.staking.nominationsCount![a.accountId] ?? 0;
        final bLength =
            widget.plugin.store.staking.nominationsCount![b.accountId] ?? 0;
        return 0 - aLength.compareTo(bLength) as int;
      });
    }
    final int decimals = widget.plugin.networkState.tokenDecimals![0];

    final maxNomPerValidator = int.parse(widget
        .plugin.networkConst['staking']['maxNominatorRewardedPerValidator']
        .toString());

    return PluginScaffold(
      appBar: PluginAppBar(title: Text(dic['overview']!)),
      body: ListView.builder(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          itemCount: ls.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                children: [
                  OverViewWidget(widget.plugin),
                  PluginTabCard(
                    [
                      "${dic['elected']!} (${widget.plugin.store.staking.electedInfo.length})",
                      "${dic['waiting']} (${widget.plugin.store.staking.nextUpsInfo.length})"
                    ],
                    (index) {
                      setState(() {
                        _tabIndex = index;
                      });
                    },
                    _tabIndex,
                    margin: EdgeInsets.only(top: 22),
                  )
                ],
              );
            }
            ValidatorData acc = ls[index - 1];
            Map? accInfo =
                widget.plugin.store.accounts.addressIndexMap[acc.accountId];
            final icon =
                widget.plugin.store.accounts.addressIconsMap[acc.accountId];
            final nomCount = _tabIndex == 0
                ? acc.nominators.length
                : widget.plugin.store.staking
                        .nominationsCount![acc.accountId] ??
                    0;
            return Container(
                decoration: BoxDecoration(
                    color: Color(0x24FFFFFF),
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(index == 1 ? 14 : 0),
                        bottomLeft:
                            Radius.circular(index == ls.length ? 14 : 0),
                        bottomRight:
                            Radius.circular(index == ls.length ? 14 : 0))),
                child: Column(
                  children: [
                    Validator(acc, accInfo, icon, decimals, nomCount,
                        nomCount >= maxNomPerValidator),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Divider(
                          color: Colors.white.withAlpha(36),
                          height: 5,
                        )),
                  ],
                ));
          }),
    );
  }
}
