import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_kusama/pages/stakingNew/overView.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginIconButton.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginLoadingWidget.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginScaffold.dart';
import 'package:polkawallet_ui/components/connectionChecker.dart';

class StakingPage extends StatefulWidget {
  StakingPage(this.plugin, this.keyring, {Key? key}) : super(key: key);
  final PluginKusama plugin;
  final Keyring keyring;

  static final String route = '/staking/stakingPage';

  @override
  State<StakingPage> createState() => _StakingPageState();
}

class _StakingPageState extends State<StakingPage> {
  Future<void> _updateStakingInfo() async {
    await widget.plugin.service.staking.queryOwnStashInfo();
    widget.plugin.service.staking.queryElectedInfo();
  }

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
        body: Observer(builder: (_) {
          final isDataLoading =
              widget.plugin.store.staking.ownStashInfo != null;
          final isStash = widget
                  .plugin.store.staking.ownStashInfo!.isOwnStash! ||
              (!widget.plugin.store.staking.ownStashInfo!.isOwnStash! &&
                  !widget.plugin.store.staking.ownStashInfo!.isOwnController!);
          return SafeArea(
              child: !isDataLoading
                  ? Column(
                      children: [
                        ConnectionChecker(widget.plugin,
                            onConnected: _updateStakingInfo),
                        Container(
                          height: MediaQuery.of(context).size.height / 2,
                          child: PluginLoadingWidget(),
                        )
                      ],
                    )
                  : Container(
                      child: widget.plugin.store.staking.ownStashInfo!
                                      .controllerId ==
                                  null &&
                              isStash
                          ? OverView(widget.plugin)
                          : Container() //staking,
                      ));
        }));
  }
}
