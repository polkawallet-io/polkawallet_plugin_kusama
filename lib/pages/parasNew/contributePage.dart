import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/svg.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/api/types/parachain/fundData.dart';
import 'package:polkawallet_sdk/api/types/txInfoData.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginAddressFormItem.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginInputItem.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginScaffold.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginTagCard.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginTxButton.dart';
import 'package:polkawallet_ui/components/v3/txButton.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/index.dart';

class ContributePage extends StatefulWidget {
  const ContributePage(this.plugin, this.keyring);

  static final String route = '/paras/fund/contribute';
  final PluginKusama plugin;
  final Keyring keyring;

  @override
  _ContributePageState createState() => _ContributePageState();
}

class _ContributePageState extends State<ContributePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _amountCtrl = new TextEditingController();

  TxFeeEstimateResult? _fee;

  Future<TxConfirmParams?> _getTxParams() async {
    if (_formKey.currentState?.validate() ?? false) {
      final fund = ModalRoute.of(context)?.settings.arguments as FundData;
      final symbol = (widget.plugin.networkState.tokenSymbol ?? [''])[0];
      final decimals = (widget.plugin.networkState.tokenDecimals ?? [12])[0];
      return TxConfirmParams(
        txTitle: 'Contribute',
        module: 'crowdloan',
        call: 'contribute',
        txDisplay: {
          "destination": fund.paraId,
          "currency": symbol,
          "amount": _amountCtrl.text.trim(),
        },
        params: [
          // params.to
          fund.paraId,
          // params.amount
          Fmt.tokenInt(_amountCtrl.text.trim(), decimals).toString(),
          null,
        ],
        isPlugin: true,
      );
    }
    return null;
  }

  Future<String?> _getTxFee({bool reload = false}) async {
    if (_fee?.partialFee != null && !reload) {
      return _fee?.partialFee.toString();
    }

    final sender = TxSenderData(
        widget.keyring.current.address, widget.keyring.current.pubKey);
    final txInfo = TxInfoData('balances', 'transfer', sender);
    final fee = await widget.plugin.sdk.api.tx
        .estimateFees(txInfo, [widget.keyring.current.address, '10000000000']);
    if (mounted) {
      setState(() {
        _fee = fee;
      });
    }
    return fee.partialFee.toString();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _getTxFee();
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'common')!;
        final symbol = (widget.plugin.networkState.tokenSymbol ?? [''])[0];
        final decimals = (widget.plugin.networkState.tokenDecimals ?? [12])[0];

        final available = Fmt.balanceInt(
            (widget.plugin.balances.native?.availableBalance ?? 0).toString());

        final fund = ModalRoute.of(context)?.settings.arguments as FundData;
        final logoUri = widget.plugin.store.paras.fundsVisible[fund.paraId]
            ['logo'] as String;

        final titleStyle = Theme.of(context)
            .textTheme
            .headline3
            ?.copyWith(color: Colors.white, fontSize: 14);
        return PluginScaffold(
          appBar: PluginAppBar(title: Text('Contribute')),
          body: Container(
            margin: EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: <Widget>[
                  PluginInputItem(
                    label: 'Crowdloan',
                    child: Row(
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(8, 12, 8, 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: Container(
                              color: Colors.white,
                              child: logoUri.contains('.svg')
                                  ? SvgPicture.network(logoUri,
                                      height: 32, width: 32)
                                  : Image.network(logoUri,
                                      height: 32, width: 32),
                            ),
                          ),
                        ),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(fund.paraId, style: titleStyle),
                            Text(
                              widget.plugin.store.paras
                                  .fundsVisible[fund.paraId]['name'],
                              style:
                                  titleStyle?.copyWith(fontSize: 12, height: 1),
                            ),
                          ],
                        ))
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 16),
                    child: PluginAddressFormItem(
                      account: widget.keyring.current,
                      label: dic['from'],
                    ),
                  ),
                  Form(
                      key: _formKey,
                      child: PluginTagCard(
                        margin: EdgeInsets.only(top: 16),
                        titleTag: dic['amount'],
                        padding: EdgeInsets.only(
                            left: 16, right: 16, bottom: 24, top: 24),
                        child: TextFormField(
                          style: Theme.of(context)
                              .textTheme
                              .headline3
                              ?.copyWith(color: Colors.white, fontSize: 40),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                            hintText:
                                '${dic['balance']}: ${Fmt.priceFloorBigInt(available, decimals, lengthMax: 6)} $symbol',
                            hintStyle: Theme.of(context)
                                .textTheme
                                .headline4
                                ?.copyWith(color: Color(0xffbcbcbc)),
                            suffix: GestureDetector(
                              child: Icon(
                                CupertinoIcons.clear_thick_circled,
                                color: Color(0xFFD8D8D8),
                                size: 16,
                              ),
                              onTap: () {
                                setState(() {
                                  _amountCtrl.text = '';
                                });
                              },
                            ),
                          ),
                          inputFormatters: [
                            UI.decimalInputFormatter(decimals)!
                          ],
                          controller: _amountCtrl,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (v) {
                            final error = Fmt.validatePrice(v!, context);
                            if (error != null) {
                              return error;
                            }
                            final feeLeft =
                                available - Fmt.tokenInt(v, decimals);
                            BigInt fee = BigInt.zero;
                            if (feeLeft < Fmt.tokenInt('0.02', decimals) &&
                                _fee?.partialFee != null) {
                              fee = Fmt.balanceInt(_fee?.partialFee.toString());
                            }
                            if (feeLeft - fee < BigInt.zero) {
                              return dic['amount.low'];
                            }
                            return null;
                          },
                        ),
                      )),
                  Container(
                    margin: EdgeInsets.only(top: 160),
                    child: PluginTxButton(
                      text: 'Contribute',
                      getTxParams: _getTxParams,
                      onFinish: (res) {
                        if (res != null) {
                          Navigator.of(context).pop(res);
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
