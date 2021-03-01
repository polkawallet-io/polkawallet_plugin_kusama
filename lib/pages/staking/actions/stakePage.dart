import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_chainx/pages/staking/actions/votePage.dart';
import 'package:polkawallet_plugin_chainx/polkawallet_plugin_chainx.dart';
import 'package:polkawallet_plugin_chainx/store/staking/types/validatorData.dart';
import 'package:polkawallet_plugin_chainx/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/txButton.dart';
import 'package:polkawallet_ui/pages/txConfirmPage.dart';

class StakePage extends StatefulWidget {
  StakePage(this.plugin, this.keyring);
  static final String route = '/staking/vote';
  final PluginChainX plugin;
  final Keyring keyring;
  @override
  _StakePageState createState() => _StakePageState();
}

class _StakePageState extends State<StakePage> {
  TxConfirmParams _bondParams;

  Future<void> _onStake(TxConfirmParams nominateParams) async {
    final dic = I18n.of(context).getDic(i18n_full_dic_chainx, 'common');
    final txBond = 'api.tx.staking.bond(...${jsonEncode(_bondParams.params)})';
    final txNominate = 'api.tx.staking.nominate(...${jsonEncode(nominateParams.params)})';
    final res = await Navigator.of(context).pushNamed(TxConfirmPage.route,
        arguments: TxConfirmParams(
          txTitle: dic['staking'],
          module: 'utility',
          call: 'batchAll',
          txDisplay: {
            "actions": [
              {'call': '${_bondParams.module}.${_bondParams.call}', ..._bondParams.txDisplay},
              {'call': '${nominateParams.module}.${nominateParams.call}', ...nominateParams.txDisplay}
            ],
          },
          params: [],
          rawParams: '[[$txBond,$txNominate]]',
        ));
    if (res != null) {
      Navigator.of(context).pop(res);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).getDic(i18n_full_dic_chainx, 'staking');
    final ValidatorData detail = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text(dic['mystaking.action.vote.label']),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Builder(builder: (BuildContext context) {
        return SafeArea(
            child: VotePage(
          widget.plugin,
          widget.keyring,
          detail.accountId,
          onNext: (TxConfirmParams params) => _onStake(params),
        ));
      }),
    );
  }
}
