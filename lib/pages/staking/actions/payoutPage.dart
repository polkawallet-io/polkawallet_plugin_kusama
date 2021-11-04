import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/addressFormItem.dart';
import 'package:polkawallet_ui/components/addressIcon.dart';
import 'package:polkawallet_ui/components/txButton.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/index.dart';

class PayoutPage extends StatefulWidget {
  PayoutPage(this.plugin, this.keyring);
  static final String route = '/staking/payout';
  final PluginKusama plugin;
  final Keyring keyring;
  @override
  _PayoutPageState createState() => _PayoutPageState();
}

class _PayoutPageState extends State<PayoutPage> {
  List _eraOptions = [];
  int _eraSelected = 0;
  int _eraSelectNew = 0;
  bool _loading = true;
  Map? _rewards;

  Future<void> _queryLatestRewards() async {
    final dynamic options =
        await widget.plugin.service.staking.fetchAccountRewardsEraOptions();
    setState(() {
      _eraOptions = options;
    });
    final res = await widget.plugin.service.staking
        .fetchAccountRewards(options[0]['value']);
    if (mounted) {
      setState(() {
        _loading = false;
        _rewards = res;
      });
    }
  }

  Future<void> _queryRewards(int selectedEra) async {
    setState(() {
      _loading = true;
    });
    final res = await widget.plugin.service.staking
        .fetchAccountRewards(_eraOptions[selectedEra]['value']);
    if (mounted) {
      setState(() {
        _loading = false;
        _rewards = res;
      });
    }
  }

  Future<void> _showEraSelect() async {
    await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).copyWith().size.height / 3,
          child: CupertinoPicker(
            backgroundColor: Colors.white,
            itemExtent: 58,
            scrollController: FixedExtentScrollController(
              initialItem: _eraSelected,
            ),
            children: _eraOptions.map((i) {
              return Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  _getEraText(i),
                  style: TextStyle(fontSize: 16),
                ),
              );
            }).toList(),
            onSelectedItemChanged: (v) {
              setState(() {
                _eraSelectNew = v;
              });
            },
          ),
        );
      },
    );

    if (_eraSelected != _eraSelectNew) {
      _queryRewards(_eraSelectNew);
      setState(() {
        _eraSelected = _eraSelectNew;
      });
    }
  }

  String _getEraText(Map selected) {
    if (selected['unit'] == 'eras') {
      final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'staking')!;
      return '${dic['reward.max']} ${selected['text']} ${selected['unit']}';
    } else {
      return '${selected['text']} ${selected['unit']}';
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _queryLatestRewards();
    });
  }

  Future<TxConfirmParams> _getParams() async {
    final dicStaking =
        I18n.of(context)!.getDic(i18n_full_dic_kusama, 'staking');
    final decimals = widget.plugin.networkState.tokenDecimals![0];

    List rewards = _rewards!['validators'];
    if (rewards.length == 1 && List.of(rewards[0]['eras']).length == 1) {
      final era = int.tryParse(rewards[0]['eras'][0]['era']);
      return TxConfirmParams(
        txTitle: dicStaking!['action.payout'],
        module: 'staking',
        call: 'payoutStakers',
        txDisplay: {
          'era': era,
          'validator': rewards[0]['validatorId'],
          'amount': Fmt.token(
            BigInt.parse(rewards[0]['available'].toString()),
            decimals,
            length: decimals,
          ),
        },
        params: [
          // validatorId
          rewards[0]['validatorId'],
          // era
          era.toString(),
        ],
      );
    }

    List params = [];
    rewards.forEach((i) {
      String? validatorId = i['validatorId'];
      List.of(i['eras']).forEach((era) {
        params.add(
            'api.tx.staking.payoutStakers("$validatorId", "${int.tryParse(era['era'])}")');
      });
    });
    final total = Fmt.balanceInt('0x${_rewards!['available']}');
    return TxConfirmParams(
      txTitle: dicStaking!['action.payout'],
      module: 'utility',
      call: 'batch',
      txDisplay: {
        'amount': Fmt.token(
          total,
          decimals,
          length: decimals,
        ),
        'txs': params,
      },
      params: [],
      rawParams: '[[${params.join(',')}]]',
    );
  }

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'common');
    final dicStaking =
        I18n.of(context)!.getDic(i18n_full_dic_kusama, 'staking')!;
    final decimals = widget.plugin.networkState.tokenDecimals![0];

    late BigInt rewardTotal;
    if (_rewards != null) {
      if (_rewards!['available'] == null) {
        rewardTotal = BigInt.zero;
      } else {
        rewardTotal = Fmt.balanceInt('0x${_rewards!['available']}');
      }
    }
    final List validators = _rewards?['validators'] ?? [];
    return Scaffold(
      appBar: AppBar(
        title: Text(dicStaking['action.payout']!),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(top: 16),
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 16, right: 16),
                    child: AddressFormItem(
                      widget.keyring.current,
                      label: dicStaking['reward.sender'],
                    ),
                  ),
                  Visibility(
                      visible: _eraOptions.length > 0,
                      child: ListTile(
                        title: Text(dicStaking['reward.time']!),
                        subtitle: _eraOptions.length > 0
                            ? Text(_getEraText(_eraOptions[_eraSelected]))
                            : null,
                        trailing: Icon(Icons.arrow_forward_ios, size: 18),
                        onTap: _loading ? null : () => _showEraSelect(),
                      )),
                  _loading
                      ? Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: CupertinoActivityIndicator(),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width / 2,
                              child: Text(dicStaking['reward.tip']!),
                            ),
                          ],
                        )
                      : Padding(
                          padding: EdgeInsets.only(left: 16, right: 16),
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: dic!['amount'],
                            ),
                            initialValue: Fmt.token(
                              rewardTotal,
                              decimals,
                              length: 8,
                            ),
                            readOnly: true,
                          ),
                        ),
                  Visibility(
                      visible: validators.length > 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 16, top: 16),
                            child: Text(
                              dicStaking['validators']!,
                              style: TextStyle(
                                  color:
                                      Theme.of(context).unselectedWidgetColor),
                            ),
                          ),
                          ...validators.map((e) {
                            return ListTile(
                              dense: true,
                              leading: AddressIcon(
                                e['validatorId'],
                                svg: widget.plugin.store.accounts
                                    .addressIconsMap[e['validatorId']],
                                size: 32,
                              ),
                              title: UI.accountDisplayName(
                                  e['validatorId'],
                                  widget.plugin.store.accounts
                                      .addressIndexMap[e['validatorId']]),
                              subtitle: Text('eras: ' +
                                  List.of(e['eras'])
                                      .map((e) =>
                                          int.tryParse(e['era'].toString()))
                                      .join(', ')),
                              trailing:
                                  Text(Fmt.balance(e['available'], decimals)),
                            );
                          }).toList()
                        ],
                      ))
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Visibility(
                  visible: _rewards != null && _rewards!['available'] != null,
                  child: TxButton(
                    getTxParams: _getParams,
                    onFinish: (Map? res) {
                      if (res != null) {
                        Navigator.of(context).pop(res);
                      }
                    },
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
