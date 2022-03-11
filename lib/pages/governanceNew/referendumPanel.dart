import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_kusama/pages/governanceNew/referendumVotePage.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/api/types/gov/referendumInfoData.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/infoItemRow.dart';
import 'package:polkawallet_ui/utils/consts.dart';
import 'package:polkawallet_ui/utils/format.dart';

class ReferendumPanel extends StatefulWidget {
  ReferendumPanel({
    Key? key,
    this.symbol,
    this.decimals,
    this.data,
    this.bestNumber,
    this.onCancelVote,
    this.blockDuration,
    this.links,
    this.onRefresh,
    this.isLock,
  }) : super(key: key);

  final String? symbol;
  final int? decimals;
  final ReferendumInfo? data;
  final BigInt? bestNumber;
  final Function(int)? onCancelVote;
  final int? blockDuration;
  final Widget? links;
  final Function? onRefresh;
  final bool? isLock;

  @override
  State<ReferendumPanel> createState() => _ReferendumPanelState();
}

class _ReferendumPanelState extends State<ReferendumPanel> {
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
    final endLeft = BigInt.parse(widget.data!.status!['end'].toString()) -
        widget.bestNumber!;
    final activateLeft =
        endLeft + BigInt.parse(widget.data!.status!['delay'].toString());
    var dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov')!;
    List<Widget?> list = <Widget?>[
      Visibility(
        visible: widget.data!.detail!['content'].toString().isNotEmpty,
        child: Text(
          "${widget.data!.image != null && widget.data!.image!['proposal'] != null ? '${widget.data!.image!['proposal']['section']}.${widget.data!.image!['proposal']['method']}\n' : ''}${(widget.data!.detail!['content'] ?? "").toString().trim()}",
          style: Theme.of(context)
              .textTheme
              .headline5
              ?.copyWith(fontSize: 12, color: Colors.white),
        ),
      ),
      Padding(
          padding: EdgeInsets.only(top: 9),
          child: Row(
            children: [
              Expanded(
                  child: GestureDetector(
                      onTap: () async {
                        if ('Nay' ==
                            (widget.data!.userVoted?['vote']['vote'] ?? '')) {
                          showCupertinoModalPopup(
                            context: context,
                            barrierDismissible: true,
                            builder: (BuildContext context) {
                              return CupertinoActionSheet(
                                title: Text(dic['vote']!),
                                message: Text(dic['v3.voteMessage.nay']!),
                                actions: [
                                  CupertinoActionSheetAction(
                                    child: Text(dic['v3.continueVote']!),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _referendumAction(false);
                                    },
                                  ),
                                  CupertinoActionSheetAction(
                                    child: Text(dic['v3.cancelMyVote']!),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      widget.onCancelVote!(
                                          widget.data!.index!.toInt());
                                    },
                                  )
                                ],
                                cancelButton: CupertinoActionSheetAction(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(I18n.of(context)!.getDic(
                                      i18n_full_dic_kusama,
                                      'common')!['cancel']!),
                                ),
                              );
                            },
                          );
                        } else {
                          _referendumAction(false);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 28,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(2)),
                          color: Color.fromARGB(255, 160, 160, 160),
                        ),
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            Container(
                              width: 'Nay' ==
                                      (widget.data!.userVoted?['vote']
                                              ['vote'] ??
                                          '')
                                  ? double.infinity
                                  : widget.data!.userVoted == null
                                      ? 7
                                      : 0,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(2)),
                                color: PluginColorsDark.primary,
                              ),
                            ),
                            Padding(
                                padding:
                                    EdgeInsets.only(top: 4, bottom: 4, left: 9),
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
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.data!.voteCountNay ?? 0}',
                    style: Theme.of(context).textTheme.headline5?.copyWith(
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.2,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${Fmt.balance(widget.data!.votedNay!, widget.decimals!)} ${widget.symbol}',
                    style: Theme.of(context).textTheme.headline5?.copyWith(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w300),
                  ),
                ],
              ))
            ],
          )),
      Padding(
          padding: EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Expanded(
                  child: GestureDetector(
                      onTap: () async {
                        if ('Aye' ==
                            (widget.data!.userVoted?['vote']['vote'] ?? '')) {
                          showCupertinoModalPopup(
                            context: context,
                            barrierDismissible: true,
                            builder: (BuildContext context) {
                              return CupertinoActionSheet(
                                title: Text(dic['vote']!),
                                message: Text(dic['v3.voteMessage.aye']!),
                                actions: [
                                  CupertinoActionSheetAction(
                                    child: Text(dic['v3.continueVote']!),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _referendumAction(true);
                                    },
                                  ),
                                  CupertinoActionSheetAction(
                                    child: Text(dic['v3.cancelMyVote']!),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      widget.onCancelVote!(
                                          widget.data!.index!.toInt());
                                    },
                                  )
                                ],
                                cancelButton: CupertinoActionSheetAction(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(I18n.of(context)!.getDic(
                                      i18n_full_dic_kusama,
                                      'common')!['cancel']!),
                                ),
                              );
                            },
                          );
                        } else {
                          _referendumAction(true);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 28,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(2)),
                          color: Color.fromARGB(255, 160, 160, 160),
                        ),
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            Container(
                                width: 'Aye' ==
                                        (widget.data!.userVoted?['vote']
                                                ['vote'] ??
                                            '')
                                    ? double.infinity
                                    : widget.data!.userVoted == null
                                        ? 7
                                        : 0,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(2)),
                                  color: PluginColorsDark.green,
                                )),
                            Padding(
                                padding:
                                    EdgeInsets.only(top: 4, bottom: 4, left: 9),
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
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.data!.voteCountAye ?? 0}',
                    style: Theme.of(context).textTheme.headline5?.copyWith(
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.2,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${Fmt.balance(widget.data!.votedAye!, widget.decimals!)} ${widget.symbol}',
                    style: Theme.of(context).textTheme.headline5?.copyWith(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w300),
                  ),
                ],
              ))
            ],
          ))
    ];
    if (_isExpansion) {
      list.addAll([
        Padding(
          padding: EdgeInsets.only(top: 8),
          child: InfoItemRow(
            dic['remain']!,
            '${Fmt.blockToTime(endLeft.toInt(), widget.blockDuration!)}(${Fmt.priceFloorBigInt(endLeft, 0, lengthFixed: 0)} blocks)',
            labelStyle: Theme.of(context)
                .textTheme
                .headline5
                ?.copyWith(fontSize: 12, color: Colors.white),
            contentStyle: Theme.of(context)
                .textTheme
                .headline5
                ?.copyWith(fontSize: 12, color: Colors.white),
          ),
        ),
        Visibility(
            visible: widget.data!.isPassing!,
            child: Padding(
              padding: EdgeInsets.only(top: 4),
              child: InfoItemRow(
                dic['activate']!,
                '${Fmt.blockToTime(activateLeft.toInt(), widget.blockDuration!)}(#${Fmt.priceFloorBigInt(widget.bestNumber! + activateLeft, 0, lengthFixed: 0)})',
                labelStyle: Theme.of(context)
                    .textTheme
                    .headline5
                    ?.copyWith(fontSize: 12, color: Colors.white),
                contentStyle: Theme.of(context)
                    .textTheme
                    .headline5
                    ?.copyWith(fontSize: 12, color: Colors.white),
              ),
            )),
        Container(
            padding: EdgeInsets.only(top: 20),
            width: double.infinity,
            alignment: Alignment.centerRight,
            child: widget.links)
      ]);
    }
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.only(left: 16, top: 8),
                          child: Row(
                            children: [
                              Text(
                                '#${widget.data!.index}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline3
                                    ?.copyWith(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                              ),
                              Visibility(
                                  child: Container(
                                padding: EdgeInsets.only(left: 4),
                                child: Image.asset(
                                  "packages/polkawallet_plugin_kusama/assets/images/gov/voted.png",
                                  width: 24,
                                ),
                              ))
                            ],
                          )),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                          color: Color(0x1AFFFFFF),
                        ),
                        child: Text(
                          dic['v3.passing.${widget.data!.isPassing}']!,
                          style: Theme.of(context)
                              .textTheme
                              .headline5
                              ?.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: (widget.data!.isPassing ?? false)
                                      ? PluginColorsDark.green
                                      : PluginColorsDark.primary),
                        ),
                      )
                    ]),
                Padding(
                  padding: EdgeInsets.only(bottom: 16, left: 16, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: list as List<Widget>,
                  ),
                )
              ],
            )));
  }
}
