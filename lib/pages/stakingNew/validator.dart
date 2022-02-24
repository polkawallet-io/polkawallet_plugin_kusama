import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/validators/validatorDetailPage.dart';
import 'package:polkawallet_plugin_kusama/store/staking/types/validatorData.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/v3/addressIcon.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/index.dart';

class Validator extends StatelessWidget {
  Validator(
    this.validator,
    this.accInfo,
    this.icon,
    this.decimals,
    this.nominationsCount,
    this.isMax,
  ) : isWaiting = validator.total == BigInt.zero;

  final ValidatorData validator;
  final Map? accInfo;
  final String? icon;
  final int decimals;
  final bool isWaiting;
  final bool isMax;
  final int nominationsCount;

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'staking')!;
    return GestureDetector(
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: AddressIcon(
                validator.accountId,
                svg: icon,
                size: 38,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: [
                      isMax
                          ? Image.asset(
                              'packages/polkawallet_plugin_kusama/assets/images/staking/icon_over_sub.png',
                              width: 14,
                            )
                          : Container(),
                      (validator.isBlocking ?? false)
                          ? Image.asset(
                              'packages/polkawallet_plugin_kusama/assets/images/staking/icon_block_nom.png',
                              width: 14,
                            )
                          : Container(),
                      Expanded(
                        child: UI.accountDisplayName(
                            validator.accountId, accInfo,
                            style: TextStyle(
                                fontSize: 14,
                                fontFamily: "TitilliumWeb",
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      )
                    ],
                  ),
                  Text(
                    !isWaiting
                        // ignore: unnecessary_null_comparison
                        ? '${dic['total']}: ${validator.total != null ? Fmt.token(validator.total, decimals) : '~'}'
                        : '${dic['nominators']}: $nominationsCount',
                    style: Theme.of(context)
                        .textTheme
                        .headline5
                        ?.copyWith(fontSize: 10, color: Colors.white),
                  ),
                  Text(
                    '${dic['commission']}: ${NumberFormat('0.00%').format(validator.commission / 100)}',
                    style: Theme.of(context)
                        .textTheme
                        .headline5
                        ?.copyWith(fontSize: 10, color: Colors.white),
                  )
                ],
              ),
            ),
            Visibility(
                visible: !isWaiting,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(dic['reward']!,
                        style: Theme.of(context)
                            .textTheme
                            .headline5
                            ?.copyWith(fontSize: 10, color: Colors.white)),
                    Text(
                        validator.isActive!
                            ? '${validator.stakedReturnCmp.toStringAsFixed(2)}%'
                            : '~',
                        style: Theme.of(context).textTheme.headline4?.copyWith(
                            fontWeight: FontWeight.w600, color: Colors.white)),
                  ],
                ))
          ],
        ),
      ),
      onTap: () {
        // webApi.staking.queryValidatorRewards(validator.accountId);
        Navigator.of(context)
            .pushNamed(ValidatorDetailPage.route, arguments: validator);
      },
    );
  }
}
