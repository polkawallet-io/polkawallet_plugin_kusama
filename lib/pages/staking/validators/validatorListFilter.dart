import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/outlinedButtonSmall.dart';

class ValidatorListFilter extends StatelessWidget {
  ValidatorListFilter(
      {this.onSearchChange,
      this.onFilterChange,
      this.filters = const [true, false]});
  final Function(String)? onSearchChange;
  final Function(List<bool>)? onFilterChange;
  final List<bool> filters;

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'staking')!;
    var theme = Theme.of(context);
    return Container(
      color: theme.cardColor,
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: <Widget>[
          CupertinoTextField(
            clearButtonMode: OverlayVisibilityMode.editing,
            padding: EdgeInsets.fromLTRB(16, 6, 16, 6),
            placeholder: dic['filter'],
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(24)),
              border: Border.all(width: 0.5, color: theme.dividerColor),
            ),
            onChanged: (value) => onSearchChange!(value.trim()),
          ),
          Container(
            margin: EdgeInsets.only(top: 8),
            child: Row(
              children: <Widget>[
                OutlinedButtonSmall(
                  active: filters[0] == true,
                  content: dic['filter.comm'],
                  onPressed: () {
                    onFilterChange!([!filters[0], filters[1]]);
                  },
                ),
                OutlinedButtonSmall(
                  active: filters[1] == true,
                  content: dic['filter.id'],
                  onPressed: () {
                    onFilterChange!([filters[0], !filters[1]]);
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
