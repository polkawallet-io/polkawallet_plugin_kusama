import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_chainx/polkawallet_plugin_chainx.dart';
import 'package:polkawallet_plugin_chainx/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/addressFormItem.dart';
import 'package:polkawallet_ui/components/txButton.dart';
import 'package:polkawallet_ui/pages/accountListPage.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/index.dart';

class SubmitProposalPage extends StatefulWidget {
  SubmitProposalPage(this.plugin, this.keyring);
  final PluginChainX plugin;
  final Keyring keyring;

  static const String route = '/gov/treasury/proposal/add';

  @override
  _SubmitProposalPageState createState() => _SubmitProposalPageState();
}

class _SubmitProposalPageState extends State<SubmitProposalPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountCtrl = new TextEditingController();

  KeyPairData _beneficiary;

  Future<TxConfirmParams> _getTxParams() async {
    if (_formKey.currentState.validate()) {
      final dic = I18n.of(context).getDic(i18n_full_dic_chainx, 'gov');
      final decimals = widget.plugin.networkState.tokenDecimals;
      final amt = _amountCtrl.text.trim();
      return TxConfirmParams(
        module: 'treasury',
        call: 'proposeSpend',
        txTitle: dic['treasury.submit'],
        txDisplay: {
          "value": amt,
          "beneficiary": _beneficiary.address,
        },
        params: [
          // "value"
          Fmt.tokenInt(amt, decimals).toString(),
          // "beneficiary"
          _beneficiary.address,
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
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).getDic(i18n_full_dic_chainx, 'gov');
    final dicCommon = I18n.of(context).getDic(i18n_full_dic_chainx, 'common');
    final decimals = widget.plugin.networkState.tokenDecimals;
    final symbol = widget.plugin.networkState.tokenSymbol;
    final bondPercentage = Fmt.balanceInt(widget.plugin.networkConst['treasury']['proposalBond'].toString()) * BigInt.from(100) ~/ BigInt.from(1000000);
    final minBond = Fmt.balanceInt(widget.plugin.networkConst['treasury']['proposalBondMinimum'].toString());
    final balance = Fmt.balanceInt((widget.plugin.balances.native.availableBalance ? widget.plugin.balances.native.availableBalance : 0).toString());
    return Scaffold(
      appBar: AppBar(title: Text(dic['treasury.submit']), centerTitle: true),
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
                              arguments: AccountListPageParams(list: widget.keyring.allAccounts),
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
                            children: [
                              TextFormField(
                                decoration: InputDecoration(
                                  hintText: dicCommon['amount'],
                                  labelText: '${dicCommon['amount']} ($symbol)',
                                ),
                                inputFormatters: [UI.decimalInputFormatter(decimals)],
                                controller: _amountCtrl,
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                validator: (v) {
                                  if (v.isEmpty) {
                                    return dicCommon['amount.error'];
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: '${dic['treasury.bond']} ($symbol)',
                                ),
                                initialValue: '$bondPercentage%',
                                readOnly: true,
                                style: TextStyle(color: Theme.of(context).disabledColor),
                                validator: (v) {
                                  final BigInt bond = Fmt.tokenInt(_amountCtrl.text.trim(), decimals) * bondPercentage ~/ BigInt.from(100);
                                  if (balance <= bond) {
                                    return dicCommon['amount.low'];
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: '${dic['treasury.bond.min']} ($symbol)',
                                ),
                                initialValue: Fmt.priceCeilBigInt(
                                  minBond,
                                  decimals,
                                  lengthFixed: 3,
                                ),
                                readOnly: true,
                                style: TextStyle(color: Theme.of(context).disabledColor),
                                validator: (v) {
                                  if (balance <= minBond) {
                                    return dicCommon['amount.low'];
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: TxButton(
                text: dic['treasury.submit'],
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
