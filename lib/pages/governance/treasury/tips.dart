import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_kusama/pages/governance/treasury/tipDetailPage.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/api/types/gov/treasuryTipData.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/v3/addressIcon.dart';
import 'package:polkawallet_ui/components/listTail.dart';
import 'package:polkawallet_ui/components/v3/roundedCard.dart';
import 'package:polkawallet_ui/utils/index.dart';

class MoneyTips extends StatefulWidget {
  MoneyTips(this.plugin, this.keyring);
  final PluginKusama plugin;
  final Keyring keyring;

  @override
  _ProposalsState createState() => _ProposalsState();
}

class _ProposalsState extends State<MoneyTips> {
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      new GlobalKey<RefreshIndicatorState>();

  Future<void> _fetchData() async {
    widget.plugin.service.gov.updateBestNumber();
    await widget.plugin.service.gov.queryTreasuryTips();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _refreshKey.currentState?.show();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (BuildContext context) {
        final tips = <TreasuryTipData>[];
        if (widget.plugin.store.gov.treasuryTips != null) {
          tips.addAll(widget.plugin.store.gov.treasuryTips!.reversed);
        }
        return RefreshIndicator(
          key: _refreshKey,
          onRefresh: _fetchData,
          child: tips.length == 0
              ? Center(
                  child: ListTail(
                  isEmpty: true,
                  isLoading: false,
                ))
              : ListView.builder(
                  padding: EdgeInsets.only(bottom: 32),
                  itemCount: tips.length + 1,
                  itemBuilder: (_, int i) {
                    if (tips.length == i) {
                      return ListTail(
                        isEmpty: false,
                        isLoading: false,
                      );
                    }
                    return Observer(builder: (_) {
                      final TreasuryTipData tip = tips[i];
                      final icon =
                          widget.plugin.store.accounts.addressIconsMap[tip.who];
                      final indices =
                          widget.plugin.store.accounts.addressIndexMap[tip.who];
                      return RoundedCard(
                        margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
                        padding: EdgeInsets.only(top: 16, bottom: 16),
                        child: ListTile(
                          leading: AddressIcon(
                            tip.who,
                            svg: icon,
                          ),
                          title: UI.accountDisplayName(tip.who, indices),
                          subtitle: Text(tip.reason!),
                          trailing: Column(
                            children: <Widget>[
                              Text(
                                tip.tips!.length.toString(),
                                style: Theme.of(context).textTheme.headline4,
                              ),
                              Text(I18n.of(context)!.getDic(
                                  i18n_full_dic_kusama,
                                  'gov')!['treasury.tipper']!)
                            ],
                          ),
                          onTap: () async {
                            final res = await Navigator.of(context).pushNamed(
                              TipDetailPage.route,
                              arguments: tip,
                            );
                            if (res != null) {
                              _refreshKey.currentState!.show();
                            }
                          },
                        ),
                      );
                    });
                  },
                ),
        );
      },
    );
  }
}
