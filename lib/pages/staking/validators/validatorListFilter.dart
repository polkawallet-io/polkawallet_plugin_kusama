import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginIconButton.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginInputItem.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginOutlinedButtonSmall.dart';
import 'package:polkawallet_ui/utils/consts.dart';

enum ValidatorSortOptions { reward, staked, commission, judgements }

class ValidatorListFilter extends StatelessWidget {
  ValidatorListFilter(
      {required this.onSearchChange,
      this.onFilterChange,
      this.onSortChange,
      this.filters = const [true, false]});
  final Function(String) onSearchChange;
  final Function(List<bool>)? onFilterChange;
  final Function(int)? onSortChange;
  final List<bool> filters;

  void _showActions(BuildContext context) {
    final dicStaking =
        I18n.of(context)!.getDic(i18n_full_dic_kusama, 'staking');
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'common');
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: ValidatorSortOptions.values
            .map((i) => CupertinoActionSheetAction(
                  child: Text(dicStaking![i.toString().split('.')[1]] ?? ''),
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (onSortChange != null) {
                      onSortChange!(i.index);
                    }
                  },
                ))
            .toList(),
        cancelButton: CupertinoActionSheetAction(
          child: Text(dic!['cancel']!),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'staking')!;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Column(
        children: <Widget>[
          Row(
            children: [
              Expanded(
                child: PluginInputItem(
                  child: CupertinoTextField(
                    clearButtonMode: OverlayVisibilityMode.never,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    placeholder: dic['filter'],
                    placeholderStyle: Theme.of(context)
                        .textTheme
                        .headline4!
                        .copyWith(
                            color: PluginColorsDark.headline3, fontSize: 14),
                    decoration: BoxDecoration(color: Colors.transparent),
                    suffix: Container(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(Icons.search,
                          color: PluginColorsDark.headline3, size: 24),
                    ),
                    style: Theme.of(context).textTheme.headline4!.copyWith(
                        color: PluginColorsDark.headline2, fontSize: 14),
                    onChanged: (value) => onSearchChange(value.trim()),
                  ),
                  bgHeight: 40,
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 8),
                child: PluginIconButton(
                  color: PluginColorsDark.primary,
                  icon: Container(
                    padding: EdgeInsets.all(4),
                    child: Image.asset(
                        'packages/polkawallet_plugin_kusama/assets/images/staking/icon_sort.png'),
                  ),
                  onPressed: () => _showActions(context),
                ),
              )
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 8),
            child: Row(
              children: <Widget>[
                PluginOutlinedButtonSmall(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  active: filters[0] == true,
                  content: dic['filter.comm'],
                  color: filters[0] == true
                      ? PluginColorsDark.primary
                      : PluginColorsDark.cardColor,
                  activeTextcolor: PluginColorsDark.headline1,
                  unActiveTextcolor: PluginColorsDark.headline2,
                  onPressed: () {
                    onFilterChange!([!filters[0], filters[1]]);
                  },
                ),
                PluginOutlinedButtonSmall(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  active: filters[1] == true,
                  content: dic['filter.id'],
                  color: filters[1] == true
                      ? PluginColorsDark.primary
                      : PluginColorsDark.cardColor,
                  activeTextcolor: PluginColorsDark.headline1,
                  unActiveTextcolor: PluginColorsDark.headline2,
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
