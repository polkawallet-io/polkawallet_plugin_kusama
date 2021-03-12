import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_chainx/polkawallet_plugin_chainx.dart';
import 'package:polkawallet_plugin_chainx/utils/i18n/index.dart';
import 'package:polkawallet_sdk/api/types/gov/referendumInfoData.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/txButton.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/i18n.dart';
import 'package:polkawallet_ui/utils/index.dart';

class ReferendumVotePage extends StatefulWidget {
  ReferendumVotePage(this.plugin, this.keyring);
  final PluginChainX plugin;
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

  Future<TxConfirmParams> _getTxParams() async {
    if (_formKey.currentState.validate()) {
      final govDic = I18n.of(context).getDic(i18n_full_dic_chainx, 'gov');
      final decimals = (widget.plugin.networkState.tokenDecimals ?? [8])[0];
      final Map args = ModalRoute.of(context).settings.arguments;
      final ReferendumInfo info = args['referenda'];
      final bool voteYes = args['voteYes'];
      final amt = _amountCtrl.text.trim();
      final vote = {
        'balance': (double.parse(amt) * pow(10, decimals)).toInt(),
        'vote': {'aye': voteYes, 'conviction': _voteConviction},
      };
      return TxConfirmParams(module: 'democracy', call: 'vote', txTitle: govDic['vote.proposal'], txDisplay: {
        "id": info.index.toInt(),
        "balance": amt,
        "vote": vote['vote'],
      }, params: [
        // "id"
        info.index.toInt(),
        // "options"
        {"Standard": vote},
      ]);
    }
    return null;
  }

  String _getConvictionLabel(int value) {
    final dicGov = I18n.of(context).getDic(i18n_full_dic_chainx, 'gov');
    final Map conviction = value > 0 ? widget.plugin.store.gov.voteConvictions[value - 1] : {};
    return value == 0 ? dicGov['locked.no'] : '${dicGov['locked']} ${conviction['period']} ${dicGov['day']} (${conviction['lock']}x)';
  }

  void _showConvictionSelect() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: MediaQuery.of(context).copyWith().size.height / 3,
        child: CupertinoPicker(
          backgroundColor: Colors.white,
          itemExtent: 58,
          scrollController: FixedExtentScrollController(initialItem: _voteConviction),
          children: _voteConvictionOptions.map((i) {
            return Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  _getConvictionLabel(i),
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
    final dicGov = I18n.of(context).getDic(i18n_full_dic_chainx, 'gov');
    return Scaffold(
      appBar: AppBar(
        title: Text(dicGov['vote.proposal']),
        centerTitle: true,
      ),
      body: Observer(
        builder: (_) {
          final dic = I18n.of(context).getDic(i18n_full_dic_chainx, 'common');
          final decimals = (widget.plugin.networkState.tokenDecimals ?? [8])[0];

          final balance = Fmt.balanceInt(widget.plugin.balances.native.freeBalance.toString());

          Map args = ModalRoute.of(context).settings.arguments;
          ReferendumInfo info = args['referenda'];
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
                            dicGov[voteYes ? 'yes.text' : 'no.text'],
                            style: Theme.of(context).textTheme.headline4,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: dic['amount'],
                              labelText: '${dic['amount']} (${dic['balance']}: ${Fmt.token(balance, decimals)})',
                            ),
                            inputFormatters: [UI.decimalInputFormatter(decimals)],
                            controller: _amountCtrl,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            validator: (v) {
                              if (v.isEmpty) {
                                return dic['amount.error'];
                              }
                              if (double.parse(v.trim()) >= balance / BigInt.from(pow(10, decimals))) {
                                return dic['amount.low'];
                              }
                              return null;
                            },
                          ),
                        ),
                        ListTile(
                          title: Text(dicGov['locked']),
                          subtitle: Text(_getConvictionLabel(_voteConviction)),
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
                    text: I18n.of(context).getDic(i18n_full_dic_ui, 'common')['tx.submit'],
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
