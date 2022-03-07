import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:polkawallet_sdk/api/types/parachain/fundData.dart';
import 'package:polkawallet_ui/components/infoItemRow.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginOutlinedButtonSmall.dart';
import 'package:polkawallet_ui/components/v3/plugin/roundedPluginCard.dart';
import 'package:polkawallet_ui/utils/consts.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/index.dart';

class CrowdLoanListItem extends StatefulWidget {
  CrowdLoanListItem({
    required this.fund,
    required this.index,
    required this.config,
    required this.contributions,
    required this.decimals,
    required this.tokenSymbol,
    required this.onContribute,
  });
  final FundData fund;
  final int index;
  final Map config;
  final Map contributions;
  final int decimals;
  final String tokenSymbol;
  final Future<void> Function() onContribute;

  @override
  _CrowdLoanListItemState createState() => _CrowdLoanListItemState();
}

class _CrowdLoanListItemState extends State<CrowdLoanListItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final textStyle =
        Theme.of(context).textTheme.headline5?.copyWith(color: Colors.white);

    final logoUri = widget.config[widget.fund.paraId]['logo'] as String;

    final isEnded =
        widget.fund.isWinner || widget.fund.isEnded || widget.fund.isCapped;

    final name = (widget.config[widget.fund.paraId]['name'] as String).length >
            13
        ? '${(widget.config[widget.fund.paraId]['name'] as String).substring(0, 13)}...'
        : (widget.config[widget.fund.paraId]['name'] as String);
    final amount = widget.contributions[widget.fund.paraId] == null
        ? '--.--'
        : Fmt.balance(widget.contributions[widget.fund.paraId], widget.decimals,
            length: 2);

    final raised =
        '${Fmt.balance(widget.fund.value.toString(), widget.decimals, length: 0)}/${Fmt.balance(widget.fund.cap.toString(), widget.decimals, length: 0)}';

    return GestureDetector(
      child: RoundedPluginCard(
        margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
        borderRadius: widget.index == 0
            ? BorderRadius.only(
                topRight: Radius.circular(8),
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8))
            : BorderRadius.all(Radius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              (isEnded ? 'Completed' : 'Ongoing').toUpperCase(),
              style: Theme.of(context).textTheme.headline3!.copyWith(
                  color: isEnded
                      ? PluginColorsDark.headline3
                      : PluginColorsDark.green,
                  fontSize: 14),
            ),
            Container(
              child: Row(
                children: [
                  Expanded(
                      child: Text(
                    '#${widget.fund.paraId}',
                    style: Theme.of(context).textTheme.headline3!.copyWith(
                        color: PluginColorsDark.headline1,
                        fontSize: 22,
                        height: 1.2),
                  )),
                  isEnded
                      ? Container()
                      : PluginOutlinedButtonSmall(
                          content: 'Contribute',
                          active: true,
                          onPressed: widget.onContribute,
                          color: PluginColorsDark.primary,
                          activeTextcolor: PluginColorsDark.headline1,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          margin: EdgeInsets.zero,
                        )
                ],
              ),
              margin: EdgeInsets.only(bottom: 4),
            ),
            Container(
              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        color: Colors.white,
                        child: logoUri.contains('.svg')
                            ? SvgPicture.network(logoUri, height: 30)
                            : Image.network(logoUri, height: 30),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 4),
                    child: Text(
                      name,
                      style: Theme.of(context).textTheme.headline3!.copyWith(
                          color: PluginColorsDark.headline1, fontSize: 16),
                    ),
                  ),
                  GestureDetector(
                    child: Image.asset(
                      'packages/polkawallet_plugin_kusama/assets/images/public/icon_link.png',
                      width: 20,
                    ),
                    onTap: () => UI.launchURL(
                        widget.config[widget.fund.paraId]['homepage']),
                  ),
                  Expanded(
                    child: Text(
                      'You Contributed: $amount ${widget.tokenSymbol}',
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.headline4!.copyWith(
                          color: PluginColorsDark.headline1, fontSize: 12),
                    ),
                  )
                ],
              ),
              margin: EdgeInsets.only(bottom: 4),
            ),
            Visibility(
              visible: _expanded,
              child: InfoItemRow(
                'Raised/Cap',
                raised,
                labelStyle: textStyle,
                contentStyle: textStyle,
              ),
            ),
            Visibility(
              visible: _expanded,
              child: InfoItemRow(
                'Leases',
                '${widget.fund.firstSlot} - ${widget.fund.lastSlot}',
                labelStyle: textStyle,
                contentStyle: textStyle,
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        setState(() {
          _expanded = !_expanded;
        });
      },
    );
  }
}
