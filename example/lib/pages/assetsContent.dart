import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_ui/components/borderedTitle.dart';
import 'package:polkawallet_ui/components/roundedCard.dart';
import 'package:polkawallet_sdk/plugin/index.dart';
import 'package:polkawallet_sdk/plugin/store/balances.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_ui/components/textTag.dart';
import 'package:polkawallet_ui/utils/format.dart';

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
        final symbol = widget.network.networkState.tokenSymbol ?? '';
        final decimals = widget.network.networkState.tokenDecimals ?? 12;

        final balancesInfo = widget.network.balances.native;
        final tokens = widget.network.balances.tokens;
        final extraTokens = widget.network.balances.extraTokens;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: ListView(
            padding: EdgeInsets.all(16),
            children: <Widget>[
              RoundedCard(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('address'),
                    Text(widget.keyring.current.address ?? ''),
                    Text(
                        'decimals: ${widget.network.networkState.tokenDecimals}'),
                    Text('symbol: ${widget.network.networkState.tokenSymbol}'),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    BorderedTitle(
                      title: 'Assets',
                    ),
                    widget.network.basic.isTestNet
                        ? TextTag(
                            'TestToken',
                            fontSize: 16,
                            color: Colors.red,
                            margin: EdgeInsets.only(left: 12),
                            padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                          )
                        : Container()
                  ],
                ),
              ),
              RoundedCard(
                margin: EdgeInsets.only(top: 16),
                child: ListTile(
                  leading: Container(
                    alignment: Alignment.centerLeft,
                    width: 45,
                    height: 36,
                    child: widget.network.tokenIcons[symbol],
                  ),
                  title: Text(symbol),
                  trailing: Text(
                    Fmt.priceFloorBigInt(
                        balancesInfo != null
                            ? Fmt.balanceTotal(balancesInfo)
                            : BigInt.zero,
                        decimals,
                        lengthFixed: 3),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black54),
                  ),
                  // onTap: () {
                  //   Navigator.pushNamed(context, AssetPage.route);
                  // },
                ),
              ),
              Column(
                children: tokens == null || tokens.length == 0
                    ? [Container()]
                    : tokens
                        .map((i) => TokenItem(
                              i,
                              decimals,
                              detailPageRoute: i.detailPageRoute,
                              icon: widget.network.tokenIcons[i.symbol],
                            ))
                        .toList(),
              ),
              Column(
                children: extraTokens == null || extraTokens.length == 0
                    ? [Container()]
                    : extraTokens.map((ExtraTokenData i) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 16),
                              child: BorderedTitle(
                                title: i.title,
                              ),
                            ),
                            Column(
                              children: i.tokens
                                  .map((e) => TokenItem(
                                        e,
                                        decimals,
                                        detailPageRoute: e.detailPageRoute,
                                        icon:
                                            widget.network.tokenIcons[e.symbol],
                                      ))
                                  .toList(),
                            )
                          ],
                        );
                      }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TokenItem extends StatelessWidget {
  TokenItem(this.item, this.decimals, {this.detailPageRoute, this.icon});
  final TokenBalanceData item;
  final int decimals;
  final String detailPageRoute;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return RoundedCard(
      margin: EdgeInsets.only(top: 16),
      child: ListTile(
        leading: Container(
          height: 36,
          width: 45,
          alignment: Alignment.centerLeft,
          child: icon ??
              CircleAvatar(
                child: Text(item.symbol.substring(0, 2)),
              ),
        ),
        title: Text(item.name),
        trailing: Text(
          Fmt.priceFloorBigInt(Fmt.balanceInt(item.amount), decimals,
              lengthFixed: 3),
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black54),
        ),
        onTap: detailPageRoute == null
            ? null
            : () {
                Navigator.of(context)
                    .pushNamed(detailPageRoute, arguments: item);
              },
      ),
    );
  }
}
