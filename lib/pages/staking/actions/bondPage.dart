import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/bondExtraPage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/setPayeePage.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/plugin/store/balances.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/textTag.dart';
import 'package:polkawallet_ui/components/txButton.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginAddressFormItem.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginButton.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginInputBalance.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginTextFormField.dart';
import 'package:polkawallet_ui/utils/consts.dart';
// import 'package:polkawallet_ui/pages/accountListPage.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/index.dart';

class BondPage extends StatefulWidget {
  BondPage(this.plugin, this.keyring, {this.onNext});
  final PluginKusama plugin;
  final Keyring keyring;
  final Function(TxConfirmParams)? onNext;
  @override
  _BondPageState createState() => _BondPageState();
}

class _BondPageState extends State<BondPage> {
  final TextEditingController _amountCtrl = new TextEditingController();

  final _rewardToOptions = ['Staked', 'Stash', 'Controller'];

  KeyPairData? _controller;

  int _rewardTo = 0;
  String? _rewardAccount;

  String? _error;

  // Future<void> _changeControllerId(BuildContext context) async {
  //   final accounts = widget.keyring.keyPairs.toList();
  //   accounts.addAll(widget.keyring.externals);
  //   final acc = await Navigator.of(context).pushNamed(
  //     AccountListPage.route,
  //     arguments: AccountListPageParams(list: accounts),
  //   );
  //   if (acc != null) {
  //     setState(() {
  //       _controller = acc as KeyPairData?;
  //     });
  //   }
  // }

  void _onPayeeChanged(int? to, String? address) {
    setState(() {
      _rewardTo = to!;
      _rewardAccount = address;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'common')!;
    final dicStaking =
        I18n.of(context)!.getDic(i18n_full_dic_kusama, 'staking')!;
    final symbol = widget.plugin.networkState.tokenSymbol![0];
    final decimals = widget.plugin.networkState.tokenDecimals![0];

    BigInt freeBalance = BigInt.zero;
    if (widget.plugin.balances.native != null) {
      freeBalance =
          Fmt.balanceInt(widget.plugin.balances.native!.freeBalance.toString());
    }

    final rewardToOptions =
        _rewardToOptions.map((i) => dicStaking['reward.$i']).toList();

    List<KeyPairData> accounts;
    if (_rewardTo == 3) {
      accounts = widget.keyring.keyPairs;
      accounts.addAll(widget.keyring.externals);
    }

    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                          child: TextTag(
                        I18n.of(context)!.getDic(
                            i18n_full_dic_kusama, 'staking')!['stake.warn'],
                        color: PluginColorsDark.primary,
                        textColor: PluginColorsDark.headline1,
                        fontSize: UI.getTextSize(12, context),
                        margin: EdgeInsets.all(0),
                        padding: EdgeInsets.all(8),
                      ))
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: PluginAddressFormItem(
                    account: widget.keyring.current,
                    label: dicStaking['stash'],
                  ),
                ),
                // Padding(
                //   padding: EdgeInsets.only(left: 16, right: 16),
                //   child: PluginAddressFormItem(
                //     account: _controller ?? widget.keyring.current,
                //     label: dicStaking['controller'],
                //     // do not allow change controller here.
                //     // onTap: () => _changeControllerId(context),
                //   ),
                // ),
                Container(
                    margin: EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Column(
                      children: [
                        PluginInputBalance(
                          titleTag: dic['amount'],
                          balance: TokenBalanceData(
                              symbol: symbol,
                              decimals: decimals,
                              amount: freeBalance.toString()),
                          tokenIconsMap: widget.plugin.tokenIcons,
                          inputCtrl: _amountCtrl,
                          onInputChange: (value) {
                            var error = Fmt.validatePrice(value, context);
                            if (error == null) {
                              final amount = double.parse(value.trim());
                              if (amount >=
                                  Fmt.bigIntToDouble(freeBalance, decimals)) {
                                error = dic['amount.low'];
                              }
                              final minBond = Fmt.balanceInt(widget.plugin.store
                                  .staking.overview['minNominatorBond']);
                              if (amount <
                                  Fmt.bigIntToDouble(minBond, decimals)) {
                                error =
                                    '${dicStaking['stake.bond.min']} ${Fmt.priceCeilBigInt(minBond, decimals)}';
                              }
                            }
                            setState(() {
                              _error = error;
                            });
                          },
                        ),
                        ErrorMessage(
                          _error,
                          margin: EdgeInsets.symmetric(vertical: 2),
                        ),
                      ],
                    )),
                Container(
                  margin: EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: PayeeSelector(
                    widget.plugin,
                    widget.keyring,
                    initialValue: widget.plugin.store.staking.ownStashInfo,
                    onChange: _onPayeeChanged,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(16),
          child: PluginButton(
            title: dicStaking['action.bond']!,
            onPressed: () {
              if (_amountCtrl.text.trim().isNotEmpty && _error == null) {
                final inputAmount = _amountCtrl.text.trim();
                String? controllerId = widget.keyring.current.address;
                if (_controller != null) {
                  controllerId = _controller!.address;
                }
                widget.onNext!(TxConfirmParams(
                  txTitle: dicStaking['action.bond'],
                  module: 'staking',
                  call: 'bond',
                  txDisplay: {
                    dicStaking['bond.reward']: _rewardTo == 3
                        ? {'Account': _rewardAccount}
                        : rewardToOptions[_rewardTo],
                  },
                  txDisplayBold: {
                    dic["amount"]!: Text(
                      '$inputAmount $symbol',
                      style: Theme.of(context)
                          .textTheme
                          .headline1!
                          .copyWith(color: PluginColorsDark.headline1),
                    ),
                  },
                  params: [
                    // "controllerId":
                    controllerId,
                    // "amount"
                    Fmt.tokenInt(inputAmount, decimals).toString(),
                    // "to"
                    _rewardTo == 3 ? {'Account': _rewardAccount} : _rewardTo,
                  ],
                  isPlugin: true,
                ));
              }
            },
          ),
        ),
      ],
    );
  }
}
