import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/api/types/gov/proposalInfoData.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/addressIcon.dart';
import 'package:polkawallet_ui/components/v3/infoItemRow.dart';
import 'package:polkawallet_ui/utils/consts.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/index.dart';

class ProposalPanel extends StatefulWidget {
  ProposalPanel(this.plugin, this.proposal, this.links, this.keyring,
      {Key? key, this.onSecondsAction})
      : super(key: key);
  final PluginKusama plugin;
  final ProposalInfoData proposal;
  final Keyring keyring;
  final Widget? links;
  final Function(ProposalInfoData)? onSecondsAction;

  @override
  State<ProposalPanel> createState() => _ProposalPanelState();
}

class _ProposalPanelState extends State<ProposalPanel> {
  bool _isExpansion = false;

  @override
  Widget build(BuildContext context) => Observer(
        builder: (_) {
          final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov')!;
          final decimals = widget.plugin.networkState.tokenDecimals![0];
          final symbol = widget.plugin.networkState.tokenSymbol![0];

          final style = Theme.of(context)
              .textTheme
              .headline5
              ?.copyWith(fontSize: 12, color: Colors.white);
          final List seconding = widget.proposal.seconds!.toList();
          final bool isSecondOn = widget.proposal.seconds!
                  .indexOf(widget.keyring.current.address!) >=
              0;
          seconding.removeAt(0);
          List<Widget> widgets = [];
          if (_isExpansion) {
            widgets.addAll([
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(dic['treasury.proposer']!, style: style),
                    Row(
                      children: [
                        AddressIcon(
                          widget.proposal.proposer,
                          svg: widget.plugin.store.accounts
                              .addressIconsMap[widget.proposal.proposer],
                          size: 14,
                        ),
                        Padding(
                            padding: EdgeInsets.only(left: 5),
                            child: UI.accountDisplayName(
                                widget.proposal.proposer,
                                widget.plugin.store.accounts
                                    .addressIndexMap[widget.proposal.proposer],
                                style: style,
                                expand: false))
                      ],
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: InfoItemRow(
                  dic['v3.locked']!,
                  '${Fmt.balance(
                    widget.proposal.balance.toString(),
                    decimals,
                  )} $symbol',
                  labelStyle: style,
                  contentStyle: style,
                ),
              ),
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
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                color: PluginColorsDark.cardColor,
              ),
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(bottom: 16),
              child: Column(
                children: <Widget>[
                  Row(
                    children: [
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '#${BigInt.parse(widget.proposal.index)}',
                            style: Theme.of(context)
                                .textTheme
                                .headline3
                                ?.copyWith(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                          ),
                          Text(
                            "${widget.proposal.image?.proposal == null ? "" : '${widget.proposal.image!.proposal!.section}.${widget.proposal.image!.proposal!.method}\n'}${widget.proposal.image?.proposal == null ? "" : widget.proposal.image!.proposal!.meta!.documentation!.trim()}",
                            style: style,
                          )
                        ],
                      )),
                      GestureDetector(
                          onTap: () {
                            if (widget.onSecondsAction != null && !isSecondOn) {
                              widget.onSecondsAction!(widget.proposal);
                            }
                          },
                          child: Padding(
                              padding: EdgeInsets.only(left: 15),
                              child: Column(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    margin: EdgeInsets.only(bottom: 4),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(4)),
                                      color: PluginColorsDark.green,
                                    ),
                                    alignment: Alignment.center,
                                    child: Image.asset(
                                      'packages/polkawallet_plugin_kusama/assets/images/gov/gov_seconds.png',
                                      width: 36,
                                    ),
                                  ),
                                  Text(
                                      '${dic['proposal.seconds']}:${seconding.length}',
                                      style: style)
                                ],
                              )))
                    ],
                  ),
                  ...widgets
                ],
              ),
            ),
          );
        },
      );
}
