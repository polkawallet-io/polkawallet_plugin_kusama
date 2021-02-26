import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_chainx/pages/staking/validators/validatorDetailPage.dart';
import 'package:polkawallet_plugin_chainx/store/staking/types/validatorData.dart';
import 'package:polkawallet_plugin_chainx/utils/i18n/index.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/addressIcon.dart';
import 'package:polkawallet_ui/utils/index.dart';

class Validator extends StatelessWidget {
  Validator(
    this.validator,
    this.accInfo,
    this.icon,
    this.decimals,
    this.nominations,
  ) : isWaiting = false;

  final ValidatorData validator;
  final Map accInfo;
  final String icon;
  final int decimals;
  final bool isWaiting;
  final List nominations;

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).getDic(i18n_full_dic_chainx, 'staking');
//    print(accInfo['identity']);
    return GestureDetector(
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: AddressIcon(validator.accountId, svg: icon),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  UI.accountDisplayName(
                    validator.accountId,
                    accInfo,
                  ),
                  Text(
                    'All Stake: ${validator.totalNomination}',
                    style: TextStyle(
                      color: Theme.of(context).unselectedWidgetColor,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'Own Stake: ${validator.selfBonded}',
                    style: TextStyle(
                      color: Theme.of(context).unselectedWidgetColor,
                      fontSize: 12,
                    ),
                  )
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(dic['reward']),
                Text('${validator.rewardPotBalance}'),
              ],
            )
          ],
        ),
      ),
      onTap: () {
        // webApi.staking.queryValidatorRewards(validator.accountId);
        Navigator.of(context).pushNamed(ValidatorDetailPage.route, arguments: validator);
      },
    );
  }
}
