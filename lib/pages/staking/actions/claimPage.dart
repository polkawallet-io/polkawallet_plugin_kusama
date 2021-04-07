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

class ClaimPage extends StatefulWidget {
  ClaimPage(this.plugin, this.keyring, this.validatorAccountId, {this.onNext});
  final PluginChainX plugin;
  final Keyring keyring;
  final String validatorAccountId;
  final Function(TxConfirmParams) onNext;
  @override
  _ClaimPageState createState() => _ClaimPageState();
}

class _ClaimPageState extends State<ClaimPage> {
  final _formKey = GlobalKey<FormState>();

  int _rewardTo = 0;

  @override
  Widget build(BuildContext context) {
    final dicStaking = I18n.of(context).getDic(i18n_full_dic_chainx, 'staking');

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
                    label: dicStaking['mystaking.claim.validator'],
                    // do not allow change controller here.
                    // onTap: () => _changeControllerId(context),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(16),
          child: RoundedButton(
            text: dicStaking['mystaking.action.claim'],
            onPressed: () {
              if (_formKey.currentState.validate()) {
                widget.onNext(TxConfirmParams(
                  txTitle: dicStaking['mystaking.action.claim'],
                  module: 'xStaking',
                  call: 'claim',
                  txDisplay: {
                    "target": widget.validatorAccountId,
                  },
                  params: [
                    // "controllerId":
                    widget.validatorAccountId,
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
