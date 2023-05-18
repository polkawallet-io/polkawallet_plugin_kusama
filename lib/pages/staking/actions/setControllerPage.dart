import 'package:flutter/cupertino.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/v3/dialog.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginAddressFormItem.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginScaffold.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginTxButton.dart';
import 'package:polkawallet_ui/utils/i18n.dart';

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
  bool _needsController = true;

  Future<void> _showControllerRemoveDialog() async {
    showCupertinoModalPopup(
        context: context,
        builder: (_) {
          final dic = I18n.of(context)!.getDic(i18n_full_dic_ui, 'common')!;
          return PolkawalletAlertDialog(
            content: Text(I18n.of(context)!.getDic(
                i18n_full_dic_kusama, 'staking')!['controller.remove']!),
            actions: <Widget>[
              PolkawalletActionSheetAction(
                isDefaultAction: true,
                child: Text(dic['cancel']!),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              PolkawalletActionSheetAction(
                child: Text(dic['ok']!),
                onPressed: () {
                  setState(() {
                    _controller = widget.keyring.current;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  bool _checkIsStash() {
    return widget.plugin.store.staking.ownStashInfo!.isOwnStash! ||
        (!widget.plugin.store.staking.ownStashInfo!.isOwnStash! &&
            !widget.plugin.store.staking.ownStashInfo!.isOwnController!);
  }

  Future<void> _checkNeedsController() async {
    final res = await widget.plugin.sdk.webView!.evalJavascript(
        'api.tx.staking.setController.meta.args.length',
        wrapPromise: false);
    if (res.toString() != '1') {
      setState(() {
        _needsController = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final KeyPairData? acc =
          ModalRoute.of(context)!.settings.arguments as KeyPairData?;
      setState(() {
        _controller = acc;
      });

      if (_checkIsStash() && acc!.pubKey != widget.keyring.current.pubKey) {
        _showControllerRemoveDialog();
      }

      widget.plugin.service.staking.queryAccountBondedInfo();

      _checkNeedsController();
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

        final isStash = _checkIsStash();
        return SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.all(16),
                  children: <Widget>[
                    PluginAddressFormItem(
                      account: widget.keyring.current,
                      label: isStash ? dic['stash'] : dic['controller'],
                    ),
                    Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: PluginAddressFormItem(
                          account: controller,
                          label: isStash ? dic['controller'] : dic['stash'],
                          svg: widget.plugin.store.accounts
                              .addressIconsMap[controller.address],
                          isDisable: false,
                          onTap: isStash ? _showControllerRemoveDialog : null,
                        )),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: PluginTxButton(
                  getTxParams: () async {
                    if (!isStash) {
                      showCupertinoDialog(
                          context: context,
                          builder: (_) {
                            return PolkawalletAlertDialog(
                              type: DialogType.warn,
                              content: Text(dic['v3.controllerError']!),
                              actions: <Widget>[
                                PolkawalletActionSheetAction(
                                  child: Text(dic['v3.iUnderstand']!),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ],
                            );
                          });
                      return null;
                    }
                    var currentController =
                        ModalRoute.of(context)!.settings.arguments;
                    if (currentController != null &&
                        _controller!.pubKey ==
                            (currentController as KeyPairData).pubKey) {
                      showCupertinoDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return PolkawalletAlertDialog(
                            type: DialogType.warn,
                            title: Container(),
                            content: Text(dic['controller.warn']!),
                            actions: <Widget>[
                              PolkawalletActionSheetAction(
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
                          child: PluginAddressFormItem(
                            account: controller,
                            svg: controller.icon,
                          ),
                        )
                      },
                      params: _needsController
                          ? [
                              // "address"
                              controller.address,
                            ]
                          : [],
                      isPlugin: true,
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
