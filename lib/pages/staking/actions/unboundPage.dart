import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_chainx/pages/staking/actions/addressFormItemForValidator.dart';
import 'package:polkawallet_plugin_chainx/polkawallet_plugin_chainx.dart';
import 'package:polkawallet_plugin_chainx/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/addressFormItem.dart';
import 'package:polkawallet_ui/components/roundedButton.dart';
import 'package:polkawallet_ui/components/txButton.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/index.dart';

class UnboundPage extends StatefulWidget {
  UnboundPage(this.plugin, this.keyring, this.validatorAccountId, this.recovable, {this.onNext});
  final PluginChainX plugin;
  final Keyring keyring;
  final String validatorAccountId;
  final double recovable;
  final Function(TxConfirmParams) onNext;
  @override
  _UnboundPageState createState() => _UnboundPageState();
}

class _UnboundPageState extends State<UnboundPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountCtrl = new TextEditingController();

  int _rewardTo = 0;

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).getDic(i18n_full_dic_chainx, 'common');
    final dicStaking = I18n.of(context).getDic(i18n_full_dic_chainx, 'staking');
    final decimals = (widget.plugin.networkState.tokenDecimals ?? [8])[0];
    final symbol = (widget.plugin.networkState.tokenSymbol ?? ['PCX'])[0];

    List<KeyPairData> accounts;
    if (_rewardTo == 3) {
      accounts = widget.keyring.keyPairs;
      accounts.addAll(widget.keyring.externals);
    }

    final accIcon = widget.plugin.store.accounts.addressIconsMap[widget.validatorAccountId];
    final accInfo = widget.plugin.store.accounts.addressIndexMap[widget.validatorAccountId];

    return Column(
      children: <Widget>[
        Expanded(
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: AddressFormItem(
                    widget.keyring.current,
                    label: dicStaking['mystaking.action.vote.myaccount'],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: AddressFormItemForValidator(
                    widget.validatorAccountId,
                    accIcon,
                    accInfo,
                    label: dicStaking['mystaking.action.unbound.validator'],
                    // do not allow change controller here.
                    // onTap: () => _changeControllerId(context),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: dic['amount'],
                      labelText: '${dic['amount']} (${dicStaking['recovable']}: ${Fmt.priceFloor(
                        widget.recovable,
                        lengthMax: 4,
                      )} $symbol)',
                    ),
                    inputFormatters: [UI.decimalInputFormatter(decimals)],
                    controller: _amountCtrl,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v.isEmpty) {
                        return dic['amount.error'];
                      }
                      if (double.parse(v.trim()) >= widget.recovable) {
                        return dic['amount.error'];
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(16),
          child: RoundedButton(
            text: dicStaking['mystaking.action.unbound'],
            onPressed: () {
              if (_formKey.currentState.validate()) {
                final inputAmount = _amountCtrl.text.trim();
                // String controllerId = widget.keyring.current.address;
                // if (_controller != null) {
                //   controllerId = _controller.address;
                // }
                widget.onNext(TxConfirmParams(
                  txTitle: dicStaking['mystaking.action.unbound'],
                  module: 'xStaking',
                  call: 'unbond',
                  txDisplay: {
                    "target": widget.validatorAccountId,
                    "value": '$inputAmount $symbol',
                  },
                  params: [
                    // "controllerId":
                    widget.validatorAccountId,
                    // "amount"
                    Fmt.tokenInt(inputAmount, decimals).toString(),
                  ],
                ));
              }
            },
          ),
        ),
      ],
    );
  }
}
