import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_ui/components/addressIcon.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_plugin_chainx/common/components/UI.dart';

class CustomDropdown<T> extends StatelessWidget {
  final List<DropdownMenuItem<T>> dropdownMenuItemList;
  final ValueChanged<T> onChanged;
  final T value;
  final bool isEnabled;
  final String label;

  CustomDropdown({
    Key key,
    @required this.dropdownMenuItemList,
    @required this.onChanged,
    @required this.value,
    @required this.label,
    this.isEnabled = true,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
        ignoring: !isEnabled,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          label != null
              ? Container(
                  margin: EdgeInsets.only(top: 4),
                  child: Text(
                    label,
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : Container(),
          Container(
            margin: EdgeInsets.only(top: 4, bottom: 4),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              border: Border.all(color: Theme.of(context).disabledColor, width: 0.5),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                isExpanded: true,
                itemHeight: 50.0,
                style: TextStyle(fontSize: 15.0, color: isEnabled ? Colors.black : Colors.grey[700]),
                items: dropdownMenuItemList,
                onChanged: onChanged,
                value: value,
              ),
            ),
          )
        ]));
  }
}
