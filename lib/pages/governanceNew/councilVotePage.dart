import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/bondExtraPage.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/plugin/store/balances.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/infoItemRow.dart';
import 'package:polkawallet_ui/components/txButton.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginAddressFormItem.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginInputBalance.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginScaffold.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginTxButton.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/i18n.dart';

class CouncilVotePage extends StatefulWidget {
  CouncilVotePage(this.plugin, this.keyring);
  final PluginKusama plugin;
  final Keyring keyring;

  static final String route = '/gov/vote';
  @override
  _CouncilVote createState() => _CouncilVote();
}

class _CouncilVote extends State<CouncilVotePage> {
  final TextEditingController _amountCtrl = new TextEditingController();

  List<List> _selected = <List>[];
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var res = ModalRoute.of(context)!.settings.arguments as List<dynamic>;
    print(res);
    if (res != null) {
      setState(() {
        _selected = List<List>.from(res);
      });
    }
  }

  Future<TxConfirmParams?> _getTxParams() async {
    if (_error == null && _amountCtrl.text.length > 0) {
      final govDic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov')!;
      final decimals = widget.plugin.networkState.tokenDecimals![0];
      final amt = _amountCtrl.text.trim();
      List selected = _selected.map((i) => i[0]).toList();
      final moduleName = await widget.plugin.service.getRuntimeModuleName(
          ['electionsPhragmen', 'elections', 'phragmenElection']);
      return TxConfirmParams(
          module: moduleName,
          call: 'vote',
          txTitle: govDic['vote.candidate'],
          txDisplay: {
            "votes": selected.map((e) => Fmt.address(e, pad: 8)).join(',\n'),
            I18n.of(context)!.getDic(i18n_full_dic_kusama, 'common')!['amount']:
                '$amt ${widget.plugin.networkState.tokenSymbol![0]}',
          },
          params: [
            // "votes"
            selected,
            // "voteValue"
            Fmt.tokenInt(amt, decimals).toString(),
          ],
          isPlugin: true);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    var govDic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov')!;
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'common')!;
    return PluginScaffold(
      appBar: PluginAppBar(
          title: Text(govDic['vote.candidate']!), centerTitle: true),
      body: Observer(
        builder: (_) {
          final decimals = widget.plugin.networkState.tokenDecimals![0];
          final symbol = widget.plugin.networkState.tokenSymbol![0];
          final balance = Fmt.balanceInt(
              widget.plugin.balances.native!.freeBalance.toString());

          return SafeArea(
            child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: ListView(
                        children: <Widget>[
                          PluginAddressFormItem(
                            account: widget.keyring.current,
                            label: govDic['v3.votingAccount'],
                          ),
                          PluginInputBalance(
                            margin: EdgeInsets.only(top: 10),
                            titleTag: dic['amount'],
                            balance: TokenBalanceData(
                                symbol: symbol,
                                decimals: decimals,
                                amount: balance.toString()),
                            inputCtrl: _amountCtrl,
                            tokenIconsMap: widget.plugin.tokenIcons,
                            onClear: () {
                              setState(() {
                                _amountCtrl.text = "";
                              });
                            },
                            onInputChange: (value) {
                              var error = Fmt.validatePrice(value, context);
                              if (error == null) {
                                final amount = double.parse(value.trim());
                                if (amount >=
                                    balance / BigInt.from(pow(10, decimals)) -
                                        0.001) {
                                  error = dic['amount.low'];
                                }
                              }
                              setState(() {
                                _error = error;
                              });
                            },
                          ),
                          ErrorMessage(
                            _error,
                            margin: EdgeInsets.zero,
                          ),
                          Visibility(
                              visible:
                                  _amountCtrl.text.length > 0 && _error == null,
                              child: Padding(
                                padding: EdgeInsets.only(top: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InfoItemRow(
                                      govDic['v3.votingBond']!,
                                      "${_amountCtrl.text.trim()} $symbol",
                                      labelStyle: Theme.of(context)
                                          .textTheme
                                          .headline5
                                          ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600),
                                      contentStyle: Theme.of(context)
                                          .textTheme
                                          .headline5
                                          ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      govDic['v3.votingMessage']!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline4
                                          ?.copyWith(
                                              color: Colors.white,
                                              fontSize: 12),
                                    )
                                  ],
                                ),
                              ))
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(bottom: 16),
                      child: PluginTxButton(
                        getTxParams: _getTxParams,
                        text: I18n.of(context)!
                            .getDic(i18n_full_dic_ui, 'common')!['tx.submit'],
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
