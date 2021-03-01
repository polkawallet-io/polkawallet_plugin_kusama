import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_ui/components/addressIcon.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/index.dart';

class AddressFormItemForValidator extends StatelessWidget {
  AddressFormItemForValidator(this.address, this.icon, {this.label, this.svg, this.onTap});
  final String label;
  final String svg;
  final String address;
  final String icon;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    Color grey = Theme.of(context).unselectedWidgetColor;

    Column content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        label != null
            ? Container(
                margin: EdgeInsets.only(top: 4),
                child: Text(
                  label,
                  style: TextStyle(color: grey),
                ),
              )
            : Container(),
        Container(
          margin: EdgeInsets.only(top: 4, bottom: 4),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            border: Border.all(color: Theme.of(context).disabledColor, width: 0.5),
          ),
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
                    // Text(UI.accountName(context, account)),
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
