import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_sdk/api/types/networkStateData.dart';
import 'package:polkawallet_sdk/plugin/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';

class AssetsContent extends StatefulWidget {
  AssetsContent(
    this.network,
    this.keyring,
    this.networkState,
  );
  final PolkawalletPlugin network;
  final Keyring keyring;
  final NetworkStateData networkState;
  @override
  _AssetsContentState createState() => _AssetsContentState();
}

class _AssetsContentState extends State<AssetsContent> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Text('assets content', style: Theme.of(context).textTheme.headline4),
        Divider(),
        Text('decimals: ${widget.networkState.tokenDecimals}'),
        Text('symbol: ${widget.networkState.tokenSymbol}'),
        Text('free balance: ${widget.network.balances.native.freeBalance}'),
        Text(
            'available balance: ${widget.network.balances.native.availableBalance}'),
      ],
    );
  }
}
