import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/controllerSelectPage.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/addressFormItem.dart';
import 'package:polkawallet_ui/components/txButton.dart';
import 'package:polkawallet_ui/components/v3/back.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginAddressFormItem.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginScaffold.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginTxButton.dart';

class SetControllerPage extends StatefulWidget {
  SetControllerPage(this.plugin, this.keyring);
  static final String route = '/staking/controller';
  final PluginKusama plugin;
  final Keyring keyring;
  @override
  _SetControllerPageState createState() => _SetControllerPageState();
}

class _SetControllerPageState extends State<SetControllerPage> {
  KeyPairData? _controller;

  Future<void> _changeControllerId(BuildContext context) async {
    var acc = await Navigator.of(context).pushNamed(ControllerSelectPage.route);
    if (acc != null) {
      setState(() {
        _controller = acc as KeyPairData?;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      final KeyPairData? acc =
          ModalRoute.of(context)!.settings.arguments as KeyPairData?;
      setState(() {
        _controller = acc;
      });

      widget.plugin.service.staking.queryAccountBondedInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'staking')!;

    return PluginScaffold(
      appBar: PluginAppBar(
        title: Text(dic['v3.account']!),
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
                    PluginAddressFormItem(
                      account: widget.keyring.current,
                      label: dic['stash'],
                    ),
                    Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: PluginAddressFormItem(
                          account: controller,
                          label: dic['controller'],
                          svg: controller.icon ??
                              widget.plugin.store.accounts
                                  .addressIconsMap[controller.address],
                          onTap: () => _changeControllerId(context),
                        )),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: PluginTxButton(
                  getTxParams: () async {
                    var currentController =
                        ModalRoute.of(context)!.settings.arguments;
                    if (currentController != null &&
                        _controller!.pubKey ==
                            (currentController as KeyPairData).pubKey) {
                      showCupertinoDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CupertinoAlertDialog(
                            title: Container(),
                            content: Text(dic['controller.warn']!),
                            actions: <Widget>[
                              CupertinoButton(
                                child: Text(I18n.of(context)!.getDic(
                                    i18n_full_dic_kusama, 'common')!['ok']!),
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
                      txDisplayBold: {
                        "controller": Container(
                          margin: EdgeInsets.only(right: 16),
                          child: AddressFormItem(
                            controller,
                            svg: controller.icon,
                          ),
                        )
                      },
                      params: [
                        // "address"
                        controller.address,
                      ],
                    );
                  },
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
