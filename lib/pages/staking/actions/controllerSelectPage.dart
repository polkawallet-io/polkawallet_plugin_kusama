import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/v3/addressIcon.dart';
import 'package:polkawallet_ui/components/v3/back.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginScaffold.dart';
import 'package:polkawallet_ui/utils/format.dart';

class ControllerSelectPage extends StatelessWidget {
  ControllerSelectPage(this.plugin, this.keyring);
  final PluginKusama plugin;
  final Keyring keyring;

  static final String route = '/staking/account/list';

  @override
  Widget build(BuildContext context) => Observer(
        builder: (_) {
          final dic =
              I18n.of(context)!.getDic(i18n_full_dic_kusama, 'staking')!;
          return PluginScaffold(
            appBar: PluginAppBar(
                title: Text(dic['controller']!), centerTitle: true),
            body: SafeArea(
              child: Container(
                child: ListView(
                  padding: EdgeInsets.all(16),
                  children: keyring.allAccounts.map((i) {
                    String? unavailable;
                    final stashOf = plugin
                        .store.staking.accountBondedMap[i.pubKey]?.controllerId;
                    String? controllerOf = plugin
                        .store.staking.accountBondedMap[i.pubKey]?.stashId;
                    if (stashOf != null && i.pubKey != keyring.current.pubKey) {
                      unavailable =
                          '${dic['controller.stashOf']} ${Fmt.address(stashOf)}';
                    }
                    if (controllerOf != null &&
                        controllerOf != keyring.current.address) {
                      unavailable =
                          '${dic['controller.controllerOf']} ${Fmt.address(controllerOf)}';
                    }
                    Color grey = Color(0xFFFF7849);
                    return Column(children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(right: 16),
                              child: AddressIcon(i.address, svg: i.icon),
                            ),
                            Expanded(
                              child: unavailable != null
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          i.name!,
                                          style: TextStyle(color: grey),
                                        ),
                                        Text(
                                          Fmt.address(i.address),
                                          style: TextStyle(color: grey),
                                        ),
                                        Text(
                                          unavailable,
                                          style: TextStyle(
                                            color: Colors.orange,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(i.name!,
                                            style:
                                                TextStyle(color: Colors.white)),
                                        Text(Fmt.address(i.address),
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ],
                                    ),
                            ),
                            Visibility(
                                visible: unavailable == null,
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 18,
                                  color: Colors.white,
                                ))
                          ],
                        ),
                        onTap: unavailable == null
                            ? () => Navigator.of(context).pop(i)
                            : null,
                      ),
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Divider(
                            color: Colors.white.withAlpha(36),
                            height: 20,
                          ))
                    ]);
                  }).toList(),
                ),
              ),
            ),
          );
        },
      );
}
