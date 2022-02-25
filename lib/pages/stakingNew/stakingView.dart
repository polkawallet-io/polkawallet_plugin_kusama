import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/bondExtraPage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/payoutPage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/redeemPage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/setControllerPage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/setPayeePage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/unbondPage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/validators/nominatePage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/validators/validatorDetailPage.dart';
import 'package:polkawallet_plugin_kusama/pages/stakingNew/RewardDetailPage.dart';
import 'package:polkawallet_plugin_kusama/pages/stakingNew/overViewPage.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/store/staking/types/validatorData.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/api/types/staking/ownStashInfo.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/connectionChecker.dart';
import 'package:polkawallet_ui/components/v3/addressIcon.dart';
import 'package:polkawallet_ui/components/v3/infoItemRow.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginLoadingWidget.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginOutlinedButtonSmall.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginTextTag.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginTxButton.dart';
import 'package:polkawallet_ui/components/v3/plugin/roundedPluginCard.dart';
import 'package:polkawallet_ui/pages/v3/txConfirmPage.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/index.dart';

class StakingView extends StatefulWidget {
  StakingView(this.plugin, this.keyring, {Key? key}) : super(key: key);
  final PluginKusama plugin;
  final Keyring keyring;

  @override
  State<StakingView> createState() => _StakingViewState();
}

class _StakingViewState extends State<StakingView> {
  Future<void> _updateData() async {
    await widget.plugin.service.staking.queryMarketPrices();
    widget.plugin.service.staking.updateStakingTxs(0);
    widget.plugin.service.staking.updateStakingRewards();
  }

  void _onAction(Future<dynamic> Function() doAction) {
    doAction().then((res) {
      if (res != null) {
        _updateData();
      }
    });
  }

  Future<void> _chill() async {
    final dicStaking =
        I18n.of(context)!.getDic(i18n_full_dic_kusama, 'staking')!;
    final params = TxConfirmParams(
      txTitle: dicStaking['action.chill'],
      module: 'staking',
      call: 'chill',
      txDisplay: {'action': 'chill'},
      params: [],
      isPlugin: true,
    );
    _onAction(() => Navigator.of(context)
        .pushNamed(TxConfirmPage.route, arguments: params));
  }

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'staking')!;

    final symbol = (widget.plugin.networkState.tokenSymbol ?? ['DOT'])[0];

    final labelStyle =
        Theme.of(context).textTheme.headline5?.copyWith(color: Colors.white);

    final Color actionButtonColor = Color(0xFF007AFE);
    final Color disabledColor = Theme.of(context).unselectedWidgetColor;
    return Observer(builder: (_) {
      final isDataLoading =
          widget.plugin.store.staking.marketPrices.length == 0;

      BigInt bonded = BigInt.zero;
      BigInt redeemable = BigInt.zero;
      if (widget.plugin.store.staking.ownStashInfo!.stakingLedger != null) {
        bonded = BigInt.parse(widget
            .plugin.store.staking.ownStashInfo!.stakingLedger!['active']
            .toString());
        redeemable = BigInt.parse(widget
            .plugin.store.staking.ownStashInfo!.account!.redeemable
            .toString());
      }
      final available = widget.plugin.balances.native?.availableBalance == null
          ? BigInt.zero
          : BigInt.parse(
              widget.plugin.balances.native!.availableBalance.toString());
      BigInt unlocking = widget.plugin.store.staking.accountUnlockingTotal;
      unlocking -= redeemable;

      final decimals = (widget.plugin.networkState.tokenDecimals ?? [12])[0];
      final marketPrice = widget.plugin.store.staking.marketPrices[symbol] ?? 0;

      final isStash = widget.plugin.store.staking.ownStashInfo!.isOwnStash! ||
          (!widget.plugin.store.staking.ownStashInfo!.isOwnStash! &&
              !widget.plugin.store.staking.ownStashInfo!.isOwnController!);
      final isController =
          widget.plugin.store.staking.ownStashInfo!.isOwnController;

      final acc02 = KeyPairData();
      acc02.address = widget.keyring.current.address;
      acc02.pubKey = widget.keyring.current.pubKey;

      widget.plugin.store.accounts.pubKeyAddressMap[widget.plugin.basic.ss58!]
          ?.forEach((k, v) {
        if (widget.plugin.store.staking.ownStashInfo!.isOwnStash! &&
            v == widget.plugin.store.staking.ownStashInfo!.controllerId) {
          acc02.address = v;
          acc02.pubKey = k;
          return;
        }
        if (widget.plugin.store.staking.ownStashInfo!.isOwnController! &&
            v == widget.plugin.store.staking.ownStashInfo!.stashId) {
          acc02.address = v;
          acc02.pubKey = k;
          return;
        }
      });

      // update account icon
      if (acc02.icon == null) {
        acc02.icon =
            widget.plugin.store.accounts.addressIconsMap[acc02.address];
      }

      var sumReward = 0.0;
      widget.plugin.store.staking.txsRewards.forEach((data) {
        sumReward += Fmt.balanceDouble(data.amount!, decimals) *
            (data.eventId == 'Reward' ? 1.0 : -1.0);
      });
      return isDataLoading
          ? Column(
              children: [
                ConnectionChecker(widget.plugin, onConnected: _updateData),
                PluginLoadingWidget(),
              ],
            )
          : Stack(children: [
              SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Container(
                    padding: EdgeInsets.only(
                        left: 16, top: 16, right: 16, bottom: 20),
                    child: Column(
                      children: [
                        ConnectionChecker(widget.plugin,
                            onConnected: _updateData),
                        RoundedPluginCard(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 20),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                        child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("${dic['v3.myStaked']} ($symbol)",
                                            style: labelStyle),
                                        Text(
                                            Fmt.priceFloorBigIntFormatter(
                                                bonded, decimals, lengthMax: 4),
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline5
                                                ?.copyWith(
                                                    color: Colors.white,
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                    height: 2.0)),
                                        Text(
                                            "\$ ${Fmt.priceFloorFormatter(Fmt.bigIntToDouble(bonded, decimals) * marketPrice)}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline5
                                                ?.copyWith(
                                                    color: Colors.white,
                                                    fontSize: 10)),
                                      ],
                                    )),
                                    Expanded(
                                        child: GestureDetector(
                                            onTap: () => Navigator.of(context)
                                                .pushNamed(
                                                    RewardDetailNewPage.route),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    "${dic['v3.newGains']} ($symbol)",
                                                    style: labelStyle),
                                                Text(
                                                    Fmt.priceFloorFormatter(
                                                        sumReward,
                                                        lengthMax: 4),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline5
                                                        ?.copyWith(
                                                            color: Colors.white,
                                                            fontSize: 22,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            height: 2.0)),
                                                Text(
                                                    "\$ ${Fmt.priceFloorFormatter(sumReward * marketPrice)}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline5
                                                        ?.copyWith(
                                                            color: Colors.white,
                                                            fontSize: 10)),
                                              ],
                                            ))),
                                  ],
                                ),
                                Padding(
                                    padding: EdgeInsets.only(top: 10),
                                    child: InfoItemRow(
                                      dic['available']!,
                                      "${Fmt.priceFloorBigIntFormatter(available, decimals, lengthMax: 4)} $symbol",
                                      labelStyle: labelStyle,
                                      contentStyle: labelStyle,
                                    )),
                                InfoItemRow(
                                  dic['v3.unstaking']!,
                                  "${Fmt.priceFloorBigIntFormatter(unlocking, decimals, lengthMax: 4)} $symbol",
                                  labelStyle: labelStyle,
                                  contentStyle: labelStyle,
                                ),
                                InfoItemRow(
                                  dic['bond.redeemable']!,
                                  "${Fmt.priceFloorBigIntFormatter(redeemable, decimals, lengthMax: 4)} $symbol",
                                  labelStyle: labelStyle,
                                  contentStyle: labelStyle,
                                ),
                                InfoItemRow(
                                  dic['v3.nominations']!,
                                  "${widget.plugin.store.staking.ownStashInfo!.nominating!.length.toString()} ${dic['validators']}",
                                  labelStyle: labelStyle,
                                  contentStyle: labelStyle,
                                ),
                                InfoItemRow(
                                  dic['v3.rewardDest']!,
                                  widget.plugin.store.staking.ownStashInfo!
                                          .destination!
                                          .contains('account')
                                      ? Fmt.address(jsonDecode(widget
                                          .plugin
                                          .store
                                          .staking
                                          .ownStashInfo!
                                          .destination!)["account"])
                                      : widget.plugin.store.staking
                                          .ownStashInfo!.destination!,
                                  labelStyle: labelStyle,
                                  contentStyle: labelStyle,
                                )
                              ],
                            )),
                        GridView.count(
                          crossAxisSpacing: 25,
                          mainAxisSpacing: 12,
                          crossAxisCount: 3,
                          childAspectRatio: 103 / 64,
                          padding: EdgeInsets.only(top: 21, bottom: 24),
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          children: [
                            GridViewItemBtn(
                              Image.asset(
                                'packages/polkawallet_plugin_kusama/assets/images/staking/icon_overview.png',
                                width: 36,
                              ),
                              dic['overview']!,
                              onTap: () => Navigator.of(context)
                                  .pushNamed(OverViewPage.route),
                            ),
                            GridViewItemBtn(
                              Image.asset(
                                'packages/polkawallet_plugin_kusama/assets/images/staking/icon_adjustBonded.png',
                                width: 36,
                              ),
                              dic['action.bondAdjust']!,
                              onTap: () {
                                showCupertinoModalPopup(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      CupertinoActionSheet(
                                    actions: <Widget>[
                                      /// disable bondExtra button if account is not stash
                                      CupertinoActionSheetAction(
                                        child: Text(
                                          dic['action.bondExtra']!,
                                          style: TextStyle(
                                            color: !isStash
                                                ? disabledColor
                                                : actionButtonColor,
                                          ),
                                        ),
                                        onPressed: !isStash
                                            ? () => {}
                                            : () {
                                                Navigator.of(context).pop();
                                                _onAction(() => Navigator.of(
                                                        context)
                                                    .pushNamed(
                                                        BondExtraPage.route));
                                              },
                                      ),

                                      /// disable unbond button if account is not controller
                                      CupertinoActionSheetAction(
                                        child: Text(
                                          dic['action.unbond']!,
                                          style: TextStyle(
                                            color: !isController!
                                                ? disabledColor
                                                : actionButtonColor,
                                          ),
                                        ),
                                        onPressed: !isController
                                            ? () => {}
                                            : () {
                                                Navigator.of(context).pop();
                                                _onAction(() =>
                                                    Navigator.of(context)
                                                        .pushNamed(
                                                            UnBondPage.route));
                                              },
                                      ),

                                      // redeem unlocked
                                      CupertinoActionSheetAction(
                                        child: Text(
                                          dic['action.redeem']!,
                                          style: TextStyle(
                                            color: redeemable == BigInt.zero ||
                                                    !isController
                                                ? disabledColor
                                                : actionButtonColor,
                                          ),
                                        ),
                                        onPressed: redeemable == BigInt.zero ||
                                                !isController
                                            ? () => {}
                                            : () {
                                                Navigator.of(context).pop();
                                                _onAction(() =>
                                                    Navigator.of(context)
                                                        .pushNamed(
                                                            RedeemPage.route));
                                              },
                                      ),
                                    ],
                                    cancelButton: CupertinoActionSheetAction(
                                      child: Text(I18n.of(context)!.getDic(
                                          i18n_full_dic_kusama,
                                          'common')!['cancel']!),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                            GridViewItemBtn(
                              Image.asset(
                                'packages/polkawallet_plugin_kusama/assets/images/staking/icon_rewardMethod.png',
                                width: 36,
                              ),
                              dic['v3.rewardDest']!,
                              onTap: () {
                                if ((isStash &&
                                        widget.plugin.store.staking
                                            .ownStashInfo!.isOwnController!) ||
                                    (!isStash && bonded > BigInt.zero)) {
                                  _onAction(() => Navigator.of(context)
                                      .pushNamed(SetPayeePage.route));
                                } else {
                                  showCupertinoDialog(
                                      context: context,
                                      builder: (_) {
                                        return CupertinoAlertDialog(
                                          content: Text(dic['v3.stashError']!),
                                          actions: <Widget>[
                                            CupertinoDialogAction(
                                              child:
                                                  Text(dic['v3.iUnderstand']!),
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                            ),
                                          ],
                                        );
                                      });
                                }
                              },
                            ),
                            GridViewItemBtn(
                              Image.asset(
                                'packages/polkawallet_plugin_kusama/assets/images/staking/icon_rewardDetail.png',
                                width: 36,
                              ),
                              dic['v3.rewardDetail']!,
                              onTap: () => Navigator.of(context)
                                  .pushNamed(RewardDetailNewPage.route),
                            ),
                            GridViewItemBtn(
                              Image.asset(
                                'packages/polkawallet_plugin_kusama/assets/images/staking/icon_payouts.png',
                                width: 36,
                              ),
                              dic['action.payout']!,
                              onTap: () => _onAction(() => Navigator.of(context)
                                  .pushNamed(PayoutPage.route)),
                            ),
                            GridViewItemBtn(
                              Image.asset(
                                'packages/polkawallet_plugin_kusama/assets/images/staking/icon_account.png',
                                width: 36,
                              ),
                              dic['v3.account']!,
                              onTap: () => _onAction(() => Navigator.of(context)
                                  .pushNamed(SetControllerPage.route,
                                      arguments: acc02)),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                PluginTextTag(
                                  padding: EdgeInsets.zero,
                                  title: dic['v3.nominations']!,
                                  child: Row(
                                    children: [
                                      Text(
                                        dic['v3.nominations']!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5
                                            ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF212123)),
                                      ),
                                      Text(
                                        " (${widget.plugin.store.staking.ownStashInfo!.nominating!.length.toString()})",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5
                                            ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFFFF7849)),
                                      )
                                    ],
                                  ),
                                  backgroundColor: Color(0xCCFFFFFF),
                                ),
                                Visibility(
                                    visible: widget.plugin.store.staking
                                            .ownStashInfo!.nominating!.length >
                                        0,
                                    child: PluginOutlinedButtonSmall(
                                      margin: EdgeInsets.only(bottom: 6),
                                      content: dic['v3.stopAll'],
                                      color: Color(0xFFFF7849),
                                      active: true,
                                      fontSize: 12,
                                      minSize: 19,
                                      onPressed: () {
                                        if (isStash && !isController!) {
                                          showCupertinoDialog(
                                              context: context,
                                              builder: (_) {
                                                return CupertinoAlertDialog(
                                                  content: Text(
                                                      dic['v3.stashError']!),
                                                  actions: <Widget>[
                                                    CupertinoDialogAction(
                                                      child: Text(dic[
                                                          'v3.iUnderstand']!),
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(),
                                                    ),
                                                  ],
                                                );
                                              });
                                          return;
                                        }
                                        _chill();
                                      },
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 2),
                                    ))
                              ],
                            ),
                            Container(
                                padding: EdgeInsets.only(
                                    left: 5, top: 10, right: 5, bottom: 10),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Color(0x24FFFFFF),
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(14),
                                        topRight: Radius.circular(14),
                                        bottomRight: Radius.circular(14))),
                                child: widget.plugin.store.staking.ownStashInfo!
                                            .nominating!.length >
                                        0
                                    ? ListView(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        children: _buildNominatingList(),
                                      )
                                    : Container(
                                        padding: EdgeInsets.only(
                                            left: 5,
                                            top: 10,
                                            right: 5,
                                            bottom: 10),
                                        width: double.infinity,
                                        alignment: Alignment.center,
                                        child: Text(
                                          dic['v3.noNomination']!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline5
                                              ?.copyWith(
                                                  fontSize: 12,
                                                  color: Colors.white),
                                        ),
                                      ))
                          ],
                        )
                      ],
                    ),
                  )),
              DragDropBtn(
                onTap: () {
                  if (isStash && !isController!) {
                    showCupertinoDialog(
                        context: context,
                        builder: (_) {
                          return CupertinoAlertDialog(
                            content: Text(dic['v3.stashError']!),
                            actions: <Widget>[
                              CupertinoDialogAction(
                                child: Text(dic['v3.iUnderstand']!),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          );
                        });
                    return;
                  }
                  Navigator.of(context).pushNamed(NominatePage.route);
                },
              ),
            ]);
    });
  }

  List<Widget> _buildNominatingList() {
    if (widget.plugin.store.staking.ownStashInfo == null ||
        widget.plugin.store.staking.validatorsInfo.length == 0) {
      return [];
    }

    final stashId = widget.plugin.store.staking.ownStashInfo!.stashId;
    final NomineesInfoData? nomineesInfo =
        widget.plugin.store.staking.ownStashInfo!.inactives;
    List<Widget> list = [];
    if (nomineesInfo != null) {
      list.addAll(nomineesInfo.nomsActive!.map((id) {
        return _NomineeItem(
          id,
          widget.plugin.store.staking.validatorsInfo,
          stashId,
          NomStatus.active,
          widget.plugin.networkState.tokenDecimals![0],
          widget.plugin.store.accounts.addressIndexMap,
          widget.plugin.store.accounts.addressIconsMap,
        );
      }));

      list.addAll(nomineesInfo.nomsOver!.map((id) {
        return _NomineeItem(
          id,
          widget.plugin.store.staking.validatorsInfo,
          stashId,
          NomStatus.over,
          widget.plugin.networkState.tokenDecimals![0],
          widget.plugin.store.accounts.addressIndexMap,
          widget.plugin.store.accounts.addressIconsMap,
        );
      }).toList());

      list.addAll(nomineesInfo.nomsInactive!.map((id) {
        return _NomineeItem(
          id,
          widget.plugin.store.staking.validatorsInfo,
          stashId,
          NomStatus.inactive,
          widget.plugin.networkState.tokenDecimals![0],
          widget.plugin.store.accounts.addressIndexMap,
          widget.plugin.store.accounts.addressIconsMap,
        );
      }).toList());

      list.addAll(nomineesInfo.nomsWaiting!.map((id) {
        return _NomineeItem(
          id,
          widget.plugin.store.staking.validatorsInfo,
          stashId,
          NomStatus.waiting,
          widget.plugin.networkState.tokenDecimals![0],
          widget.plugin.store.accounts.addressIndexMap,
          widget.plugin.store.accounts.addressIconsMap,
        );
      }).toList());
    }
    return list;
  }
}

class _NomineeItem extends StatelessWidget {
  _NomineeItem(
    this.id,
    this.validators,
    this.stashId,
    this.nomStatus,
    this.decimals,
    this.accInfoMap,
    this.accIconMap,
  );

  final String id;
  final List<ValidatorData> validators;
  final String? stashId;
  final NomStatus nomStatus;
  final int decimals;
  final Map<String?, Map?> accInfoMap;
  final Map<String?, String?> accIconMap;

  @override
  Widget build(BuildContext context) {
    final dicStaking =
        I18n.of(context)!.getDic(i18n_full_dic_kusama, 'staking')!;

    final validatorIndex = validators.indexWhere((i) => i.accountId == id);
    final validator = validatorIndex < 0
        ? ValidatorData.fromJson({'accountId': id})
        : validators[validatorIndex];

    final accInfo = accInfoMap[validator.accountId];
    final icon = accIconMap[validator.accountId];

    BigInt? meStaked;
    int meIndex = validator.nominators.indexWhere((i) => i['who'] == stashId);
    if (meIndex >= 0) {
      meStaked =
          BigInt.parse(validator.nominators[meIndex]['value'].toString());
    }

    return Column(
      children: [
        ListTile(
          dense: true,
          leading: AddressIconTag(
            validator.accountId,
            nomStatus,
            svg: icon,
            size: 38,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UI.accountDisplayName(validator.accountId, accInfo,
                  style: TextStyle(
                      fontSize: 14,
                      fontFamily: "TitilliumWeb",
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              Text(
                "${dicStaking['total']}: ${Fmt.token(meStaked ?? BigInt.zero, decimals)}",
                style: Theme.of(context)
                    .textTheme
                    .headline5
                    ?.copyWith(fontSize: 10, color: Colors.white),
              ),
              Text(
                "${dicStaking['commission']}: ${NumberFormat('0.00%').format(validator.commission / 100)}",
                style: Theme.of(context)
                    .textTheme
                    .headline5
                    ?.copyWith(fontSize: 10, color: Colors.white),
              )
            ],
          ),
          // subtitle: Text(
          //   "${dicStaking['total']}: ${Fmt.token(meStaked ?? BigInt.zero, decimals)}",
          //   style: Theme.of(context)
          //       .textTheme
          //       .headline5
          //       ?.copyWith(fontSize: 10, color: Colors.white),
          // ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(dicStaking['reward']!,
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
          ),
          onTap: () {
            print("onTap");
            Navigator.of(context)
                .pushNamed(ValidatorDetailPage.route, arguments: validator);
          },
        ),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Divider(
              color: Colors.white.withAlpha(36),
              height: 5,
            ))
      ],
    );
  }
}

class GridViewItemBtn extends StatefulWidget {
  GridViewItemBtn(this.icon, this.text, {Key? key, this.onTap})
      : super(key: key);
  Widget icon;
  String text;
  Function()? onTap;

  @override
  State<GridViewItemBtn> createState() => _GridViewItemBtnState();
}

class _GridViewItemBtnState extends State<GridViewItemBtn> {
  bool _onTapDown = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: widget.onTap,
        onPanDown: (tapDownDetails) {
          setState(() {
            _onTapDown = true;
          });
        },
        onPanCancel: () {
          setState(() {
            _onTapDown = false;
          });
        },
        onPanEnd: (tapUpDetails) {
          setState(() {
            _onTapDown = false;
          });
        },
        child: Container(
          padding: EdgeInsets.all(1),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 1.0],
                colors: [Color(0xFFFF7849), Color(0x1AFFA180)]),
            borderRadius: BorderRadius.all(
              Radius.circular(5.0),
            ),
          ),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [
                    0.0,
                    1.0
                  ],
                  colors: [
                    _onTapDown
                        ? Color.fromARGB(255, 86, 70, 65)
                        : Color.fromARGB(255, 57, 59, 62),
                    _onTapDown
                        ? Color.fromARGB(255, 145, 91, 71)
                        : Color.fromARGB(255, 57, 59, 62)
                  ]),
              borderRadius: BorderRadius.all(
                Radius.circular(5.0),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                widget.icon,
                Text(
                  widget.text,
                  style: Theme.of(context).textTheme.headline5?.copyWith(
                      color: Color(0xFFFF7849),
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        ));
  }
}

class DragDropBtn extends StatefulWidget {
  DragDropBtn({Key? key, this.onTap}) : super(key: key);
  Function()? onTap;

  @override
  State<DragDropBtn> createState() => _DragDropBtnState();
}

class _DragDropBtnState extends State<DragDropBtn> {
  Offset? offset;
  final GlobalKey globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    if (offset == null) {
      offset = Offset(
          MediaQuery.of(context).size.width - 48 - 17,
          MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom -
              kToolbarHeight -
              48 -
              50 -
              90);
    }
    return Container(
        key: globalKey,
        child: Stack(
          children: [
            Positioned(
                left: offset!.dx,
                top: offset!.dy,
                child: GestureDetector(
                    onTap: widget.onTap,
                    onPanUpdate: (details) {
                      var dx = offset!.dx + details.delta.dx;
                      if (dx < 0) {
                        dx = 0;
                      } else if (dx >
                          globalKey.currentContext!.size!.width - 48) {
                        dx = globalKey.currentContext!.size!.width - 48;
                      }
                      var dy = offset!.dy + details.delta.dy;
                      if (dy < -40) {
                        dy = -40;
                      } else if (dy >
                          globalKey.currentContext!.size!.height - 40 - 48) {
                        dy = globalKey.currentContext!.size!.height - 40 - 48;
                      }
                      setState(() {
                        offset = Offset(dx, dy);
                      });
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(top: 40),
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(const Radius.circular(24)),
                        color: Color(0xFFFF7849),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFFF9A77),
                            blurRadius: 8.0,
                            spreadRadius: 0.0,
                            offset: Offset(
                              0.0,
                              0.0,
                            ),
                          )
                        ],
                      ),
                      child: SvgPicture.asset(
                        "packages/polkawallet_plugin_kusama/assets/images/staking/icon_nomination.svg",
                        color: Colors.white,
                        width: 37,
                      ),
                    )))
          ],
        ));
  }
}
