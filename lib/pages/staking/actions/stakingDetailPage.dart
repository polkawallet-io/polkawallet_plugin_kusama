import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/api/types/txData.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/txDetail.dart';
import 'package:polkawallet_ui/utils/format.dart';

class StakingDetailPage extends StatelessWidget {
  StakingDetailPage(this.plugin, this.keyring);
  static final String route = '/staking/tx';
  final PluginKusama plugin;
  final Keyring keyring;

  @override
  Widget build(BuildContext context) {
    final dicStaking = I18n.of(context).getDic(i18n_full_dic_kusama, 'staking');
    final decimals = plugin.networkState.tokenDecimals[0];
    final symbol = plugin.networkState.tokenSymbol[0];
    final TxData detail = ModalRoute.of(context).settings.arguments;
    List<TxDetailInfoItem> info = <TxDetailInfoItem>[
      TxDetailInfoItem(label: dicStaking['action'], content: Text(detail.call)),
    ];
    List params = jsonDecode(detail.params);
    if (params != null) {
      info.addAll(params.map((i) {
        String value = i['value'].toString();
        switch (i['type']) {
          case "Address":
            value = Fmt.address(value);
            break;
          case "Compact<BalanceOf>":
            value = '${Fmt.balance(value, decimals)} $symbol';
            break;
          case "AccountId":
            value = value.contains('0x') ? value : '0x$value';
            final address = plugin.store.accounts
                        .pubKeyAddressMap[plugin.sdk.api.connectedNode.ss58]
                    [value] ??
                value;
            value = Fmt.address(address);
            break;
          case "RewardDestination<AccountId>":
            if (i['value']['Account'] != null) {
              value = 'Account: ${Fmt.address(i['value']['Account'])}';
            } else {
              value = Map.of(i['value']).keys.toList()[0];
            }
            break;
          case "Vec<<Lookup as StaticLookup>::Source>":
            // for nominate targets
            final pubKeys = List.of(i['value']).map((e) {
              if (e is String) {
                return '0x${Fmt.address(e)}';
              }
              return '0x${Fmt.address(e['Id'])}';
            }).toList();
            value = pubKeys.join(',\n');
            break;
        }
        return TxDetailInfoItem(
          label: i['name'],
          content: Text(value),
        );
      }));
    }
    return TxDetail(
      networkName: plugin.basic.name,
      success: detail.success,
      action: detail.call,
      fee: '${Fmt.balance(detail.fee, decimals)} $symbol',
      hash: detail.hash,
      eventId: detail.txNumber,
      infoItems: info,
      blockTime: Fmt.dateTime(
          DateTime.fromMillisecondsSinceEpoch(detail.blockTimestamp * 1000)),
      blockNum: detail.blockNum,
    );
  }
}
