import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/validators/validator.dart';
import 'package:polkawallet_plugin_kusama/pages/stakingNew/overView.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/store/staking/types/validatorData.dart';
import 'package:polkawallet_plugin_kusama/utils/format.dart';
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
    return PluginScaffold(
        appBar: PluginAppBar(title: Text(dic['overview']!)),
        body: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  OverViewWidget(widget.plugin),
                  PluginTabCard(
                    [dic['elected']!, dic['waiting']!],
                    (index) {
                      setState(() {
                        _tabIndex = index;
                      });
                    },
                    _tabIndex,
                    margin: EdgeInsets.only(top: 32),
                  ),
                  Container(
                      decoration: BoxDecoration(
                          color: Color(0xFFFFFFFF).withAlpha(20),
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(14),
                              topRight: Radius.circular(14),
                              bottomRight: Radius.circular(14))),
                      child: _buildListView())
                ],
              )),
        ));
  }

  Widget _buildListView() {
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
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        ValidatorData acc = ls[index];
        Map? accInfo =
            widget.plugin.store.accounts.addressIndexMap[acc.accountId];
        final icon =
            widget.plugin.store.accounts.addressIconsMap[acc.accountId];
        return Validator(
          acc,
          accInfo,
          icon,
          decimals,
          widget.plugin.store.staking.nominationsCount![acc.accountId] ?? 0,
        );
      },
      itemCount: ls.length,
    );
  }
}
