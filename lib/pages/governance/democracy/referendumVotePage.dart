import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/api/types/gov/referendumInfoData.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/txButton.dart';
import 'package:polkawallet_ui/components/v3/back.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/i18n.dart';
import 'package:polkawallet_ui/utils/index.dart';

class ReferendumVotePage extends StatefulWidget {
  ReferendumVotePage(this.plugin, this.keyring);
  final PluginKusama plugin;
  final Keyring keyring;

  static final String route = '/gov/referenda';

  @override
  _ReferendumVoteState createState() => _ReferendumVoteState();
}

class _ReferendumVoteState extends State<ReferendumVotePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _amountCtrl = new TextEditingController();

  final List<int> _voteConvictionOptions = [0, 1, 2, 3, 4, 5, 6];

  int _voteConviction = 0;

  Future<TxConfirmParams?> _getTxParams() async {
    if (_formKey.currentState!.validate()) {
      final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'common')!;
      final govDic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov')!;
      final decimals = widget.plugin.networkState.tokenDecimals![0];
      final Map args =
          ModalRoute.of(context)!.settings.arguments as Map<dynamic, dynamic>;
      final ReferendumInfo info = args['referenda'];
      final bool voteYes = args['voteYes'] ?? false;
      final bool? isLock = args['isLock'];
      final amt = _amountCtrl.text.trim();
      final vote = {
        'balance': (double.parse(amt) * pow(10, decimals)).toInt(),
        'vote': {'aye': voteYes, 'conviction': _voteConviction},
      };
      if (isLock!) {
        final txs = [
          'api.tx.democracy.unlock("${widget.keyring.current.address}")'
        ];
        final standard = {"Standard": vote};
        txs.add(
            'api.tx.democracy.vote(${info.index!.toInt()},${jsonEncode(standard)})');
        return TxConfirmParams(
          txTitle: govDic['vote.proposal'],
          module: 'utility',
          call: 'batch',
          txDisplay: {
            govDic["referenda"]: '#${info.index!.toInt()}',
            govDic["vote"]: voteYes ? govDic['yes'] : govDic['no'],
            dic["amount"]: '$amt ${widget.plugin.networkState.tokenSymbol![0]}',
            '': _getConvictionLabel(_voteConviction),
          },
          params: [],
          rawParams: '[[${txs.join(',')}]]',
        );
      } else {
        return TxConfirmParams(
            module: 'democracy',
            call: 'vote',
            txTitle: govDic['vote.proposal'],
            txDisplay: {
              govDic["referenda"]: '#${info.index!.toInt()}',
              govDic["vote"]: voteYes ? govDic['yes'] : govDic['no'],
              dic["amount"]:
                  '$amt ${widget.plugin.networkState.tokenSymbol![0]}',
              '': _getConvictionLabel(_voteConviction),
            },
            params: [
              // "id"
              info.index!.toInt(),
              // "options"
              {"Standard": vote},
            ]);
      }
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
                  style: TextStyle(fontSize: 16),
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
    final dicGov = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov')!;
    return Scaffold(
      appBar: AppBar(
        title: Text(dicGov['vote.proposal']!),
        centerTitle: true,
        leading: BackBtn(
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
      body: Observer(
        builder: (_) {
          final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'common')!;
          final decimals = widget.plugin.networkState.tokenDecimals![0];

          BigInt available = Fmt.balanceInt(
              widget.plugin.balances.native!.freeBalance.toString());
          widget.plugin.balances.native!.lockedBreakdown!.forEach((e) {
            if (e.use!.contains('democrac')) {
              available -= Fmt.balanceInt(e.amount.toString());
            }
          });

          Map args = ModalRoute.of(context)!.settings.arguments
              as Map<dynamic, dynamic>;
          // ReferendumInfo? info = args['referenda'];
          bool voteYes = args['voteYes'];
          return SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            dicGov[voteYes ? 'yes.text' : 'no.text']!,
                            style: Theme.of(context).textTheme.headline4,
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(left: 16, right: 16, bottom: 16),
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: dic['amount'],
                              labelText:
                                  '${dic['amount']} (${dic['balance']}: ${Fmt.token(available, decimals)})',
                            ),
                            inputFormatters: [
                              UI.decimalInputFormatter(decimals)!
                            ],
                            controller: _amountCtrl,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            validator: (v) {
                              final error = Fmt.validatePrice(v!, context);
                              if (error != null) {
                                return error;
                              }
                              if (double.parse(v.trim()) >=
                                  available / BigInt.from(pow(10, decimals))) {
                                return dic['amount.low'];
                              }
                              return null;
                            },
                          ),
                        ),
                        ListTile(
                          title: Text(dicGov['locked']!),
                          subtitle: Text(_getConvictionLabel(_voteConviction)!),
                          trailing: Icon(Icons.arrow_forward_ios, size: 18),
                          onTap: _showConvictionSelect,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  child: TxButton(
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
            ),
          );
        },
      ),
    );
  }
}
