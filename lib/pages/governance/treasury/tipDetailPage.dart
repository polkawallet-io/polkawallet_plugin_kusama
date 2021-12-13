import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_kusama/pages/governance/council/candidateDetailPage.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/api/types/gov/treasuryTipData.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/addressIcon.dart';
import 'package:polkawallet_ui/components/borderedTitle.dart';
import 'package:polkawallet_ui/components/roundedButton.dart';
import 'package:polkawallet_ui/components/roundedCard.dart';
import 'package:polkawallet_ui/components/txButton.dart';
import 'package:polkawallet_ui/components/v3/back.dart';
import 'package:polkawallet_ui/pages/txConfirmPage.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/index.dart';

class TipDetailPage extends StatefulWidget {
  TipDetailPage(this.plugin, this.keyring);
  final PluginKusama plugin;
  final Keyring keyring;

  static const String route = '/gov/treasury/tip';

  @override
  _TipDetailPageState createState() => _TipDetailPageState();
}

class _TipDetailPageState extends State<TipDetailPage> {
  final TextEditingController _tipInputCtrl = TextEditingController();

  Future<void> _onEndorse() async {
    final symbol = widget.plugin.networkState.tokenSymbol![0];
    final decimals = widget.plugin.networkState.tokenDecimals![0];
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'common')!;
        final dicGov = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov')!;
        return CupertinoAlertDialog(
          title: Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
                '${dicGov['treasury.tip']} - ${dicGov['treasury.endorse']}'),
          ),
          content: CupertinoTextField(
            controller: _tipInputCtrl,
            suffix: Padding(
              padding: EdgeInsets.only(right: 8),
              child: Text(symbol),
            ),
            inputFormatters: [UI.decimalInputFormatter(decimals)!],
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          actions: <Widget>[
            CupertinoButton(
              child: Text(dic['cancel']!),
              onPressed: () {
                setState(() {
                  _tipInputCtrl.text = '';
                });
                Navigator.of(context).pop();
              },
            ),
            CupertinoButton(
              child: Text(dic['ok']!),
              onPressed: () {
                try {
                  final value = double.parse(_tipInputCtrl.text);
                  if (value >= 0) {
                    Navigator.of(context).pop();
                    _onEndorseSubmit();
                  } else {
                    _showTipInvalid();
                  }
                } catch (err) {
                  _showTipInvalid();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showTipInvalid() async {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'common')!;
        return CupertinoAlertDialog(
          title: Container(),
          content: Text(dic['input.invalid']!),
          actions: <Widget>[
            CupertinoButton(
              child: Text(dic['cancel']!),
              onPressed: () {
                setState(() {
                  _tipInputCtrl.text = '';
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _onEndorseSubmit() async {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov')!;
    final decimals = widget.plugin.networkState.tokenDecimals![0];
    final TreasuryTipData tipData =
        ModalRoute.of(context)!.settings.arguments as TreasuryTipData;
    String amt = _tipInputCtrl.text.trim();
    final args = TxConfirmParams(
      module: 'tips',
      call: 'tip',
      txTitle: '${dic['treasury.tip']} - ${dic['treasury.endorse']}',
      txDisplay: {
        "hash": Fmt.address(tipData.hash, pad: 16),
        "tipValue": amt,
      },
      params: [
        // "hash"
        tipData.hash,
        // "tipValue"
        Fmt.tokenInt(amt, decimals).toString(),
      ],
    );
    setState(() {
      _tipInputCtrl.text = '';
    });

    final res = await Navigator.of(context)
        .pushNamed(TxConfirmPage.route, arguments: args);
    if (res != null) {
      Navigator.of(context).pop(res);
    }
  }

  Future<void> _onCancel() async {
    var dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov')!;
    final TreasuryTipData tipData =
        ModalRoute.of(context)!.settings.arguments as TreasuryTipData;
    final args = TxConfirmParams(
      module: 'tips',
      call: 'retractTip',
      txTitle: '${dic['treasury.tip']} - ${dic['treasury.retract']}',
      txDisplay: {"hash": Fmt.address(tipData.hash, pad: 16)},
      params: [tipData.hash],
    );
    final res = await Navigator.of(context)
        .pushNamed(TxConfirmPage.route, arguments: args);
    if (res != null) {
      Navigator.of(context).pop(res);
    }
  }

  Future<void> _onCloseTip() async {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov')!;
    final TreasuryTipData tipData =
        ModalRoute.of(context)!.settings.arguments as TreasuryTipData;
    final args = TxConfirmParams(
      module: 'tips',
      call: 'closeTip',
      txTitle: '${dic['treasury.tip']} - ${dic['treasury.closeTip']}',
      txDisplay: {"hash": Fmt.address(tipData.hash, pad: 16)},
      params: [tipData.hash],
    );
    final res = await Navigator.of(context)
        .pushNamed(TxConfirmPage.route, arguments: args);
    if (res != null) {
      Navigator.of(context).pop(res);
    }
  }

  Future<void> _onTip(BigInt median) async {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov')!;
    final decimals = widget.plugin.networkState.tokenDecimals![0];
    final TreasuryTipData tipData =
        ModalRoute.of(context)!.settings.arguments as TreasuryTipData;
    final args = TxConfirmParams(
      module: 'tips',
      call: 'tip',
      txTitle: '${dic['treasury.tip']} - ${dic['treasury.jet']}',
      txDisplay: {
        "hash": Fmt.address(tipData.hash, pad: 16),
        "median": Fmt.token(median, decimals),
      },
      params: [tipData.hash, median.toString()],
    );
    final res = await Navigator.of(context)
        .pushNamed(TxConfirmPage.route, arguments: args);
    if (res != null) {
      Navigator.of(context).pop(res);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov')!;
    final symbol = widget.plugin.networkState.tokenSymbol![0];
    final decimals = widget.plugin.networkState.tokenDecimals![0];
    final TreasuryTipData tipData =
        ModalRoute.of(context)!.settings.arguments as TreasuryTipData;
    final who = KeyPairData();
    final finder = KeyPairData();
    who.address = tipData.who;
    final Map? accInfo =
        widget.plugin.store.accounts.addressIndexMap[who.address];
    Map? accInfoFinder;
    if (tipData.finder != null) {
      finder.address = tipData.finder;
      accInfoFinder =
          widget.plugin.store.accounts.addressIndexMap[finder.address];
    }
    bool isFinder = false;
    if (widget.keyring.current.address == finder.address) {
      isFinder = true;
    }
    bool isCouncil = false;
    widget.plugin.store.gov.council.members!.forEach((e) {
      if (widget.keyring.current.address == e[0]) {
        isCouncil = true;
      }
    });
    bool isTipped = tipData.tips!.length > 0;
    int blockTime = 6000;
    if (widget.plugin.networkConst['treasury'] != null) {
      blockTime =
          int.parse(widget.plugin.networkConst['babe']['expectedBlockTime']);
    }

    final List<BigInt> values =
        tipData.tips!.map((e) => BigInt.parse(e.value.toString())).toList();
    values.sort();
    final int midIndex = (values.length / 2).floor();
    BigInt median = BigInt.zero;
    if (values.length > 0) {
      median = values.length % 2 > 0
          ? values[midIndex]
          : (values[midIndex - 1] + values[midIndex]) ~/ BigInt.two;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(dic['treasury.tip']!),
        centerTitle: true,
        leading: BackBtn(
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Observer(
          builder: (BuildContext context) {
            final closeBlock = tipData.closes != null
                ? BigInt.parse(tipData.closes.toString())
                : null;
            final bool canClose = closeBlock != null &&
                closeBlock <= widget.plugin.store.gov.bestNumber;
            return ListView(
              children: <Widget>[
                RoundedCard(
                  margin: EdgeInsets.all(16),
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        leading: AddressIcon(
                          who.address,
                          svg: widget.plugin.store.accounts
                              .addressIconsMap[who.address],
                        ),
                        title: UI.accountDisplayName(who.address, accInfo),
                        subtitle: Text(dic['treasury.who']!),
                      ),
                      Visibility(
                          visible: tipData.finder != null,
                          child: ListTile(
                            leading: AddressIcon(
                              finder.address,
                              svg: widget.plugin.store.accounts
                                  .addressIconsMap[finder.address],
                            ),
                            title: UI.accountDisplayName(
                              finder.address,
                              accInfoFinder,
                            ),
                            subtitle: Text(dic['treasury.finder']!),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  '${Fmt.balance(
                                    tipData.deposit.toString(),
                                    decimals,
                                  )} $symbol',
                                  style: Theme.of(context).textTheme.headline4,
                                ),
                                Text(dic['treasury.bond']!),
                              ],
                            ),
                          )),
                      Padding(
                        padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Row(
                          children: <Widget>[
                            Text(dic['treasury.reason']!),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(left: 16),
                                child: TextFormField(
                                  decoration: InputDecoration.collapsed(
                                      hintText: '',
                                      focusColor: Theme.of(context).cardColor),
                                  style: TextStyle(fontSize: 14),
                                  initialValue: tipData.reason,
                                  readOnly: true,
                                  maxLines: 6,
                                  minLines: 1,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Row(
                          children: <Widget>[
                            Text('Hash'),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(left: 16),
                                child: Text(
                                  Fmt.address(tipData.hash, pad: 10)!,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                          visible: closeBlock != null &&
                              closeBlock > widget.plugin.store.gov.bestNumber,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                            child: Row(
                              children: <Widget>[
                                Text(dic['treasury.closeTip']!),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: <Widget>[
                                        Text(
                                          closeBlock != null
                                              ? Fmt.blockToTime(
                                                  (closeBlock -
                                                          widget.plugin.store
                                                              .gov.bestNumber)
                                                      .toInt(),
                                                  blockTime,
                                                )
                                              : "",
                                        ),
                                        Text('#$closeBlock')
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      Container(
                        padding: EdgeInsets.fromLTRB(8, 16, 8, 16),
                        child: Column(
                          children: <Widget>[
                            Divider(height: 24),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: RoundedButton(
                                    color: Colors.orange,
                                    text: I18n.of(context)!.getDic(
                                        i18n_full_dic_kusama,
                                        'common')!['cancel'],
                                    onPressed: isFinder ? _onCancel : null,
                                  ),
                                ),
                                Container(width: 8),
                                Expanded(
                                  child: canClose
                                      ? RoundedButton(
                                          text: dic['treasury.closeTip'],
                                          onPressed:
                                              !isCouncil ? _onCloseTip : null,
                                        )
                                      : RoundedButton(
                                          text: dic['treasury.endorse'],
                                          onPressed:
                                              isCouncil ? _onEndorse : null,
                                        ),
                                ),
                                Visibility(
                                    visible: !canClose,
                                    child: Container(width: 8)),
                                Visibility(
                                    visible: !canClose,
                                    child: RoundedButton(
                                      icon: Icon(
                                        Icons.airplanemode_active,
                                        color: Theme.of(context).cardColor,
                                      ),
                                      onPressed: isCouncil && isTipped
                                          ? () => _onTip(median)
                                          : null,
                                    ))
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Visibility(
                    visible: tipData.tips!.length > 0,
                    child: Container(
                      color: Theme.of(context).cardColor,
                      margin: EdgeInsets.only(top: 8),
                      padding: EdgeInsets.only(top: 8, bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                            child: BorderedTitle(
                                title:
                                    '${tipData.tips!.length} ${dic['treasury.tipper']} (${Fmt.token(median, decimals)} $symbol)'),
                          ),
                          Column(
                            children: tipData.tips!.map((e) {
                              return ListTile(
                                leading: AddressIcon(e.address,
                                    svg: widget.plugin.store.accounts
                                        .addressIconsMap[e.address]),
                                title: UI.accountDisplayName(
                                    e.address,
                                    widget.plugin.store.accounts
                                        .addressIndexMap[e.address]),
                                trailing: Text(
                                  '${Fmt.balance(
                                    e.value.toString(),
                                    decimals,
                                  )} $symbol',
                                  style: Theme.of(context).textTheme.headline4,
                                ),
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                    CandidateDetailPage.route,
                                    arguments: widget
                                        .plugin.store.gov.council.members!
                                        .firstWhere((i) {
                                      return i[0] == e.address;
                                    }),
                                  );
                                },
                              );
                            }).toList(),
                          )
                        ],
                      ),
                    ))
              ],
            );
          },
        ),
      ),
    );
  }
}
