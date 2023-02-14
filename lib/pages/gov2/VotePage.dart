import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/api/types/gov/referendumV2Data.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginScaffold.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginTagCard.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginTxButton.dart';
import 'package:polkawallet_ui/components/v3/plugin/roundedPluginCard.dart';
import 'package:polkawallet_ui/utils/consts.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/i18n.dart';
import 'package:polkawallet_ui/utils/index.dart';

class VotePage extends StatefulWidget {
  VotePage(this.plugin, this.keyring);
  final PluginKusama plugin;
  final Keyring keyring;

  static final String route = '/gov2/vote';

  @override
  _ReferendumVoteState createState() => _ReferendumVoteState();
}

class _ReferendumVoteState extends State<VotePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _amountAbsCtrl = new TextEditingController();
  final TextEditingController _amountAyeCtrl = new TextEditingController();
  final TextEditingController _amountNayCtrl = new TextEditingController();

  final List<int> _voteConvictionOptions = [0, 1, 2, 3, 4, 5, 6];
  int _voteConviction = 0;

  int _tab = 0;

  Future<TxConfirmParams?> _getTxParams() async {
    if (_formKey.currentState!.validate()) {
      final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'common')!;
      final govDic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov')!;
      final symbol = widget.plugin.networkState.tokenSymbol![0];
      final decimals = widget.plugin.networkState.tokenDecimals![0];
      final voteName = ['Aye', 'Nay', 'Split', 'Abstain'][_tab];
      final Map args =
          ModalRoute.of(context)!.settings.arguments as Map<dynamic, dynamic>;
      final ReferendumItem info = args['referenda'];
      final amtAye = _amountAyeCtrl.text.trim();
      final amtNay = _amountNayCtrl.text.trim();
      final amtAbs = _amountAbsCtrl.text.trim();
      final votes = _tab == 3
          ? {
              "SplitAbstain": [
                Fmt.tokenInt(amtAye, decimals).toString(),
                Fmt.tokenInt(amtNay, decimals).toString(),
                Fmt.tokenInt(amtAbs, decimals).toString()
              ]
            }
          : _tab == 2
              ? {
                  "Split": [
                    Fmt.tokenInt(amtAye, decimals).toString(),
                    Fmt.tokenInt(amtNay, decimals).toString()
                  ]
                }
              : {
                  "Standard": {
                    'vote': {'aye': _tab == 0, 'conviction': _voteConviction},
                    'balance':
                        Fmt.tokenInt(_tab == 0 ? amtAye : amtNay, decimals)
                            .toString()
                  }
                };
      return TxConfirmParams(
          module: 'convictionVoting',
          call: 'vote',
          txTitle: govDic['vote.proposal'],
          txDisplay: {
            govDic["referenda"]: '#${info.key}',
            govDic["vote"]: voteName,
            dic["amount"]: _tab == 0
                ? '$amtAye $symbol'
                : _tab == 1
                    ? '$amtNay $symbol'
                    : _tab == 2
                        ? 'Aye: $amtAye $symbol\nNay: $amtNay $symbol'
                        : 'Aye: $amtAye $symbol\nNay: $amtNay $symbol\nAbstain: $amtAbs $symbol',
            '': _tab == 0 || _tab == 1
                ? _getConvictionLabel(_voteConviction)
                : '',
          },
          params: [
            // "id"
            info.key,
            // "options"
            votes,
          ],
          isPlugin: true);
    }
    return null;
  }

  String? _getConvictionLabel(int value) {
    final dicGov = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov');
    final Map? conviction =
        value > 0 ? widget.plugin.store.gov.voteConvictions![value - 1] : {};
    return value == 0
        ? dicGov!['locked.no']
        : '${dicGov!['locked']} ${conviction!['period']} ${dicGov['day']} (${conviction['value']}x)';
  }

  void _showConvictionSelect() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: MediaQuery.of(context).copyWith().size.height / 3,
        child: CupertinoPicker(
          backgroundColor: Colors.white,
          itemExtent: 58,
          scrollController:
              FixedExtentScrollController(initialItem: _voteConviction),
          children: _voteConvictionOptions.map((i) {
            return Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  _getConvictionLabel(i)!,
                  style: TextStyle(
                      fontSize: UI.getTextSize(16, context),
                      color: Colors.black),
                ));
          }).toList(),
          onSelectedItemChanged: (v) {
            setState(() {
              _voteConviction = v;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'common')!;
    final dicGov = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov')!;
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final referendum = args['referenda'] as ReferendumItem;

    final tabTextStyle = Theme.of(context)
        .textTheme
        .labelMedium
        ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold);
    return PluginScaffold(
      appBar: PluginAppBar(title: Text(dicGov['vote']!), centerTitle: true),
      body: Observer(
        builder: (_) {
          final decimals = widget.plugin.networkState.tokenDecimals![0];

          BigInt available = Fmt.balanceInt(
              widget.plugin.balances.native!.freeBalance.toString());
          widget.plugin.balances.native!.lockedBreakdown!.forEach((e) {
            if (e.use!.contains('democrac')) {
              available -= Fmt.balanceInt(e.amount.toString());
            }
          });

          return SafeArea(
            child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          physics: BouncingScrollPhysics(),
                          children: <Widget>[
                            RoundedPluginCard(
                              margin: EdgeInsets.only(bottom: 16),
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Vote for referenda #${referendum.key}',
                                    style: tabTextStyle,
                                  ),
                                  Text(
                                    referendum.callDocs == null
                                        ? Fmt.address(referendum.proposalHash,
                                            pad: 12)
                                        : '${referendum.callMethod}\n${referendum.callDocs}',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                            PluginTagCard(
                              margin: EdgeInsets.zero,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              titleTag: dicGov['v3.voting'],
                              child: Container(
                                alignment: Alignment.center,
                                child: CupertinoSegmentedControl<int>(
                                  borderColor: PluginColorsDark.primary,
                                  selectedColor: PluginColorsDark.primary,
                                  unselectedColor: PluginColorsDark.cardColor,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  groupValue: _tab,
                                  onValueChanged: (int value) {
                                    setState(() {
                                      _tab = value;
                                      _voteConviction = 0;
                                    });
                                  },
                                  children: <int, Widget>{
                                    0: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      child: Text('Aye', style: tabTextStyle),
                                    ),
                                    1: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      child: Text('Nay', style: tabTextStyle),
                                    ),
                                    2: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      child: Text('Split', style: tabTextStyle),
                                    ),
                                    3: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      child:
                                          Text('Abstain', style: tabTextStyle),
                                    ),
                                  },
                                ),
                              ),
                            ),
                            Visibility(
                              visible: _tab == 3,
                              child: PluginTagCard(
                                margin: EdgeInsets.only(top: 16),
                                titleTag: 'Abstain ${dicGov['v3.voteVaule']}',
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                child: TextFormField(
                                  cursorColor: PluginColorsDark.primary,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline3
                                      ?.copyWith(
                                          color: Colors.white,
                                          fontSize:
                                              UI.getTextSize(20, context)),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    border: InputBorder.none,
                                    hintText:
                                        '${dic['amount']} (${dic['balance']}: ${Fmt.token(available, decimals)})',
                                    hintStyle: Theme.of(context)
                                        .textTheme
                                        .headline5
                                        ?.copyWith(
                                            color: Color(0xffbcbcbc),
                                            fontWeight: FontWeight.w300),
                                    suffix: GestureDetector(
                                      child: Icon(
                                        CupertinoIcons.clear_thick_circled,
                                        color: Color(0xFFD8D8D8),
                                        size: 18,
                                      ),
                                      onTap: () {
                                        setState(() {
                                          _amountAbsCtrl.text = '';
                                        });
                                      },
                                    ),
                                  ),
                                  inputFormatters: [
                                    UI.decimalInputFormatter(decimals)!
                                  ],
                                  controller: _amountAbsCtrl,
                                  keyboardType: TextInputType.numberWithOptions(
                                      decimal: true),
                                  validator: (v) {
                                    final error =
                                        Fmt.validatePrice(v!, context);
                                    if (error != null) {
                                      return error;
                                    }
                                    if (double.parse(v.trim()) >=
                                        available /
                                            BigInt.from(pow(10, decimals))) {
                                      return dic['amount.low'];
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            Visibility(
                              visible: _tab != 1,
                              child: PluginTagCard(
                                margin: EdgeInsets.only(top: 16),
                                titleTag: 'Aye ${dicGov['v3.voteVaule']}',
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                child: TextFormField(
                                  cursorColor: PluginColorsDark.primary,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline3
                                      ?.copyWith(
                                          color: Colors.white,
                                          fontSize:
                                              UI.getTextSize(20, context)),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    border: InputBorder.none,
                                    hintText:
                                        '${dic['amount']} (${dic['balance']}: ${Fmt.token(available, decimals)})',
                                    hintStyle: Theme.of(context)
                                        .textTheme
                                        .headline5
                                        ?.copyWith(
                                            color: Color(0xffbcbcbc),
                                            fontWeight: FontWeight.w300),
                                    suffix: GestureDetector(
                                      child: Icon(
                                        CupertinoIcons.clear_thick_circled,
                                        color: Color(0xFFD8D8D8),
                                        size: 18,
                                      ),
                                      onTap: () {
                                        setState(() {
                                          _amountAyeCtrl.text = '';
                                        });
                                      },
                                    ),
                                  ),
                                  inputFormatters: [
                                    UI.decimalInputFormatter(decimals)!
                                  ],
                                  controller: _amountAyeCtrl,
                                  keyboardType: TextInputType.numberWithOptions(
                                      decimal: true),
                                  validator: (v) {
                                    final error =
                                        Fmt.validatePrice(v!, context);
                                    if (error != null) {
                                      return error;
                                    }
                                    if (double.parse(v.trim()) >=
                                        available /
                                            BigInt.from(pow(10, decimals))) {
                                      return dic['amount.low'];
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            Visibility(
                              visible: _tab != 0,
                              child: PluginTagCard(
                                margin: EdgeInsets.only(top: 16),
                                titleTag: 'Nay ${dicGov['v3.voteVaule']}',
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                child: TextFormField(
                                  cursorColor: PluginColorsDark.primary,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline3
                                      ?.copyWith(
                                          color: Colors.white,
                                          fontSize:
                                              UI.getTextSize(20, context)),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    border: InputBorder.none,
                                    hintText:
                                        '${dic['amount']} (${dic['balance']}: ${Fmt.token(available, decimals)})',
                                    hintStyle: Theme.of(context)
                                        .textTheme
                                        .headline5
                                        ?.copyWith(
                                            color: Color(0xffbcbcbc),
                                            fontWeight: FontWeight.w300),
                                    suffix: GestureDetector(
                                      child: Icon(
                                        CupertinoIcons.clear_thick_circled,
                                        color: Color(0xFFD8D8D8),
                                        size: 18,
                                      ),
                                      onTap: () {
                                        setState(() {
                                          _amountNayCtrl.text = '';
                                        });
                                      },
                                    ),
                                  ),
                                  inputFormatters: [
                                    UI.decimalInputFormatter(decimals)!
                                  ],
                                  controller: _amountNayCtrl,
                                  keyboardType: TextInputType.numberWithOptions(
                                      decimal: true),
                                  validator: (v) {
                                    final error =
                                        Fmt.validatePrice(v!, context);
                                    if (error != null) {
                                      return error;
                                    }
                                    if (double.parse(v.trim()) >=
                                        available /
                                            BigInt.from(pow(10, decimals))) {
                                      return dic['amount.low'];
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            Visibility(
                              visible: _tab == 0 || _tab == 1,
                              child: PluginTagCard(
                                margin: EdgeInsets.only(top: 16),
                                padding: EdgeInsets.all(12),
                                titleTag: dicGov['locked'],
                                child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: _showConvictionSelect,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _getConvictionLabel(
                                                _voteConviction)!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline5
                                                ?.copyWith(color: Colors.white),
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            size: 18,
                                            color: Colors.white,
                                          )
                                        ])),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(bottom: 16),
                      child: PluginTxButton(
                        text: I18n.of(context)!
                            .getDic(i18n_full_dic_ui, 'common')!['tx.submit'],
                        getTxParams: _getTxParams,
                        onFinish: (res) {
                          if (res != null) {
                            Navigator.of(context).pop(res);
                          }
                        },
                      ),
                    )
                  ],
                )),
          );
        },
      ),
    );
  }
}
