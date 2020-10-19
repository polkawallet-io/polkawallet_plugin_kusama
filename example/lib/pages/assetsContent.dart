import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_ui/components/roundedCard.dart';
import 'package:polkawallet_sdk/plugin/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';

class AssetsContent extends StatefulWidget {
  AssetsContent(
    this.network,
    this.keyring,
  );
  final PolkawalletPlugin network;
  final Keyring keyring;
  @override
  _AssetsContentState createState() => _AssetsContentState();
}

class _AssetsContentState extends State<AssetsContent> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return ListView(
          padding: EdgeInsets.all(16),
          children: [
            Text('assets content',
                style: Theme.of(context).textTheme.headline4),
            Divider(),
            RoundedCard(
              padding: EdgeInsets.only(top: 40, bottom: 40),
              child: Column(
                children: [
                  Text(
                      'decimals: ${widget.network.networkState.tokenDecimals}'),
                  Text('symbol: ${widget.network.networkState.tokenSymbol}'),
                  Text(
                      'free balance: ${widget.network.balances.native?.freeBalance}'),
                  Text(
                      'available balance: ${widget.network.balances.native?.availableBalance}')
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
