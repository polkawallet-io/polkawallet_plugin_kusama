import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_chainx/common/components/infoItem.dart';
import 'package:polkawallet_plugin_chainx/polkawallet_plugin_chainx.dart';
import 'package:polkawallet_plugin_chainx/store/staking/types/validatorData.dart';
import 'package:polkawallet_plugin_chainx/pages/staking/validators/accountInfo.dart';
import 'package:polkawallet_plugin_chainx/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/roundedCard.dart';
import 'package:polkawallet_ui/utils/format.dart';

class ValidatorDetailPage extends StatelessWidget {
  ValidatorDetailPage(this.plugin, this.keyring);
  static final String route = '/staking/validator';

  final PluginChainX plugin;
  final Keyring keyring;

  @override
  Widget build(BuildContext context) => Observer(
        builder: (_) {
          final dicStaking = I18n.of(context).getDic(i18n_full_dic_chainx, 'staking');
          final ValidatorData detail = ModalRoute.of(context).settings.arguments;

          final accInfo = plugin.store.accounts.addressIndexMap[detail.accountId];
          final accIcon = plugin.store.accounts.addressIconsMap[detail.accountId];

          return Scaffold(
            appBar: AppBar(
              title: Text(dicStaking['validator']),
              centerTitle: true,
            ),
            body: SafeArea(
                child: RoundedCard(
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
                          title: dicStaking['overview.all'],
                          content: detail.totalNominationFmt,
                        ),
                        InfoItem(
                          title: dicStaking['overview.own'],
                          content: detail.selfBondedFmt,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16, left: 24, bottom: 24),
                    child: Row(
                      children: <Widget>[
                        InfoItem(
                          title: dicStaking['overview.pots'],
                          content: detail.rewardPotBalanceFmt,
                        ),
                        InfoItem(title: dicStaking['overview.potacc'], content: Fmt.address(detail.rewardPotAccount)),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          );
        },
      );
}
