import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:polkawallet_plugin_chainx/common/components/infoItem.dart';
import 'package:polkawallet_plugin_chainx/pages/staking/actions/bondExtraPage.dart';
import 'package:polkawallet_plugin_chainx/pages/staking/actions/payoutPage.dart';
import 'package:polkawallet_plugin_chainx/pages/staking/actions/rebondPage.dart';
import 'package:polkawallet_plugin_chainx/pages/staking/actions/redeemPage.dart';
import 'package:polkawallet_plugin_chainx/pages/staking/actions/rewardDetailPage.dart';
import 'package:polkawallet_plugin_chainx/pages/staking/actions/setControllerPage.dart';
import 'package:polkawallet_plugin_chainx/pages/staking/actions/setPayeePage.dart';
import 'package:polkawallet_plugin_chainx/pages/staking/actions/stakingDetailPage.dart';
import 'package:polkawallet_plugin_chainx/pages/staking/actions/unbondPage.dart';
import 'package:polkawallet_plugin_chainx/polkawallet_plugin_chainx.dart';
import 'package:polkawallet_plugin_chainx/pages/staking/topCard.dart';
import 'package:polkawallet_plugin_chainx/store/staking/types/nominationData.dart';
import 'package:polkawallet_plugin_chainx/store/staking/types/userInterestData.dart';
import 'package:polkawallet_plugin_chainx/utils/i18n/index.dart';
import 'package:polkawallet_sdk/api/subscan.dart';
import 'package:polkawallet_sdk/api/types/staking/ownStashInfo.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/listTail.dart';
import 'package:polkawallet_ui/components/roundedCard.dart';
import 'package:polkawallet_ui/components/addressIcon.dart';
import 'package:polkawallet_ui/components/outlinedCircle.dart';
import 'package:polkawallet_ui/utils/i18n.dart';
import 'package:polkawallet_ui/utils/index.dart';
import 'package:polkawallet_ui/utils/format.dart';

class StakingActions extends StatefulWidget {
  StakingActions(this.plugin, this.keyring);
  final PluginChainX plugin;
  final Keyring keyring;
  @override
  _StakingActions createState() => _StakingActions();
}

class StakedInfo {
  String address;
  String votes;
  String interests;
  String freeze;

  StakedInfo(String _address, String _votes, String _interests, String _freeze) {
    address = _address;
    votes = _votes;
    interests = _interests;
    freeze = _freeze;
  }
}

class _StakingActions extends State<StakingActions> with SingleTickerProviderStateMixin {
  final GlobalKey<RefreshIndicatorState> _refreshKey = new GlobalKey<RefreshIndicatorState>();

  bool _loading = false;
  bool _rewardLoading = false;

  TabController _tabController;
  int _tab = 0;

  int _txsPage = 0;
  bool _isLastPage = false;
  ScrollController _scrollController;

  Future<void> _updateStakingTxs() async {
    setState(() {
      _loading = true;
    });
    Map res = await widget.plugin.service.staking.updateStakingTxs(_txsPage);
    if (mounted) {
      setState(() {
        _loading = false;
      });

      if (res == null || res['extrinsics'] == null || res['extrinsics'].length < tx_list_page_size) {
        setState(() {
          _isLastPage = true;
        });
      }
    }
  }

  Future<void> _updateStakingRewardTxs() async {
    setState(() {
      _rewardLoading = true;
    });
    await widget.plugin.service.staking.updateStakingRewards();
    if (mounted) {
      setState(() {
        _rewardLoading = false;
      });
    }
  }

  Future<void> _updateStakingInfo() async {
    // _tab == 0 ? _updateStakingTxs() : _updateStakingRewardTxs();

    // await widget.plugin.service.staking.queryOwnStashInfo();
  }

  List<Widget> _buildMyStakedValidatorsList() {
    List<NominationData> validNominations = widget.plugin.store.staking.validNominations;
    List<UserInterestData> userInterests = widget.plugin.store.staking.userInterests;

    final dicStaking = I18n.of(context).getDic(i18n_full_dic_chainx, 'staking');

    List<Widget> res = [];

    List<StakedInfo> txs = [];

    res.add(Padding(padding: EdgeInsets.only(left: 20, bottom: 10), child: Text(dicStaking['mystaking.label'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))));

    String currentAccount = widget.keyring.current.address;

    if (currentAccount.isNotEmpty) {
      validNominations.forEach((nmn) {
        BigInt chunks = BigInt.zero;
        nmn.unbondedChunks?.forEach((chunk) => {chunks += BigInt.parse(chunk.value)});

        if (nmn.account == currentAccount) {
          BigInt interest = userInterests.length > 0 ? BigInt.parse(userInterests[0].interests.firstWhere((i) => i.validator == nmn.validatorId)?.interest) : BigInt.zero;
          txs.add(StakedInfo(nmn.validatorId, '${nmn.nomination} PCX', '${interest.toString()}', '${chunks.toString()}'));
        }
      });
    }

    res.addAll(txs.map((i) {
      return Container(
        color: Theme.of(context).cardColor,
        child: ListTile(
          leading: Container(
            width: 32,
            padding: EdgeInsets.only(top: 4),
            child: AddressIcon(
              widget.keyring.current.address,
              svg: widget.keyring.current.icon,
            ),
          ),
          title: UI.accountDisplayName(
            i.address,
            widget.plugin.store.accounts.addressIndexMap[i.address],
          ),
          subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${dicStaking['mystaking.votes']}: ${i.votes}', style: TextStyle(color: Colors.green)),
            Text('${dicStaking['mystaking.freeze']}: ${i.freeze}'),
          ]),
          trailing: Text('${i.interests}', style: TextStyle(color: Colors.red)),
          onTap: () {
            Navigator.of(context).pushNamed(StakingDetailPage.route, arguments: i);
          },
        ),
      );
    }));

    res.add(ListTail(
      isLoading: widget.plugin.store.staking.nominationLoading,
      isEmpty: txs.length == 0,
    ));

    return res;
  }

  @override
  void initState() {
    super.initState();

    _tabController = TabController(vsync: this, length: 2);

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent) {
        setState(() {
          if (!_isLastPage) {
            _txsPage += 1;
            _updateStakingTxs();
          }
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.plugin.store.staking.ownStashInfo == null) {
        if (_refreshKey.currentState != null) {
          _refreshKey.currentState.show();
        }
      } else {
        _updateStakingInfo();
      }
      widget.plugin.service.staking.queryAccountBondedInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        List<Widget> list = <Widget>[
          TopCard(widget.plugin.store.staking.validatorsInfo, widget.plugin.store.staking.validNominations, widget.plugin.store.staking.nominationLoading, widget.keyring.current.address),
        ];
        list.addAll(_buildMyStakedValidatorsList());
        return RefreshIndicator(
          key: _refreshKey,
          onRefresh: _updateStakingInfo,
          child: ListView(
            controller: _scrollController,
            children: list,
          ),
        );
      },
    );
  }
}
