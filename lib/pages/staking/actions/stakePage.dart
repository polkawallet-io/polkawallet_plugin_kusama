import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/bondPage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/nominateForm.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/txButton.dart';
import 'package:polkawallet_ui/components/v3/back.dart';
import 'package:polkawallet_ui/pages/v3/txConfirmPage.dart';

class StakePage extends StatefulWidget {
  StakePage(this.plugin, this.keyring);
  static final String route = '/staking/stake';
  final PluginKusama plugin;
  final Keyring keyring;
  @override
  _StakePageState createState() => _StakePageState();
}

class _StakePageState extends State<StakePage> {
  /// staking action has 2 steps on this page:
  /// 0. staking.bond()
  /// 1. staking.nominate()
  int _step = 0;
  late TxConfirmParams _bondParams;

  Future<void> _onStake(TxConfirmParams nominateParams) async {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'common')!;
    final txBond = 'api.tx.staking.bond(...${jsonEncode(_bondParams.params)})';
    final txNominate =
        'api.tx.staking.nominate(...${jsonEncode(nominateParams.params)})';
    final res = await Navigator.of(context).pushNamed(TxConfirmPage.route,
        arguments: TxConfirmParams(
          txTitle: dic['staking'],
          module: 'utility',
          call: 'batchAll',
          txDisplay: {..._bondParams.txDisplay, ...nominateParams.txDisplay},
          txDisplayBold: {
            ..._bondParams.txDisplayBold,
            ...nominateParams.txDisplayBold
          },
          params: [],
          rawParams: '[[$txBond,$txNominate]]',
        ));
    if (res != null) {
      Navigator.of(context).pop(res);
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      widget.plugin.service.staking.queryElectedInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'common')!;

    return Scaffold(
      appBar: AppBar(
        title: Text('${dic['staking']} ${_step + 1}/2'),
        centerTitle: true,
        leading: BackBtn(
          onBack: () {
            if (_step == 1) {
              setState(() {
                _step = 0;
              });
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: Builder(builder: (BuildContext context) {
        return SafeArea(
          child: _step == 0
              ? BondPage(
                  widget.plugin,
                  widget.keyring,
                  onNext: (TxConfirmParams bondParams) {
                    setState(() {
                      _bondParams = bondParams;
                      _step = 1;
                    });
                  },
                )
              : NominateForm(
                  widget.plugin,
                  widget.keyring,
                  onNext: (TxConfirmParams params) => _onStake(params),
                ),
        );
      }),
    );
  }
}
