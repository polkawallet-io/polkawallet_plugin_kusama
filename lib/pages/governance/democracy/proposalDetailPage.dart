import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_kusama/pages/governance/council/motionDetailPage.dart';
import 'package:polkawallet_plugin_kusama/pages/governance/govExternalLinks.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/store/accounts.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/api/types/gov/genExternalLinksParams.dart';
import 'package:polkawallet_sdk/api/types/gov/proposalInfoData.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/addressIcon.dart';
import 'package:polkawallet_ui/components/borderedTitle.dart';
import 'package:polkawallet_ui/components/roundedCard.dart';
import 'package:polkawallet_ui/components/txButton.dart';
import 'package:polkawallet_ui/pages/txConfirmPage.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/index.dart';

class ProposalDetailPage extends StatefulWidget {
  ProposalDetailPage(this.plugin, this.keyring);
  final PluginKusama plugin;
  final Keyring keyring;

  static const String route = '/gov/democracy/proposal';

  @override
  _ProposalDetailPageState createState() => _ProposalDetailPageState();
}

class _ProposalDetailPageState extends State<ProposalDetailPage> {
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      new GlobalKey<RefreshIndicatorState>();

  List? _links;

  Future<List?> _getExternalLinks(BigInt id) async {
    if (_links != null) return _links;

    final List? res = await widget.plugin.sdk.api.gov.getExternalLinks(
      GenExternalLinksParams.fromJson(
          {'data': id.toString(), 'type': 'proposal'}),
    );
    if (res != null) {
      setState(() {
        _links = res;
      });
    }
    return res;
  }

  Future<void> _fetchData() async {
    await widget.plugin.service!.gov.queryProposals();
  }

  Future<void> _onSwitch() async {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov')!;
    final ProposalInfoData proposal =
        ModalRoute.of(context)!.settings.arguments as ProposalInfoData;
    final TxConfirmParams params = TxConfirmParams(
      module: 'democracy',
      call: 'second',
      txTitle: dic['proposal.second'],
      txDisplay: {
        "proposal": BigInt.parse(proposal.index.toString()).toInt(),
        "seconds": proposal.seconds!.length,
      },
      params: [
        BigInt.parse(proposal.index.toString()).toInt(),
        proposal.seconds!.length,
      ],
    );

    final res = await Navigator.of(context)
        .pushNamed(TxConfirmPage.route, arguments: params);
    if (res as bool? ?? false) {
      _refreshKey.currentState!.show();
    }
  }

  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov')!;
    final ProposalInfoData proposalPara =
        ModalRoute.of(context)!.settings.arguments as ProposalInfoData;
    return Scaffold(
      appBar: AppBar(
          title: Text(
              '${dic['proposal']} #${BigInt.parse(proposalPara.index.toString())}'),
          centerTitle: true),
      body: SafeArea(
        child: RefreshIndicator(
          key: _refreshKey,
          onRefresh: _fetchData,
          child: Observer(
            builder: (_) {
              final ProposalInfoData proposal = widget
                  .plugin.store!.gov.proposals
                  .firstWhere((e) => e.index == proposalPara.index);
              final decimals = widget.plugin.networkState.tokenDecimals![0];
              final symbol = widget.plugin.networkState.tokenSymbol![0];
              final List<List<String>> params = [];
              bool hasProposal = false;
              if (proposal.image?.proposal != null) {
                proposal.image!.proposal!.meta!.args!.asMap().forEach((k, v) {
                  params.add([
                    '${v.name}: ${v.type}',
                    proposal.image!.proposal!.args![k].toString()
                  ]);
                });
                hasProposal = true;
              }
              final bool isSecondOn =
                  proposal.seconds!.indexOf(widget.keyring.current.address!) >=
                      0;
              return ListView(
                children: <Widget>[
                  RoundedCard(
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        hasProposal
                            ? Text(
                                '${proposal.image!.proposal!.section}.${proposal.image!.proposal!.method}',
                                style: Theme.of(context).textTheme.headline4,
                              )
                            : Container(),
                        hasProposal
                            ? Text(proposal
                                .image!.proposal!.meta!.documentation!
                                .trim())
                            : Container(),
                        hasProposal ? Divider(height: 24) : Container(),
                        Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: ProposalArgsItem(
                            label: Text('Hash'),
                            content: Text(
                              Fmt.address(proposal.imageHash, pad: 10)!,
                              style: Theme.of(context).textTheme.headline4,
                            ),
                            margin: EdgeInsets.all(0),
                          ),
                        ),
                        params.length > 0
                            ? Text(
                                dic['proposal.params']!,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .unselectedWidgetColor),
                              )
                            : Container(),
                        params.length > 0
                            ? ProposalArgsList(params)
                            : Container(),
                        Text(
                          dic['treasury.proposer']!,
                          style: TextStyle(
                              color: Theme.of(context).unselectedWidgetColor),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.all(0),
                          leading: AddressIcon(
                            proposal.proposer,
                            svg: widget.plugin.store!.accounts
                                .addressIconsMap[proposal.proposer],
                          ),
                          title: UI.accountDisplayName(
                              proposal.proposer,
                              widget.plugin.store!.accounts
                                  .addressIndexMap[proposal.proposer]),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 8, bottom: 8),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  dic['treasury.bond']!,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .unselectedWidgetColor),
                                ),
                              ),
                              Text(
                                '${Fmt.balance(proposal.balance.toString(), decimals)} $symbol',
                                style: Theme.of(context).textTheme.headline4,
                              )
                            ],
                          ),
                        ),
                        FutureBuilder(
                          future: _getExternalLinks(
                              BigInt.parse(proposalPara.index.toString())),
                          builder: (_, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              return GovExternalLinks(snapshot.data);
                            }
                            return Container();
                          },
                        ),
                        Divider(height: 24),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                dic['proposal.second']!,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .unselectedWidgetColor),
                              ),
                            ),
                            CupertinoSwitch(
                              value: isSecondOn,
                              onChanged: (res) {
                                if (res) {
                                  _onSwitch();
                                }
                              },
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  ProposalSecondsList(
                      store: widget.plugin.store!.accounts, proposal: proposal),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class ProposalSecondsList extends StatelessWidget {
  ProposalSecondsList({this.store, this.proposal});

  final AccountsStore? store;
  final ProposalInfoData? proposal;

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov')!;
    final List seconding = proposal!.seconds!.toList();
    seconding.removeAt(0);
    return Container(
      padding: EdgeInsets.only(bottom: 24),
      margin: EdgeInsets.only(top: 8),
      color: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16),
            child: BorderedTitle(
                title: '${dic['proposal.seconds']}(${seconding.length})'),
          ),
          Column(
            children: seconding.map((e) {
              final Map? accInfo = store!.addressIndexMap[e];
              return ListTile(
                leading: AddressIcon(e, svg: store!.addressIconsMap[e]),
                title: UI.accountDisplayName(e, accInfo),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
