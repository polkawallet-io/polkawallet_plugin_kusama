import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_chainx/pages/staking/actions/rebondPageWrapper.dart';
import 'package:polkawallet_plugin_chainx/polkawallet_plugin_chainx.dart';
import 'package:polkawallet_plugin_chainx/pages/staking/topCard.dart';
import 'package:polkawallet_plugin_chainx/store/staking/types/nominationData.dart';
import 'package:polkawallet_plugin_chainx/store/staking/types/unboundArgData.dart';
import 'package:polkawallet_plugin_chainx/store/staking/types/userInterestData.dart';
import 'package:polkawallet_plugin_chainx/pages/staking/actions/stakePage.dart';
import 'package:polkawallet_plugin_chainx/pages/staking/actions/claimPageWrapper.dart';
import 'package:polkawallet_plugin_chainx/pages/staking/actions/unboundPageWrapper.dart';
import 'package:polkawallet_plugin_chainx/pages/staking/actions/rebondPageWrapper.dart';
import 'package:polkawallet_plugin_chainx/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/listTail.dart';
import 'package:polkawallet_ui/components/addressIcon.dart';
import 'package:polkawallet_ui/utils/index.dart';
import 'package:polkawallet_ui/utils/format.dart';

enum ValidatorSortOptions { vote, claim, unbound, rebond }

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

  ScrollController _scrollController;

  Future<void> _updateStakingTxs() async {
    if (_loading) return;
    setState(() {
      _loading = true;
    });
    await widget.plugin.service.staking.queryNominations(widget.keyring.current.address);
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  void _showActions(StakedInfo info) {
    final dicStaking = I18n.of(context).getDic(i18n_full_dic_chainx, 'staking');
    final dic = I18n.of(context).getDic(i18n_full_dic_chainx, 'common');

    final validator = widget.plugin.store.staking.validatorsInfo.where((val) => val.accountId == info.address)?.first;

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: ValidatorSortOptions.values
            .map((i) => CupertinoActionSheetAction(
                  child: Text(dicStaking['mystaking.action.' + i.toString().split('.')[1]]),
                  onPressed: () {
                    Navigator.of(context).pop();
                    // widget.onSortChange(i.index);
                    switch (i.index) {
                      case 0:
                        Navigator.of(context).pushNamed(StakePage.route, arguments: validator);
                        break;
                      case 1:
                        Navigator.of(context).pushNamed(ClaimPageWrapper.route, arguments: validator);
                        break;
                      case 2:
                        Navigator.of(context).pushNamed(UnboundPageWrapper.route, arguments: UnboundArgData(validator, Fmt.priceFloorBigInt(Fmt.balanceInt(info.votes), 8, lengthMax: 4)));
                      case 3:
                        Navigator.of(context).pushNamed(RebondPageWrapper.route, arguments: UnboundArgData(validator, Fmt.priceFloorBigInt(Fmt.balanceInt(info.votes), 8, lengthMax: 4)));
                        break;
                      default:
                        break;
                    }
                  },
                ))
            .toList(),
        cancelButton: CupertinoActionSheetAction(
          child: Text(dic['cancel']),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  List<Widget> _buildMyStakedValidatorsList() {
    List<NominationData> validNominations = widget.plugin.store.staking.validNominations;
    List<UserInterestData> userInterests = widget.plugin.store.staking.userInterests;
    var theme = Theme.of(context);

    final dicStaking = I18n.of(context).getDic(i18n_full_dic_chainx, 'staking');

    List<Widget> res = [];

    List<StakedInfo> txs = [];

    res.add(Padding(
        padding: EdgeInsets.only(top: 50, left: 20, bottom: 10, right: 20),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(dicStaking['mystaking.label'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          GestureDetector(
            child: Container(
              margin: EdgeInsets.only(left: 8),
              padding: EdgeInsets.fromLTRB(16, 6, 16, 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(24)),
                border: Border.all(width: 0.5, color: theme.dividerColor),
              ),
              child: Text(dicStaking['refresh']),
            ),
            onTap: _updateStakingTxs,
          )
        ])));

    String currentAccount = widget.keyring.current.address;

    if (currentAccount.isNotEmpty) {
      validNominations.forEach((nmn) {
        BigInt chunks = BigInt.zero;
        nmn.unbondedChunks?.forEach((chunk) => {chunks += BigInt.from(chunk.value)});

        if (nmn.account == currentAccount) {
          BigInt interest = userInterests.length > 0 ? BigInt.parse(userInterests[0].interests.firstWhere((i) => i.validator == nmn.validatorId)?.interest) : BigInt.zero;
          txs.add(StakedInfo(nmn.validatorId, nmn.nomination.toString(), interest.toString(), chunks.toString()));
        }
      });
    }

    res.addAll(txs.map((i) {
      final icon = widget.plugin.store.accounts.addressIconsMap[i.address];
      return Container(
        color: Theme.of(context).cardColor,
        child: ListTile(
          leading: Container(
            width: 32,
            padding: EdgeInsets.only(top: 4),
            child: AddressIcon(
              i.address,
              svg: icon,
            ),
          ),
          title: UI.accountDisplayName(
            i.address,
            widget.plugin.store.accounts.addressIndexMap[i.address],
          ),
          subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${dicStaking['mystaking.votes']}: ${Fmt.priceFloorBigInt(Fmt.balanceInt(i.votes.toString()), 8, lengthMax: 4)}', style: TextStyle(color: Colors.green)),
            Text('${dicStaking['mystaking.freeze']}: ${Fmt.priceFloorBigInt(Fmt.balanceInt(i.freeze.toString()), 8, lengthMax: 4)}'),
          ]),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(dicStaking['mystaking.interests'], style: TextStyle(color: Colors.red)),
              Text(Fmt.priceFloorBigInt(Fmt.balanceInt(i.interests.toString()), 8, lengthMax: 4), style: TextStyle(color: Colors.red))
            ],
          ),
          onTap: () {
            _showActions(i);
          },
        ),
      );
    }));

    res.add(ListTail(
      isLoading: widget.plugin.store.staking.nominationLoading || widget.plugin.sdk.api.connectedNode == null,
      isEmpty: txs.length == 0,
    ));

    return res;
  }

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent) {
        setState(() {
          _updateStakingTxs();
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('WidgetsBinding.instance.addPostFrameCallback');
      _updateStakingTxs();
      // if (widget.plugin.store.staking.ownStashInfo == null) {
      //   if (_refreshKey.currentState != null) {
      //     _refreshKey.currentState.show();
      //   }
      // } else {
      //   _updateStakingInfo();
      // }
      // widget.plugin.service.staking.queryAccountBondedInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        List<Widget> list = <Widget>[
          TopCard(widget.plugin.store.staking.validatorsInfo, widget.plugin.store.staking.validNominations,
              widget.plugin.store.staking.nominationLoading || widget.plugin.sdk.api.connectedNode == null, widget.keyring.current.address),
        ];
        list.addAll(_buildMyStakedValidatorsList());
        return RefreshIndicator(
          key: _refreshKey,
          onRefresh: _updateStakingTxs,
          child: ListView(
            controller: _scrollController,
            children: list,
          ),
        );
      },
    );
  }
}
