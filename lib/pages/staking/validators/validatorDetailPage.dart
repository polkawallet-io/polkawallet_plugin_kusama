import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_kusama/common/components/infoItem.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/store/staking/types/validatorData.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/accountInfo.dart';
import 'package:polkawallet_ui/components/roundedCard.dart';
import 'package:polkawallet_ui/utils/format.dart';

class ValidatorDetailPage extends StatelessWidget {
  ValidatorDetailPage(this.plugin, this.keyring);
  static final String route = '/staking/validator';

  final PluginKusama plugin;
  final Keyring keyring;

  @override
  Widget build(BuildContext context) => Observer(
        builder: (_) {
          final dicStaking =
              I18n.of(context).getDic(i18n_full_dic_kusama, 'staking');
          final int decimals = plugin.networkState.tokenDecimals;
          final ValidatorData detail =
              ModalRoute.of(context).settings.arguments;

          final accInfo =
              plugin.store.accounts.addressIndexMap[detail.accountId];
          final accIcon =
              plugin.store.accounts.addressIconsMap[detail.accountId];

          return Scaffold(
            appBar: AppBar(
              title: Text(dicStaking['validator']),
              centerTitle: true,
            ),
            body: SafeArea(
              child: ListView(
                children: <Widget>[
                  RoundedCard(
                    margin: EdgeInsets.all(16),
                    child: Column(
                      children: <Widget>[
                        AccountInfo(
                          network: plugin.basic.name,
                          accInfo: accInfo,
                          address: detail.accountId,
                          icon: accIcon,
                        ),
                        Divider(),
                        Padding(
                          padding: EdgeInsets.only(top: 16, left: 24),
                          child: Row(
                            children: <Widget>[
                              InfoItem(
                                title: dicStaking['stake.own'],
                                content: Fmt.token(detail.bondOwn, decimals),
                              ),
                              InfoItem(
                                title: dicStaking['stake.other'],
                                content: Fmt.token(detail.bondOther, decimals),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(top: 16, left: 24, bottom: 24),
                          child: Row(
                            children: <Widget>[
                              InfoItem(
                                title: dicStaking['commission'],
                                content: detail.commission,
                              ),
                              InfoItem(
                                title: 'points',
                                content: detail.points.toString(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
}
