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

class SetControllerPage extends StatefulWidget {
  SetControllerPage(this.plugin, this.keyring);
  static final String route = '/staking/controller';
  final PluginKusama plugin;
  final Keyring keyring;
  @override
  _SetControllerPageState createState() => _SetControllerPageState();
}

class _SetControllerPageState extends State<SetControllerPage> {
  KeyPairData _controller;

  Future<void> _changeControllerId(BuildContext context) async {
    final accounts = widget.keyring.keyPairs.toList();
    accounts.addAll(widget.keyring.externals);
    var acc = await Navigator.of(context).pushNamed(
      AccountListPage.route,
      arguments: AccountListPageParams(list: accounts),
    );
    if (acc != null) {
      setState(() {
        _controller = acc;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller == null) {
      var acc = ModalRoute.of(context).settings.arguments;
      setState(() {
        _controller = acc;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).getDic(i18n_full_dic_kusama, 'staking');

    return Scaffold(
      appBar: AppBar(
        title: Text(dic['action.control']),
        centerTitle: true,
      ),
      body: Builder(builder: (BuildContext context) {
        final controller = _controller ?? widget.keyring.current;
        return SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(16),
                  children: <Widget>[
                    AddressFormItem(
                      widget.keyring.current,
                      label: dic['stash'],
                    ),
                    AddressFormItem(
                      controller,
                      label: dic['controller'],
                      svg: controller.icon ??
                          widget.plugin.store.accounts
                              .addressIconsMap[controller.address],
                      onTap: () => _changeControllerId(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: TxButton(
                  getTxParams: () {
                    var currentController =
                        ModalRoute.of(context).settings.arguments;
                    if (currentController != null &&
                        _controller.pubKey ==
                            (currentController as KeyPairData).pubKey) {
                      showCupertinoDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CupertinoAlertDialog(
                            title: Container(),
                            content: Text(dic['controller.warn']),
                            actions: <Widget>[
                              CupertinoButton(
                                child: Text(I18n.of(context).getDic(
                                    i18n_full_dic_kusama, 'common')['ok']),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          );
                        },
                      );
                      return null;
                    }

                    return TxConfirmParams(
                      txTitle: dic['action.control'],
                      module: 'staking',
                      call: 'setController',
                      txDisplay: {"controllerId": controller.address},
                      params: [
                        // "address"
                        controller.address,
                      ],
                    );
                  },
                  onFinish: (bool success) {
                    if (success != null && success) {
                      Navigator.of(context).pop(success);
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
