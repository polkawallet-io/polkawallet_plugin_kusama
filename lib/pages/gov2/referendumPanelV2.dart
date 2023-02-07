import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_kusama/pages/gov2/VotePage.dart';
import 'package:polkawallet_plugin_kusama/pages/governanceNew/referendumVotePage.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/api/types/gov/referendumV2Data.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/infoItemRow.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginButton.dart';
import 'package:polkawallet_ui/utils/consts.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/index.dart';

class ReferendumPanelV2 extends StatefulWidget {
  ReferendumPanelV2({
    Key? key,
    required this.symbol,
    required this.decimals,
    required this.data,
    required this.bestNumber,
    this.onCancelVote,
    this.blockDuration,
    this.links,
    this.onRefresh,
    this.isLock,
  }) : super(key: key);

  final String symbol;
  final int decimals;
  final ReferendumItem data;
  final BigInt bestNumber;
  final Function(int)? onCancelVote;
  final int? blockDuration;
  final Widget? links;
  final Function? onRefresh;
  final bool? isLock;

  @override
  State<ReferendumPanelV2> createState() => _ReferendumPanelV2State();
}

class _ReferendumPanelV2State extends State<ReferendumPanelV2> {
  bool _isExpansion = false;

  Future<void> _referendumAction(bool voteYes) async {
    final res = await Navigator.of(context).pushNamed(ReferendumVotePage.route,
        arguments: {
          'referenda': widget.data,
          'voteYes': voteYes,
          'isLock': widget.isLock
        });
    if (res != null) {
      widget.onRefresh!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final endLeft =
        BigInt.parse(widget.data.periodEnd ?? '') - widget.bestNumber;
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov')!;

    final isPassing =
        BigInt.parse(widget.data.ayes) > BigInt.parse(widget.data.nays);

    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _isExpansion = !_isExpansion;
          });
        },
        child: Container(
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(8),
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              color: PluginColorsDark.cardColor,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 16),
                      child: Text(
                        '#${widget.data.key}',
                        style: Theme.of(context).textTheme.headline3?.copyWith(
                            fontSize: UI.getTextSize(22, context),
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 4, right: 4),
                      child: Image.asset(
                        "packages/polkawallet_plugin_kusama/assets/images/gov/voted.png",
                        width: 24,
                      ),
                    ),
                    Expanded(
                        child: Text(
                      widget.data.confirmEnd != null
                          ? 'Confirming'
                          : widget.data.decideEnd != null
                              ? 'Deciding'
                              : 'Preparing',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: PluginColorsDark.green),
                    )),
                    Container(
                      padding: EdgeInsets.all(0),
                      margin: EdgeInsets.fromLTRB(0, 8, 8, 0),
                      width: 100,
                      child: PluginButton(
                        height: 36,
                        title: 'Vote',
                        onPressed: () => Navigator.of(context)
                            .pushNamed(VotePage.route, arguments: {
                          'referenda': widget.data,
                          'isLock': false,
                        }),
                      ),
                    ),
                  ],
                ),
                // Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: <Widget>[
                //       Expanded(
                //           child: Container(
                //               margin: EdgeInsets.only(left: 16, top: 8),
                //               child: )),
                //       Container(
                //         padding:
                //             EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                //         child: PluginButton(
                //           title: 'Vote',
                //           onPressed: () => Navigator.of(context)
                //               .pushNamed(VotePage.route, arguments: {
                //             'referenda': widget.data,
                //             'isLock': false,
                //           }),
                //         ),
                //       )
                //     ]),
                Padding(
                  padding: EdgeInsets.only(bottom: 16, left: 16, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.data.callDocs == null
                            ? Fmt.address(widget.data.proposalHash, pad: 12)
                            : "${widget.data.callMethod.isNotEmpty ? '${widget.data.callMethod}\n' : ''}${widget.data.callDocs.toString().trim()}",
                        style: Theme.of(context).textTheme.headline5?.copyWith(
                            fontSize: UI.getTextSize(12, context),
                            color: Colors.white),
                      ),
                      Padding(
                          padding: EdgeInsets.only(top: 9),
                          child: Row(
                            children: [
                              Expanded(
                                  child: GestureDetector(
                                      // onTap: () async {
                                      //   if ('Nay' ==
                                      //       (widget.data!.userVoted?['vote']['vote'] ?? '')) {
                                      //     showCupertinoModalPopup(
                                      //       context: context,
                                      //       barrierDismissible: true,
                                      //       builder: (BuildContext context) {
                                      //         return PolkawalletActionSheet(
                                      //           title: Text(dic['vote']!),
                                      //           message: Text(dic['v3.voteMessage.nay']!),
                                      //           actions: [
                                      //             PolkawalletActionSheetAction(
                                      //               child: Text(dic['v3.continueVote']!),
                                      //               onPressed: () {
                                      //                 Navigator.of(context).pop();
                                      //                 _referendumAction(false);
                                      //               },
                                      //             ),
                                      //             PolkawalletActionSheetAction(
                                      //               child: Text(dic['v3.cancelMyVote']!),
                                      //               onPressed: () {
                                      //                 Navigator.of(context).pop();
                                      //                 widget.onCancelVote!(
                                      //                     widget.data!.index!.toInt());
                                      //               },
                                      //             )
                                      //           ],
                                      //           cancelButton: PolkawalletActionSheetAction(
                                      //             onPressed: () {
                                      //               Navigator.pop(context);
                                      //             },
                                      //             child: Text(I18n.of(context)!.getDic(
                                      //                 i18n_full_dic_kusama,
                                      //                 'common')!['cancel']!),
                                      //           ),
                                      //         );
                                      //       },
                                      //     );
                                      //   } else {
                                      //     _referendumAction(false);
                                      //   }
                                      // },
                                      child: Container(
                                width: double.infinity,
                                height: 28,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(2)),
                                  color: Color.fromARGB(255, 160, 160, 160),
                                ),
                                child: Stack(
                                  alignment: Alignment.centerLeft,
                                  children: [
                                    Container(
                                      width: 7,
                                      // width: 'Nay' ==
                                      //         (widget.data!.userVoted?['vote']
                                      //                 ['vote'] ??
                                      //             '')
                                      //     ? double.infinity
                                      //     : widget.data!.userVoted == null
                                      //         ? 7
                                      //         : 0,
                                      height: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(2)),
                                        color: PluginColorsDark.primary,
                                      ),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(
                                            top: 4, bottom: 4, left: 9),
                                        child: Text(
                                          dic['no']!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline4
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  height: 1.1,
                                                  color: Color(0xFF222426)),
                                        ))
                                  ],
                                ),
                              ))),
                              Container(width: 16),
                              Expanded(
                                child: Text(
                                  Fmt.balance(
                                          widget.data.nays, widget.decimals) +
                                      ' ${widget.symbol}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline5
                                      ?.copyWith(
                                          fontSize: UI.getTextSize(14, context),
                                          color: Colors.white,
                                          height: 1.2,
                                          fontWeight: FontWeight.w600),
                                ),
                              )
                            ],
                          )),
                      Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Expanded(
                                  child: GestureDetector(
                                      // onTap: () async {
                                      //   if ('Aye' ==
                                      //       (widget.data!.userVoted?['vote']['vote'] ?? '')) {
                                      //     showCupertinoModalPopup(
                                      //       context: context,
                                      //       barrierDismissible: true,
                                      //       builder: (BuildContext context) {
                                      //         return PolkawalletActionSheet(
                                      //           title: Text(dic['vote']!),
                                      //           message: Text(dic['v3.voteMessage.aye']!),
                                      //           actions: [
                                      //             PolkawalletActionSheetAction(
                                      //               child: Text(dic['v3.continueVote']!),
                                      //               onPressed: () {
                                      //                 Navigator.of(context).pop();
                                      //                 _referendumAction(true);
                                      //               },
                                      //             ),
                                      //             PolkawalletActionSheetAction(
                                      //               child: Text(dic['v3.cancelMyVote']!),
                                      //               onPressed: () {
                                      //                 Navigator.of(context).pop();
                                      //                 widget.onCancelVote!(
                                      //                     widget.data!.index!.toInt());
                                      //               },
                                      //             )
                                      //           ],
                                      //           cancelButton: PolkawalletActionSheetAction(
                                      //             onPressed: () {
                                      //               Navigator.pop(context);
                                      //             },
                                      //             child: Text(I18n.of(context)!.getDic(
                                      //                 i18n_full_dic_kusama,
                                      //                 'common')!['cancel']!),
                                      //           ),
                                      //         );
                                      //       },
                                      //     );
                                      //   } else {
                                      //     _referendumAction(true);
                                      //   }
                                      // },
                                      child: Container(
                                width: double.infinity,
                                height: 28,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(2)),
                                  color: Color.fromARGB(255, 160, 160, 160),
                                ),
                                child: Stack(
                                  alignment: Alignment.centerLeft,
                                  children: [
                                    Container(
                                        width: 7,
                                        // width: 'Aye' ==
                                        //         (widget.data!.userVoted?['vote']
                                        //                 ['vote'] ??
                                        //             '')
                                        //     ? double.infinity
                                        //     : widget.data!.userVoted == null
                                        //         ? 7
                                        //         : 0,
                                        height: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(2)),
                                          color: PluginColorsDark.green,
                                        )),
                                    Padding(
                                        padding: EdgeInsets.only(
                                            top: 4, bottom: 4, left: 9),
                                        child: Text(
                                          dic['yes']!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline4
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  height: 1.1,
                                                  color: Color(0xFF222426)),
                                        ))
                                  ],
                                ),
                              ))),
                              Container(width: 16),
                              Expanded(
                                child: Text(
                                  Fmt.balance(
                                          widget.data.ayes, widget.decimals) +
                                      ' ${widget.symbol}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline5
                                      ?.copyWith(
                                          fontSize: UI.getTextSize(14, context),
                                          color: Colors.white,
                                          height: 1.2,
                                          fontWeight: FontWeight.w600),
                                ),
                              )
                            ],
                          )),
                      Visibility(
                          visible: _isExpansion,
                          child: Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: InfoItemRow(
                              dic['remain']!,
                              '${Fmt.blockToTime(endLeft.toInt(), widget.blockDuration!)}(${Fmt.priceFloorBigInt(endLeft, 0, lengthFixed: 0)} blocks)',
                              labelStyle: Theme.of(context)
                                  .textTheme
                                  .headline5
                                  ?.copyWith(
                                      fontSize: UI.getTextSize(12, context),
                                      color: Colors.white),
                              contentStyle: Theme.of(context)
                                  .textTheme
                                  .headline5
                                  ?.copyWith(
                                      fontSize: UI.getTextSize(12, context),
                                      color: Colors.white),
                            ),
                          )),
                      Visibility(
                          visible: _isExpansion,
                          child: Container(
                              padding: EdgeInsets.only(top: 20),
                              width: double.infinity,
                              alignment: Alignment.centerRight,
                              child: widget.links)),
                    ],
                  ),
                )
              ],
            )));
  }
}
