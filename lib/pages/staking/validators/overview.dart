import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_chainx/pages/staking/validators/validator.dart';
import 'package:polkawallet_plugin_chainx/pages/staking/validators/validatorListFilter.dart';
import 'package:polkawallet_plugin_chainx/pages/staking/topCard.dart';
import 'package:polkawallet_plugin_chainx/polkawallet_plugin_chainx.dart';
import 'package:polkawallet_plugin_chainx/store/staking/types/validatorData.dart';
import 'package:polkawallet_plugin_chainx/utils/format.dart';
import 'package:polkawallet_plugin_chainx/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';

const validator_list_page_size = 100;

class StakingOverviewPage extends StatefulWidget {
  StakingOverviewPage(this.plugin, this.keyring);
  final PluginChainX plugin;
  final Keyring keyring;

  @override
  _StakingOverviewPageState createState() => _StakingOverviewPageState();
}

class _StakingOverviewPageState extends State<StakingOverviewPage> with SingleTickerProviderStateMixin {
  final GlobalKey<RefreshIndicatorState> _refreshKey = new GlobalKey<RefreshIndicatorState>();

  bool _loading = false;
  int _sort = 0;
  String _filter = '';

  TabController _tabController;
  int _tab = 0;

  Future<void> _refreshData() async {
    if (_loading) {
      return;
    }
    setState(() {
      _loading = true;
    });

    // _fetchRecommendedValidators();
    widget.plugin.service.staking.queryElectedInfo();
    // await widget.plugin.service.staking.queryOwnStashInfo();
  }

  @override
  void initState() {
    super.initState();

    _tabController = TabController(vsync: this, length: 3);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dicStaking = I18n.of(context).getDic(i18n_full_dic_chainx, 'staking');
    return Observer(
      builder: (_) {
        final int decimals = widget.plugin.networkState.tokenDecimals;
        final List<Tab> _listTabs = <Tab>[
          Tab(
            text: dicStaking['overview.validator'],
          ),
          Tab(
            text: dicStaking['overview.candidate'],
          ),
          Tab(
            text: dicStaking['overview.dropout'],
          ),
        ];
        List list = [
          // index_0: the overview card
          TopCard(widget.plugin.store.staking.validatorsInfo, widget.plugin.store.staking.validNominations,
              widget.plugin.store.staking.nominationLoading || widget.plugin.sdk.api.connectedNode == null, widget.keyring.current.address),
          // index_1: the 'Validators' label
          Container(
            color: Theme.of(context).cardColor,
            child: TabBar(
              labelColor: Colors.black87,
              labelStyle: TextStyle(fontSize: 16),
              controller: _tabController,
              tabs: _listTabs,
              onTap: (i) {
                setState(() {
                  _tab = i;
                });
              },
            ),
          ),
        ];
        if (widget.plugin.store.staking.validatorsInfo.length > 0) {
          // index_2: the filter Widget
          list.add(Container(
            color: Colors.white,
            padding: EdgeInsets.only(top: 8),
            child: ValidatorListFilter(
              needSort: true,
              onSortChange: (value) {
                if (value != _sort) {
                  setState(() {
                    _sort = value;
                  });
                }
              },
              onFilterChange: (value) {
                if (value != _filter) {
                  setState(() {
                    _filter = value;
                  });
                }
              },
            ),
          ));
          List<ValidatorData> ls = widget.plugin.store.staking.validatorsInfo.where((validator) {
            if (_tab == 0) return validator.isValidating;
            if (_tab == 2) return validator.isChilled;
            return !validator.isValidating && !validator.isChilled;
          }).toList();
          // filter list
          ls = PluginFmt.filterValidatorList(ls, _filter, widget.plugin.store.accounts.addressIndexMap);
          // sort list
          ls.sort((a, b) => PluginFmt.sortValidatorList(widget.plugin.store.accounts.addressIndexMap, a, b, _sort));
          // if (_tab == 1) {
          //   ls.sort((a, b) {
          //     final aLength = widget.plugin.store.staking.nominationsMap[a.accountId]?.length ?? 0;
          //     final bLength = widget.plugin.store.staking.nominationsMap[b.accountId]?.length ?? 0;
          //     return 0 - aLength.compareTo(bLength);
          //   });
          // }
          list.addAll(ls);
        } else {
          list.add(Container(
            height: 160,
            child: CupertinoActivityIndicator(),
          ));
        }
        return RefreshIndicator(
          key: _refreshKey,
          onRefresh: _refreshData,
          child: ListView.builder(
            itemCount: list.length,
            itemBuilder: (BuildContext context, int i) {
              // we already have the index_0 - index_3 Widget
              if (i < 3) {
                return list[i];
              }
              ValidatorData acc = list[i];
              Map accInfo = widget.plugin.store.accounts.addressIndexMap[acc.accountId];
              final icon = widget.plugin.store.accounts.addressIconsMap[acc.accountId];
              return Validator(acc, accInfo, icon, decimals,
                  // widget.plugin.store.staking.nominationsMap[acc.accountId] ?? [],
                  []);
            },
          ),
        );
      },
    );
  }
}

enum NomStatus { active, over, inactive, waiting }
