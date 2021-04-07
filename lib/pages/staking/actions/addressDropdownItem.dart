import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_ui/components/addressIcon.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/index.dart';

class AddressDropdownItem extends StatelessWidget {
  AddressDropdownItem(this.address, this.icon, this.accInfo, {this.label, this.svg, this.onTap});
  final String label;
  final String svg;
  final String address;
  final String icon;
  final Map accInfo;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    Color grey = Theme.of(context).unselectedWidgetColor;

    Column content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          child: Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 8),
                child: AddressIcon(
                  address,
                  svg: svg ?? icon,
                  size: 32,
                  tapToCopy: false,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    UI.accountDisplayName(
                      address,
                      accInfo,
                    ),
                    Text(
                      Fmt.address(address),
                      style: TextStyle(fontSize: 14, color: grey),
                    )
                  ],
                ),
              ),
              onTap == null
                  ? Container()
                  : Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: grey,
                    )
            ],
          ),
        )
      ],
    );

    if (onTap == null) {
      return content;
    }
    return GestureDetector(
      child: content,
      onTap: () => onTap(),
    );
  }
}
