import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_chainx/pages/governance/council/council.dart';
import 'package:polkawallet_plugin_chainx/polkawallet_plugin_chainx.dart';
import 'package:polkawallet_plugin_chainx/utils/format.dart';
import 'package:polkawallet_plugin_chainx/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/roundedButton.dart';
import 'package:polkawallet_ui/utils/i18n.dart';

class CandidateListPage extends StatefulWidget {
  CandidateListPage(this.plugin, this.keyring);
  final PluginChainX plugin;
  final Keyring keyring;

  static final String route = '/gov/candidates';

  @override
  _CandidateList createState() => _CandidateList();
}

class _CandidateList extends State<CandidateListPage> {
  final List<List> _selected = List<List>();
  final List<List> _notSelected = List<List>();
  Map<String, bool> _selectedMap = Map<String, bool>();

  String _filter = '';

  @override
  void initState() {
    super.initState();

    setState(() {
      widget.plugin.store.gov.council.members.forEach((i) {
        _notSelected.add(i);
        _selectedMap[i[0]] = false;
      });
      widget.plugin.store.gov.council.runnersUp.forEach((i) {
        _notSelected.add(i);
        _selectedMap[i[0]] = false;
      });
      widget.plugin.store.gov.council.candidates.forEach((i) {
        _notSelected.add([i, '0']);
        _selectedMap[i] = false;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    List args = ModalRoute.of(context).settings.arguments;
    if (args.length > 0) {
      List<List> ls = List<List>.from(args);
      setState(() {
        _selected.addAll(ls);
        _notSelected.removeWhere((i) => ls.indexWhere((arg) => arg[0] == i[0]) > -1);
        ls.forEach((i) {
          _selectedMap[i[0]] = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context).getDic(i18n_full_dic_chainx, 'gov');
    final decimals = widget.plugin.networkState.tokenDecimals;
    final symbol = widget.plugin.networkState.tokenSymbol;

    List<List> list = [];
    list.addAll(_selected);
    // filter the _notSelected list
    List<List> retained = List.of(_notSelected);
    retained = PluginFmt.filterCandidateList(retained, _filter, widget.plugin.store.accounts.addressIndexMap);
    list.addAll(retained);

    return Scaffold(
      appBar: AppBar(
        title: Text(dic['candidate']),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              color: Theme.of(context).cardColor,
              padding: EdgeInsets.all(16),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: CupertinoTextField(
                      padding: EdgeInsets.fromLTRB(16, 6, 16, 6),
                      placeholder: I18n.of(context).getDic(i18n_full_dic_chainx, 'staking')['filter'],
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                        border: Border.all(width: 0.5, color: Theme.of(context).dividerColor),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _filter = value.trim();
                        });
                      },
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: list.map(
                  (i) {
                    return CandidateItem(
                      accInfo: widget.plugin.store.accounts.addressIndexMap[i[0]],
                      icon: widget.plugin.store.accounts.addressIconsMap[i[0]],
                      balance: i,
                      tokenSymbol: symbol,
                      decimals: decimals,
                      trailing: CupertinoSwitch(
                        value: _selectedMap[i[0]],
                        onChanged: (value) {
                          setState(() {
                            _selectedMap[i[0]] = value;
                          });
                          Timer(Duration(milliseconds: 300), () {
                            setState(() {
                              if (value) {
                                _selected.add(i);
                                _notSelected.removeWhere((item) => item[0] == i[0]);
                              } else {
                                _selected.removeWhere((item) => item[0] == i[0]);
                                _notSelected.add(i);
                              }
                            });
                          });
                        },
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              child: RoundedButton(
                text: I18n.of(context).getDic(i18n_full_dic_ui, 'common')['ok'],
                onPressed: () => Navigator.of(context).pop(_selected),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
