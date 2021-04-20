import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_chainx/pages/staking/actions/addressFormItemForValidator.dart';
import 'package:polkawallet_plugin_chainx/pages/staking/actions/customDropdown.dart';
import 'package:polkawallet_plugin_chainx/polkawallet_plugin_chainx.dart';
import 'package:polkawallet_plugin_chainx/store/staking/types/nominationData.dart';
import 'package:polkawallet_plugin_chainx/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/addressFormItem.dart';
import 'package:polkawallet_ui/components/roundedButton.dart';
import 'package:polkawallet_ui/components/txButton.dart';

class UnfreezePage extends StatefulWidget {
  UnfreezePage(this.plugin, this.keyring, this.validatorAccountId, this.unbondedChunks, {this.onNext});
  final PluginChainX plugin;
  final Keyring keyring;
  final String validatorAccountId;
  final List<BondedChunksData> unbondedChunks;
  final Function(TxConfirmParams) onNext;
  @override
  _UnfreezePageState createState() => _UnfreezePageState();
}

class _UnfreezePageState extends State<UnfreezePage> {
  final _formKey = GlobalKey<FormState>();

  int chunkIndex;
  BondedChunksData chunkData;

  List<DropdownMenuItem<BondedChunksData>> chunksDropdownList;
  List<DropdownMenuItem<BondedChunksData>> _buildChunksDropdown(List chunksList) {
    List<DropdownMenuItem<BondedChunksData>> items = List();
    for (BondedChunksData chunk in chunksList) {
      items.add(DropdownMenuItem(
        value: chunk,
        child: Text('locked until: ${chunk.lockedUntil}'),
      ));
    }
    return items;
  }

  @override
  void initState() {
    chunksDropdownList = _buildChunksDropdown(widget.unbondedChunks);
    chunkIndex = 0;
    chunkData = widget.unbondedChunks.length > 0 ? widget.unbondedChunks[0] : null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dicStaking = I18n.of(context).getDic(i18n_full_dic_chainx, 'staking');
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
                    label: dicStaking['mystaking.unfreeze.node'],
                    // do not allow change controller here.
                    // onTap: () => _changeControllerId(context),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(left: 16, right: 16),
                    child: CustomDropdown<BondedChunksData>(
                        dropdownMenuItemList: chunksDropdownList,
                        onChanged: (BondedChunksData newValue) => {
                              setState(() {
                                chunkIndex = widget.unbondedChunks.indexOf(newValue);
                                chunkData = newValue;
                              })
                            },
                        value: chunkData,
                        isEnabled: true,
                        label: dicStaking['mystaking.unfreeze.id'])),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(16),
          child: RoundedButton(
            text: dicStaking['mystaking.action.unfreeze'],
            onPressed: () {
              if (_formKey.currentState.validate()) {
                widget.onNext(TxConfirmParams(
                  txTitle: dicStaking['mystaking.action.unfreeze'],
                  module: 'xStaking',
                  call: 'unlockUnbondedWithdrawal',
                  txDisplay: {
                    "target": widget.validatorAccountId,
                    "unbonded_index": chunkIndex,
                  },
                  params: [
                    // "target":
                    widget.validatorAccountId,
                    // "unbonded_index":
                    chunkIndex,
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
