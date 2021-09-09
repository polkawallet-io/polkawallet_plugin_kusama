import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/addressFormItem.dart';
import 'package:polkawallet_ui/components/txButton.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/index.dart';

class BondExtraPage extends StatefulWidget {
  BondExtraPage(this.plugin, this.keyring);
  static final String route = '/staking/bondExtra';
  final PluginKusama plugin;
  final Keyring keyring;
  @override
  _BondExtraPageState createState() => _BondExtraPageState();
}

class _BondExtraPageState extends State<BondExtraPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _amountCtrl = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'common');
    final dicStaking = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'staking')!;
    final symbol = widget.plugin.networkState.tokenSymbol![0];
    final decimals = widget.plugin.networkState.tokenDecimals![0];

    BigInt available = BigInt.zero;
    if (widget.plugin.balances.native != null) {
      available =
          Fmt.balanceInt(widget.plugin.balances.native!.freeBalance.toString());
      widget.plugin.balances.native!.lockedBreakdown!.forEach((e) {
        print(e.use);
        if (e.use!.contains('staking')) {
          available -= Fmt.balanceInt(e.amount.toString());
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(dicStaking['action.bondExtra']!),
        centerTitle: true,
      ),
      body: Builder(builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: EdgeInsets.all(16),
                    children: <Widget>[
                      AddressFormItem(
                        widget.keyring.current,
                        label: dicStaking['stash'],
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: dic!['amount'],
                          labelText:
                              '${dic['amount']} (${dicStaking['available']}: ${Fmt.priceFloorBigInt(
                            available,
                            decimals,
                            lengthMax: 4,
                          )} $symbol)',
                        ),
                        inputFormatters: [UI.decimalInputFormatter(decimals)!],
                        controller: _amountCtrl,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        validator: (v) {
                          if (v!.isEmpty) {
                            return dic['amount.error'];
                          }
                          if (double.parse(v.trim()) >=
                              Fmt.bigIntToDouble(available, decimals)) {
                            return dic['amount.low'];
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: TxButton(
                  getTxParams: () async {
                    if (_formKey.currentState!.validate()) {
                      final inputAmount = _amountCtrl.text.trim();
                      return TxConfirmParams(
                        txTitle: dicStaking['action.bondExtra'],
                        module: 'staking',
                        call: 'bondExtra',
                        txDisplay: {"amount": '$inputAmount $symbol'},
                        params: [
                          // "amount"
                          Fmt.tokenInt(inputAmount, decimals).toString(),
                        ],
                      );
                    }
                    return null;
                  } as Future<TxConfirmParams> Function()?,
                  onFinish: (Map? res) {
                    if (res != null) {
                      Navigator.of(context).pop(res);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
