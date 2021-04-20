import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_chainx/pages/staking/actions/addressDropdownItem.dart';
import 'package:polkawallet_plugin_chainx/pages/staking/actions/addressFormItemForValidator.dart';
import 'package:polkawallet_plugin_chainx/pages/staking/actions/customDropdown.dart';
import 'package:polkawallet_plugin_chainx/pages/staking/validators/validator.dart';
import 'package:polkawallet_plugin_chainx/polkawallet_plugin_chainx.dart';
import 'package:polkawallet_plugin_chainx/store/staking/types/validatorData.dart';
import 'package:polkawallet_plugin_chainx/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/addressFormItem.dart';
import 'package:polkawallet_ui/components/roundedButton.dart';
import 'package:polkawallet_ui/components/txButton.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_plugin_chainx/common/components/UI.dart';

class RebondPage extends StatefulWidget {
  RebondPage(this.plugin, this.keyring, this.validatorAccountId, this.switchable, {this.onNext});
  final PluginChainX plugin;
  final Keyring keyring;
  final String validatorAccountId;
  final double switchable;
  final Function(TxConfirmParams) onNext;
  @override
  _RebondPageState createState() => _RebondPageState();
}

class _RebondPageState extends State<RebondPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountCtrl = new TextEditingController();

  ValidatorData validatorTo;

  List<DropdownMenuItem<ValidatorData>> validatorDropdownList;
  List<DropdownMenuItem<ValidatorData>> _buildFavouriteFoodModelDropdown(List validatorList) {
    List<DropdownMenuItem<ValidatorData>> items = List();
    for (ValidatorData validator in validatorList) {
      final accIcon = widget.plugin.store.accounts.addressIconsMap[validator.accountId];
      final accInfo = widget.plugin.store.accounts.addressIndexMap[validator.accountId];
      items.add(DropdownMenuItem(
        value: validator,
        child: AddressDropdownItem(
          validator.accountId,
          accIcon,
          accInfo,
          // do not allow change controller here.
          // onTap: () => _changeControllerId(context),
        ),
      ));
    }
    return items;
  }

  @override
  void initState() {
    validatorDropdownList = _buildFavouriteFoodModelDropdown(widget.plugin.store.staking.validatorsInfo);
    validatorTo = widget.plugin.store.staking.validatorsInfo[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).getDic(i18n_full_dic_chainx, 'common');
    final dicStaking = I18n.of(context).getDic(i18n_full_dic_chainx, 'staking');
    final decimals = (widget.plugin.networkState.tokenDecimals ?? [8])[0];
    final symbol = (widget.plugin.networkState.tokenSymbol ?? ['PCX'])[0];

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
                    label: dicStaking['mystaking.rebond.from'],
                    // do not allow change controller here.
                    // onTap: () => _changeControllerId(context),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(left: 16, right: 16),
                    child: CustomDropdown<ValidatorData>(
                        dropdownMenuItemList: validatorDropdownList,
                        onChanged: (ValidatorData newValue) => {
                              setState(() {
                                validatorTo = newValue;
                              })
                            },
                        value: validatorTo,
                        isEnabled: true,
                        label: dicStaking['mystaking.rebond.to'])),
                Padding(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: dic['amount'],
                      labelText: '${dic['amount']} (${dicStaking['switchable']}: ${Fmt.priceFloor(
                        widget.switchable,
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
                      if (double.parse(v.trim()) >= widget.switchable) {
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
            text: dicStaking['mystaking.action.rebond'],
            onPressed: () {
              if (_formKey.currentState.validate()) {
                final inputAmount = _amountCtrl.text.trim();
                // String controllerId = widget.keyring.current.address;
                // if (_controller != null) {
                //   controllerId = _controller.address;
                // }
                widget.onNext(TxConfirmParams(
                  txTitle: dicStaking['mystaking.action.rebond'],
                  module: 'xStaking',
                  call: 'rebond',
                  txDisplay: {
                    "from": widget.validatorAccountId,
                    "to": validatorTo.accountId,
                    "value": '$inputAmount $symbol',
                  },
                  params: [
                    // "from":
                    widget.validatorAccountId,
                    // "to":
                    validatorTo.accountId,
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
