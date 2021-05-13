import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/addressFormItem.dart';
import 'package:polkawallet_ui/components/txButton.dart';
import 'package:polkawallet_ui/pages/accountListPage.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/index.dart';

class SubmitTipPage extends StatefulWidget {
  SubmitTipPage(this.plugin, this.keyring);
  final PluginKusama plugin;
  final Keyring keyring;

  static const String route = '/gov/treasury/tip/add';

  @override
  _SubmitTipPageState createState() => _SubmitTipPageState();
}

class _SubmitTipPageState extends State<SubmitTipPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountCtrl = new TextEditingController();
  final TextEditingController _reasonCtrl = new TextEditingController();
  static const MAX_REASON_LEN = 128;
  static const MIN_REASON_LEN = 5;

  KeyPairData _beneficiary;

  Future<TxConfirmParams> _getTxParams() async {
    if (_formKey.currentState.validate()) {
      final dic = I18n.of(context).getDic(i18n_full_dic_kusama, 'gov');
      final int decimals = widget.plugin.networkState.tokenDecimals[0];
      final bool isCouncil = ModalRoute.of(context).settings.arguments;
      final String amt = _amountCtrl.text.trim();
      final String address = _beneficiary.address;
      return TxConfirmParams(
        module: 'tips',
        call: isCouncil ? 'tipNew' : 'reportAwesome',
        txTitle: isCouncil ? dic['treasury.tipNew'] : dic['treasury.report'],
        txDisplay: isCouncil
            ? {
                "beneficiary": address,
                "reason": _reasonCtrl.text.trim(),
                "value": amt,
              }
            : {
                "beneficiary": address,
                "reason": _reasonCtrl.text.trim(),
              },
        params: isCouncil
            ? [
                // "reason"
                _reasonCtrl.text.trim(),
                // "beneficiary"
                address,
                // "value"
                Fmt.tokenInt(amt, decimals).toString(),
              ]
            : [
                // "reason"
                _reasonCtrl.text.trim(),
                // "beneficiary"
                address,
              ],
      );
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _beneficiary = widget.keyring.current;
      });
    });
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).getDic(i18n_full_dic_kusama, 'gov');
    final dicCommon = I18n.of(context).getDic(i18n_full_dic_kusama, 'common');
    final decimals = widget.plugin.networkState.tokenDecimals[0];
    final symbol = widget.plugin.networkState.tokenSymbol[0];
    final bool isCouncil = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
          title: Text(
            dic[isCouncil ? 'treasury.tipNew' : 'treasury.report'],
          ),
          centerTitle: true),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: _beneficiary == null
                  ? Container()
                  : ListView(
                      padding: EdgeInsets.all(16),
                      children: <Widget>[
                        AddressFormItem(
                          _beneficiary,
                          label: dic['treasury.beneficiary'],
                          onTap: () async {
                            final acc = await Navigator.of(context).pushNamed(
                              AccountListPage.route,
                              arguments: AccountListPageParams(
                                  list: widget.keyring.allAccounts),
                            );
                            if (acc != null) {
                              setState(() {
                                _beneficiary = acc;
                              });
                            }
                          },
                        ),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                decoration: InputDecoration(
                                  hintText: dic['treasury.reason'],
                                  labelText: dic['treasury.reason'],
                                ),
                                controller: _reasonCtrl,
                                maxLines: 3,
                                validator: (v) {
                                  final String reason = v.trim();
                                  if (reason.length < MIN_REASON_LEN ||
                                      reason.length > MAX_REASON_LEN) {
                                    return dicCommon['input.invalid'];
                                  }
                                  return null;
                                },
                              ),
                              isCouncil
                                  ? TextFormField(
                                      decoration: InputDecoration(
                                        hintText: dicCommon['amount'],
                                        labelText:
                                            '${dicCommon['amount']} ($symbol)',
                                      ),
                                      inputFormatters: [
                                        UI.decimalInputFormatter(decimals)
                                      ],
                                      controller: _amountCtrl,
                                      keyboardType:
                                          TextInputType.numberWithOptions(
                                              decimal: true),
                                      validator: (v) {
                                        if (v.isEmpty) {
                                          return dicCommon['amount.error'];
                                        }
                                        return null;
                                      },
                                    )
                                  : Container(),
                            ],
                          ),
                        )
                      ],
                    ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: TxButton(
                text: dic['treasury.report'],
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
      ),
    );
  }
}
