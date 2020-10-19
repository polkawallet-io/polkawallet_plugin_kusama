import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:polkawallet_plugin_kusama/common/components/infoItem.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/bondExtraPage.dart';
// import 'package:polkawallet_plugin_kusama/pages/staking/actions/bondPage.dart';
// import 'package:polkawallet_plugin_kusama/pages/staking/actions/payoutPage.dart';
// import 'package:polkawallet_plugin_kusama/pages/staking/actions/redeemPage.dart';
// import 'package:polkawallet_plugin_kusama/pages/staking/actions/rewardDetailPage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/setControllerPage.dart';
// import 'package:polkawallet_plugin_kusama/pages/staking/actions/setPayeePage.dart';
// import 'package:polkawallet_plugin_kusama/pages/staking/actions/stakingDetailPage.dart';
// import 'package:polkawallet_plugin_kusama/pages/staking/actions/unbondPage.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/store/index.dart';
import 'package:polkawallet_plugin_kusama/store/staking/types/ownStashInfo.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/api/subscan.dart';
import 'package:polkawallet_sdk/api/types/balanceData.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/listTail.dart';
import 'package:polkawallet_ui/components/roundedCard.dart';
import 'package:polkawallet_ui/components/addressIcon.dart';
import 'package:polkawallet_ui/components/tapTooltip.dart';
import 'package:polkawallet_ui/components/outlinedCircle.dart';
import 'package:polkawallet_ui/utils/index.dart';
import 'package:polkawallet_ui/utils/format.dart';

class StakingActions extends StatefulWidget {
  StakingActions(this.plugin, this.keyring);
  final PluginKusama plugin;
  final Keyring keyring;
  @override
  _StakingActions createState() => _StakingActions();
}

class _StakingActions extends State<StakingActions>
    with SingleTickerProviderStateMixin {
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      new GlobalKey<RefreshIndicatorState>();

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

      if (res == null ||
          res['extrinsics'] == null ||
          res['extrinsics'].length < tx_list_page_size) {
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
    _tab == 0 ? _updateStakingTxs() : _updateStakingRewardTxs();

    await widget.plugin.service.staking.queryOwnStashInfo();
  }

  List<Widget> _buildTxList() {
    final dic = I18n.of(context).getDic(i18n_full_dic_kusama, 'common');
    List<Widget> res = [];
    res.addAll(widget.plugin.store.staking.txs.map((i) {
      return Container(
        color: Theme.of(context).cardColor,
        child: ListTile(
          leading: Container(
            width: 32,
            padding: EdgeInsets.only(top: 4),
            child: i.success
                ? Image.asset(
                    'packages/polkawallet_plugin_kusama/assets/images/staking/ok.png')
                : Image.asset(
                    'packages/polkawallet_plugin_kusama/assets/images/staking/error.png'),
          ),
          title: Text(i.call),
          subtitle: Text(Fmt.dateTime(
              DateTime.fromMillisecondsSinceEpoch(i.blockTimestamp * 1000))),
          trailing: i.success
              ? Text(
                  dic['success'],
                  style: TextStyle(color: Colors.green),
                )
              : Text(
                  dic['failed'],
                  style: TextStyle(color: Colors.pink),
                ),
          onTap: () {
            // Navigator.of(context)
            //     .pushNamed(StakingDetailPage.route, arguments: i);
          },
        ),
      );
    }));

    res.add(ListTail(
      isLoading: widget.plugin.store.staking.txsLoading,
      isEmpty: widget.plugin.store.staking.txs.length == 0,
    ));

    return res;
  }

  List<Widget> _buildRewardsList() {
    final int decimals = widget.plugin.networkState.tokenDecimals;
    final String symbol = widget.plugin.networkState.tokenSymbol;

    List<Widget> res = [];
    res.addAll(widget.plugin.store.staking.txsRewards.map((i) {
      return Container(
        color: Theme.of(context).cardColor,
        child: ListTile(
          leading: Container(
            width: 32,
            padding: EdgeInsets.only(top: 4),
            child: i.eventId == 'Reward'
                ? SvgPicture.asset(
                    'packages/polkawallet_plugin_kusama/assets/images/staking/reward.svg')
                : SvgPicture.asset(
                    'packages/polkawallet_plugin_kusama/assets/images/staking/slash.svg'),
          ),
          title: Text(i.eventId),
          subtitle: Text(Fmt.dateTime(
              DateTime.fromMillisecondsSinceEpoch(i.blockTimestamp * 1000))),
          trailing: Text('${Fmt.balance(i.amount, decimals)} $symbol'),
          onTap: () {
            // Navigator.of(context)
            //     .pushNamed(RewardDetailPage.route, arguments: i);
          },
        ),
      );
    }));

    res.add(ListTail(
      isLoading: _rewardLoading,
      isEmpty: widget.plugin.store.staking.txsRewards.length == 0,
    ));

    return res;
  }

  Widget _buildActionCard() {
    var dic = I18n.of(context).getDic(i18n_full_dic_kusama, 'staking');
    final bool hasData = widget.plugin.store.staking.ownStashInfo != null;

    bool isStash = true;
    bool isController = true;
    bool isSelfControl = true;
    final acc02 = KeyPairData();
    acc02.address = widget.keyring.current.address;
    acc02.pubKey = widget.keyring.current.pubKey;
    if (hasData) {
      // we assume an address is stash if it's stakingData
      // is empty (!isOwnStash && !isOwnController).
      isStash = widget.plugin.store.staking.ownStashInfo.isOwnStash ||
          (!widget.plugin.store.staking.ownStashInfo.isOwnStash &&
              !widget.plugin.store.staking.ownStashInfo.isOwnController);
      isController = widget.plugin.store.staking.ownStashInfo.isOwnController;
      isSelfControl = isStash && isController;

      widget.plugin.store.accounts
          .pubKeyAddressMap[widget.plugin.sdk.api.connectedNode.ss58]
          ?.forEach((k, v) {
        if (widget.plugin.store.staking.ownStashInfo.isOwnStash &&
            v == widget.plugin.store.staking.ownStashInfo.controllerId) {
          acc02.address = v;
          acc02.pubKey = k;
          return;
        }
        if (widget.plugin.store.staking.ownStashInfo.isOwnController &&
            v == widget.plugin.store.staking.ownStashInfo.stashId) {
          acc02.address = v;
          acc02.pubKey = k;
          return;
        }
      });
    }

    final symbol = widget.plugin.networkState.tokenSymbol;
    final decimals = widget.plugin.networkState.tokenDecimals;

    final BalanceData info = widget.plugin.balances.native;
    final freeBalance = BigInt.parse(info.freeBalance.toString());
    final reservedBalance = BigInt.parse(info.reservedBalance.toString());
    final totalBalance = freeBalance + reservedBalance;
    BigInt bonded = BigInt.zero;
    BigInt redeemable = BigInt.zero;
    if (hasData &&
        widget.plugin.store.staking.ownStashInfo.stakingLedger != null) {
      bonded = BigInt.parse(widget
          .plugin.store.staking.ownStashInfo.stakingLedger['active']
          .toString());
      redeemable = BigInt.parse(widget
          .plugin.store.staking.ownStashInfo.account.redeemable
          .toString());
    }
    BigInt unlocking = widget.plugin.store.staking.accountUnlockingTotal;
    unlocking -= redeemable;

    return RoundedCard(
      margin: EdgeInsets.fromLTRB(16, 12, 16, 24),
      padding: EdgeInsets.all(16),
      child: !hasData
          ? Container(
              padding: EdgeInsets.only(top: 80, bottom: 80),
              child: CupertinoActivityIndicator(),
            )
          : Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(right: 16),
                      child: AddressIcon(
                        widget.keyring.current.address,
                        svg: widget.keyring.current.icon,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            UI.accountName(context, widget.keyring.current),
                            style: Theme.of(context).textTheme.headline4,
                          ),
                          Text(Fmt.address(widget.keyring.current.address))
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '${Fmt.priceFloorBigInt(totalBalance, decimals, lengthMax: 3)}',
                            style: Theme.of(context).textTheme.headline4,
                          ),
                          Text(
                            dic['balance'],
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                RowAccount02(
                  acc02: acc02,
                  accountId: widget.plugin.store.staking.ownStashInfo.account
                          .accountId ??
                      widget.keyring.current.address,
                  isController: isController,
                  isSelfControl: isSelfControl,
                  stashInfo: widget.plugin.store.staking.ownStashInfo,
                  store: widget.plugin.store,
                ),
                Divider(),
                StakingInfoPanel(
                  hasData: hasData,
                  isController: isController,
                  accountId: widget.keyring.current.address,
                  stashInfo: widget.plugin.store.staking.ownStashInfo,
                  decimals: decimals,
                  blockDuration: widget.plugin.networkConst['babe']
                      ['expectedBlockTime'],
                  bonded: bonded,
                  unlocking: unlocking,
                  redeemable: redeemable,
                  available: BigInt.parse(info.availableBalance.toString()),
                  networkLoading: !hasData,
                ),
                Divider(),
                StakingActionsPanel(
                  isStash: isStash,
                  isController: isController,
                  stashInfo: widget.plugin.store.staking.ownStashInfo,
                  bonded: bonded,
                  controller: acc02,
                  onSuccess: () => _refreshKey.currentState.show(),
                ),
              ],
            ),
    );
  }

  @override
  void initState() {
    super.initState();

    _tabController = TabController(vsync: this, length: 2);

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent) {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic =
        I18n.of(context).getDic(i18n_full_dic_kusama, 'staking');

    return Observer(
      builder: (_) {
        List<Widget> list = <Widget>[
          _buildActionCard(),
          Container(
            color: Theme.of(context).cardColor,
            padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TabBar(
              labelColor: Colors.black87,
              labelStyle: TextStyle(fontSize: 18),
              controller: _tabController,
              tabs: <Tab>[
                Tab(
                  text: dic['txs'],
                ),
                Tab(
                  text: dic['txs.reward'],
                ),
              ],
              onTap: (i) {
                i == 0 ? _updateStakingTxs() : _updateStakingRewardTxs();
                setState(() {
                  _tab = i;
                });
              },
            ),
          ),
        ];
        list.addAll(_tab == 0 ? _buildTxList() : _buildRewardsList());
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

class RowAccount02 extends StatelessWidget {
  RowAccount02({
    this.acc02,
    this.accountId,
    this.isController,
    this.isSelfControl,
    this.stashInfo,
    this.store,
  });

  /// 1. if acc02 != null, then we have acc02 in accountListAll.
  /// 2. if current account is controller, and it's not self-controlled,
  ///    we display a stashId as address02, or we display a controllerId.
  final KeyPairData acc02;
  final String accountId;
  final bool isController;
  final bool isSelfControl;
  final OwnStashInfoData stashInfo;
  final PluginStore store;

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic =
        I18n.of(context).getDic(i18n_full_dic_kusama, 'staking');
    final stashId = stashInfo.stashId ?? accountId;
    final controllerId = stashInfo.controllerId ?? accountId;
    final String address02 =
        isController && !isSelfControl ? stashId : controllerId;
    return Container(
      padding: EdgeInsets.only(top: 8, bottom: 8),
      child: stashInfo != null
          ? Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 4, right: 20),
                  child: acc02 != null
                      ? AddressIcon(address02,
                          svg: store.accounts.addressIconsMap[acc02.address],
                          size: 32)
                      : AddressIcon(address02, size: 32),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        isController && !isSelfControl
                            ? dic['stash']
                            : dic['controller'],
                        style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).unselectedWidgetColor),
                      ),
                      Text(
                        Fmt.address(address02),
                        style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).unselectedWidgetColor),
                      ),
                    ],
                  ),
                ),
                Container()
              ],
            )
          : Container(),
    );
  }
}

class StakingInfoPanel extends StatelessWidget {
  StakingInfoPanel({
    this.hasData,
    this.isController,
    this.accountId,
    this.stashInfo,
    this.decimals,
    this.blockDuration,
    this.bonded,
    this.unlocking,
    this.redeemable,
    this.available,
    this.networkLoading,
  });

  final bool hasData;
  final bool isController;
  final String accountId;
  final OwnStashInfoData stashInfo;
  final int decimals;
  final int blockDuration;
  final BigInt bonded;
  final BigInt unlocking;
  final BigInt redeemable;
  final BigInt available;
  final bool networkLoading;

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic =
        I18n.of(context).getDic(i18n_full_dic_kusama, 'staking');
    final Map<String, String> dicGov =
        I18n.of(context).getDic(i18n_full_dic_kusama, 'gov');
    Color actionButtonColor = Theme.of(context).primaryColor;
    final unlockDetail = List.of(stashInfo.unbondings['mapped'])
        .map((e) {
          return '${dic['bond.unlocking']}:  ${Fmt.balance(e[0], decimals)}\n'
              '${dicGov['remain']}:  ${Fmt.blockToTime(e[1], blockDuration)}';
        })
        .toList()
        .join('\n\n');
    return Padding(
      padding: EdgeInsets.only(top: 4, bottom: 4),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              InfoItem(
                title: dic['bonded'],
                content: Fmt.priceFloorBigInt(bonded, decimals, lengthMax: 3),
                crossAxisAlignment: CrossAxisAlignment.center,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(dic['bond.unlocking'], style: TextStyle(fontSize: 12)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        unlocking > BigInt.zero
                            ? TapTooltip(
                                child: Padding(
                                  padding: EdgeInsets.only(right: 2),
                                  child: Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: actionButtonColor,
                                  ),
                                ),
                                message: '\n$unlockDetail\n',
                              )
                            : Container(),
                        Text(
                          Fmt.priceFloorBigInt(unlocking, decimals,
                              lengthMax: 3),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).unselectedWidgetColor,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(dic['bond.redeemable'],
                        style: TextStyle(fontSize: 12)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          Fmt.priceFloorBigInt(
                            redeemable,
                            decimals,
                            lengthMax: 3,
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).unselectedWidgetColor,
                          ),
                        ),
                        isController && redeemable > BigInt.zero
                            ? GestureDetector(
                                child: Container(
                                  padding: EdgeInsets.only(left: 4),
                                  child: Icon(
                                    Icons.lock_open,
                                    size: 16,
                                    color: actionButtonColor,
                                  ),
                                ),
                                onTap: () {
                                  // Navigator.of(context)
                                  //     .pushNamed(RedeemPage.route);
                                },
                              )
                            : Container()
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
          Container(
            height: 16,
          ),
          Row(
            children: <Widget>[
              InfoItem(
                title: dic['available'],
                content:
                    Fmt.priceFloorBigInt(available, decimals, lengthMax: 3),
                crossAxisAlignment: CrossAxisAlignment.center,
              ),
              InfoItem(
                title: dic['bond.reward'],
                content: stashInfo.destination,
                crossAxisAlignment: CrossAxisAlignment.center,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(dic['payout'], style: TextStyle(fontSize: 12)),
                    GestureDetector(
                      child: Container(
                        padding: EdgeInsets.all(1),
                        child: Icon(
                          Icons.card_giftcard,
                          size: 16,
                          color: actionButtonColor,
                        ),
                      ),
                      onTap: () {
                        if (!networkLoading) {
                          // Navigator.of(context).pushNamed(PayoutPage.route);
                        }
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StakingActionsPanel extends StatelessWidget {
  StakingActionsPanel({
    this.isStash,
    this.isController,
    this.stashInfo,
    this.bonded,
    this.controller,
    this.onSuccess,
  });

  final bool isStash;
  final bool isController;
  final OwnStashInfoData stashInfo;
  final BigInt bonded;
  final KeyPairData controller;
  final Function onSuccess;

  void _onAction(Future doAction) {
    doAction.then((res) {
      if (res ?? false) {
        onSuccess();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic =
        I18n.of(context).getDic(i18n_full_dic_kusama, 'staking');

    num actionButtonWidth = (MediaQuery.of(context).size.width - 64) / 3;
    Color actionButtonColor = Theme.of(context).primaryColor;
    Color disabledColor = Theme.of(context).unselectedWidgetColor;

    String bondButtonString = dic['action.bondAdjust'];
    bool setPayeeDisabled = true;
    Function onSetPayeeTap = () => null;
    bool setControllerDisabled = true;
    Function onSetControllerTap = () => null;
    if (isStash) {
      if (stashInfo.controllerId != null) {
        setControllerDisabled = false;
        onSetControllerTap = () => _onAction(Navigator.of(context)
            .pushNamed(SetControllerPage.route, arguments: controller));

        if (stashInfo.isOwnController) {
          setPayeeDisabled = false;
          // onSetPayeeTap = () => Navigator.of(context).pushNamed(
          //       SetPayeePage.route,
          //       arguments: stashInfo.destinationId,
          //     );
        }
      } else {
        bondButtonString = dic['action.bond'];
      }
    } else {
      if (bonded > BigInt.zero) {
        setPayeeDisabled = false;
        // onSetPayeeTap = () => Navigator.of(context).pushNamed(
        //       SetPayeePage.route,
        //       arguments: stashInfo.destinationId,
        //     );
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Container(
            width: actionButtonWidth,
            child: GestureDetector(
              child: Column(
                children: <Widget>[
                  OutlinedCircle(
                    icon: Icons.add,
                    color: actionButtonColor,
                  ),
                  Text(
                    bondButtonString,
                    style: TextStyle(
                      color: actionButtonColor,
                      fontSize: 11,
                    ),
                  )
                ],
              ),
              onTap: () {
                /// if stake clear, we can go to bond page.
                /// 1. it has no controller
                /// 2. it's stash is itself(it's not controller of another acc)
                if (stashInfo.controllerId == null && isStash) {
                  // Navigator.of(context).pushNamed(BondPage.route);
                  return;
                }
                showCupertinoModalPopup(
                  context: context,
                  builder: (BuildContext context) => CupertinoActionSheet(
                    actions: <Widget>[
                      /// disable bondExtra button if account is not stash
                      CupertinoActionSheetAction(
                        child: Text(
                          dic['action.bondExtra'],
                          style: TextStyle(
                            color: !isStash ? disabledColor : actionButtonColor,
                          ),
                        ),
                        onPressed: !isStash
                            ? () => {}
                            : () {
                                Navigator.of(context).pop();
                                Navigator.of(context)
                                    .pushNamed(BondExtraPage.route);
                              },
                      ),

                      /// disable unbond button if account is not controller
                      CupertinoActionSheetAction(
                        child: Text(
                          dic['action.unbond'],
                          style: TextStyle(
                            color: !isController
                                ? disabledColor
                                : actionButtonColor,
                          ),
                        ),
                        onPressed: !isController
                            ? () => {}
                            : () {
                                Navigator.of(context).pop();
                                // Navigator.of(context)
                                //     .pushNamed(UnBondPage.route);
                              },
                      ),
                    ],
                    cancelButton: CupertinoActionSheetAction(
                      child: Text(I18n.of(context)
                          .getDic(i18n_full_dic_kusama, 'common')['cancel']),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: actionButtonWidth,
            child: GestureDetector(
              child: Column(
                children: <Widget>[
                  OutlinedCircle(
                    icon: Icons.repeat,
                    color: setPayeeDisabled ? disabledColor : actionButtonColor,
                  ),
                  Text(
                    dic['action.reward'],
                    style: TextStyle(
                        color: setPayeeDisabled
                            ? disabledColor
                            : actionButtonColor,
                        fontSize: 11),
                  )
                ],
              ),
              onTap: onSetPayeeTap,
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: actionButtonWidth,
            child: GestureDetector(
              child: Column(
                children: <Widget>[
                  OutlinedCircle(
                    icon: Icons.repeat,
                    color: setControllerDisabled
                        ? disabledColor
                        : actionButtonColor,
                  ),
                  Text(
                    dic['action.control'],
                    style: TextStyle(
                        color: setControllerDisabled
                            ? disabledColor
                            : actionButtonColor,
                        fontSize: 11),
                  )
                ],
              ),
              onTap: onSetControllerTap,
            ),
          ),
        )
      ],
    );
  }
}
