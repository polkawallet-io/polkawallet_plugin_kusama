import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_chainx/pages/staking/actions/stakePage.dart';
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
    var theme = Theme.of(context);

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
                    '${dic['overview.all']}: ${validator.totalNominationFmt}',
                    style: TextStyle(
                      color: Theme.of(context).unselectedWidgetColor,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${dic['overview.own']}: ${validator.selfBondedFmt}',
                    style: TextStyle(
                      color: Theme.of(context).unselectedWidgetColor,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${dic['overview.pots']}: ${validator.rewardPotBalanceFmt}',
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
                GestureDetector(
                  child: Container(
                    margin: EdgeInsets.only(left: 8),
                    padding: EdgeInsets.fromLTRB(16, 6, 16, 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                      border: Border.all(width: 0.5, color: theme.dividerColor),
                    ),
                    child: Text(dic['mystaking.action.vote']),
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed(StakePage.route, arguments: validator);
                  },
                ),
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
