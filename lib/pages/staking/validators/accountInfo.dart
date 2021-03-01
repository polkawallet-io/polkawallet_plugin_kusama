import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_ui/components/addressIcon.dart';
import 'package:polkawallet_ui/components/jumpToBrowserLink.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/index.dart';

class AccountInfo extends StatelessWidget {
  AccountInfo({this.accInfo, this.address, this.icon, this.network});
  final Map accInfo;
  final String address;
  final String icon;
  final String network;
  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];
    if (accInfo != null) {
      List<Widget> ls = [];
      accInfo['identity'].keys.forEach((k) {
        if (k != 'judgements' && k != 'other') {
          String content = accInfo['identity'][k].toString();
          if (k == 'parent') {
            content = Fmt.address(content);
          }
          ls.add(Row(
            children: <Widget>[
              Container(
                width: 80,
                child: Text(k),
              ),
              Text(content),
            ],
          ));
        }
      });

      if (ls.length > 0) {
        list.add(Divider());
        list.add(Container(height: 4));
        list.addAll(ls);
      }
    }

    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 16, bottom: 8),
          child: AddressIcon(address, svg: icon),
        ),
        accInfo != null ? Text(accInfo['accountIndex'] ?? '') : Container(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [UI.accountDisplayName(address, accInfo, expand: false)],
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 16, top: 8),
          child: Text(Fmt.address(address)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: JumpToBrowserLink(
                'https://polkascan.io/$network/account/$address',
                text: 'Polkascan',
              ),
            ),
            JumpToBrowserLink(
              'https://$network.subscan.io/account/$address',
              text: 'Subscan',
            ),
          ],
        ),
        accInfo == null
            ? Container()
            : Container(
                padding: EdgeInsets.only(left: 24, right: 24, bottom: 4),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: list),
              )
      ],
    );
  }
}
