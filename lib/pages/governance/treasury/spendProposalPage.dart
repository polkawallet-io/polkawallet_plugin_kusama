import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_kusama/pages/governance/council/motionDetailPage.dart';
import 'package:polkawallet_plugin_kusama/pages/governance/govExternalLinks.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/api/types/gov/genExternalLinksParams.dart';
import 'package:polkawallet_sdk/api/types/gov/treasuryOverviewData.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/addressIcon.dart';
import 'package:polkawallet_ui/components/borderedTitle.dart';
import 'package:polkawallet_ui/components/infoItem.dart';
import 'package:polkawallet_ui/components/roundedButton.dart';
import 'package:polkawallet_ui/components/roundedCard.dart';
import 'package:polkawallet_ui/components/txButton.dart';
import 'package:polkawallet_ui/pages/txConfirmPage.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/i18n.dart';
import 'package:polkawallet_ui/utils/index.dart';

class SpendProposalPage extends StatefulWidget {
  SpendProposalPage(this.plugin, this.keyring);
  final PluginKusama plugin;
  final Keyring keyring;

  static const String route = '/gov/treasury/proposal';

  @override
  _SpendProposalPageState createState() => _SpendProposalPageState();
}

class _SpendProposalPageState extends State<SpendProposalPage> {
  List? _links;

  Future<List?> _getExternalLinks(int id) async {
    if (_links != null) return _links;

    final List? res = await widget.plugin.sdk.api.gov.getExternalLinks(
      GenExternalLinksParams.fromJson(
          {'data': id.toString(), 'type': 'treasury'}),
    );
    if (res != null) {
      setState(() {
        _links = res;
      });
    }
    return res;
  }

  Future<void> _showActions({bool isVote = false}) async {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov');
    final SpendProposalData? proposal =
        ModalRoute.of(context)!.settings.arguments as SpendProposalData?;
    CouncilProposalData? proposalData = CouncilProposalData();
    if (isVote) {
      proposalData = proposal!.council![0].proposal;
    }
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(isVote ? dic!['treasury.vote']! : dic!['treasury.send']!),
        message: isVote
            ? Text('${proposalData!.section}.${proposalData.method}()')
            : null,
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(isVote ? dic['yes.text']! : dic['treasury.approve']!),
            onPressed: () {
              Navigator.of(context).pop();
              if (isVote) {
                _onVote(true);
              } else {
                _onSendToCouncil(true);
              }
            },
          ),
          CupertinoActionSheetAction(
            child: Text(isVote ? dic['no.text']! : dic['treasury.reject']!),
            onPressed: () {
              Navigator.of(context).pop();
              if (isVote) {
                _onVote(false);
              } else {
                _onSendToCouncil(false);
              }
            },
          )
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(
              I18n.of(context)!.getDic(i18n_full_dic_ui, 'common')!['cancel']!),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Future<void> _onSendToCouncil(bool approve) async {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov');
    final SpendProposalData proposal =
        ModalRoute.of(context)!.settings.arguments as SpendProposalData;
    final String txName =
        'treasury.${approve ? 'approveProposal' : 'rejectProposal'}';
    final args = TxConfirmParams(
      module: 'council',
      call: 'propose',
      txTitle: approve ? dic!['treasury.approve'] : dic!['treasury.reject'],
      txDisplay: {"proposal": txName, "proposal_id": proposal.id},
      params: [proposal.id],
      txName: txName,
    );
    final res = await Navigator.of(context)
        .pushNamed(TxConfirmPage.route, arguments: args);
    if (res != null) {
      Navigator.of(context).pop(res);
    }
  }

  Future<void> _onVote(bool approve) async {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov')!;
    final SpendProposalData proposal =
        ModalRoute.of(context)!.settings.arguments as SpendProposalData;
    final CouncilMotionData councilProposal = proposal.council![0];
    final args = TxConfirmParams(
      module: 'council',
      call: 'vote',
      txTitle: dic['treasury.vote'],
      txDisplay: {
        "councilHash": councilProposal.hash,
        "councilId": councilProposal.votes!.index,
        "voteValue": approve,
      },
      params: [
        councilProposal.hash,
        councilProposal.votes!.index,
        approve,
      ],
    );
    final res = await Navigator.of(context)
        .pushNamed(TxConfirmPage.route, arguments: args);
    if (res != null) {
      Navigator.of(context).pop(res);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov')!;
    final symbol = widget.plugin.networkState.tokenSymbol![0];
    final decimals = widget.plugin.networkState.tokenDecimals![0];
    final SpendProposalData proposal =
        ModalRoute.of(context)!.settings.arguments as SpendProposalData;
    final proposer = KeyPairData();
    final beneficiary = KeyPairData();
    proposer.address = proposal.proposal!.proposer;
    beneficiary.address = proposal.proposal!.beneficiary;
    final Map? accInfoProposer =
        widget.plugin.store!.accounts.addressIndexMap[proposer.address];
    final Map? accInfoBeneficiary =
        widget.plugin.store!.accounts.addressIndexMap[beneficiary.address];
    bool isCouncil = false;
    widget.plugin.store!.gov.council.members!.forEach((e) {
      if (widget.keyring.current.address == e[0]) {
        isCouncil = true;
      }
    });
    final bool isApproval = proposal.isApproval ?? false;
    final bool hasProposals = proposal.council!.length > 0;
    bool isVotedYes = false;
    bool isVotedNo = false;
    if (hasProposals) {
      proposal.council![0].votes!.ayes!.forEach((e) {
        if (e == widget.keyring.current.address) {
          isVotedYes = true;
        }
      });
      proposal.council![0].votes!.nays!.forEach((e) {
        if (e == widget.keyring.current.address) {
          isVotedNo = true;
        }
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('${dic['treasury.proposal']} #${int.parse(proposal.id!)}'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            RoundedCard(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.fromLTRB(0, 24, 0, 8),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: <Widget>[
                        InfoItem(
                          title: dic['treasury.value'],
                          content: '${Fmt.balance(
                            proposal.proposal!.value.toString(),
                            decimals,
                          )} $symbol',
                          crossAxisAlignment: CrossAxisAlignment.center,
                        ),
                        InfoItem(
                          title: dic['treasury.bond'],
                          content: '${Fmt.balance(
                            proposal.proposal!.bond.toString(),
                            decimals,
                          )} $symbol',
                          crossAxisAlignment: CrossAxisAlignment.center,
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: AddressIcon(
                      proposer.address,
                      svg: widget.plugin.store!.accounts
                          .addressIconsMap[proposer.address],
                    ),
                    title: UI.accountDisplayName(
                        proposer.address, accInfoProposer),
                    subtitle: Text(dic['treasury.proposer']!),
                  ),
                  ListTile(
                    leading: AddressIcon(
                      beneficiary.address,
                      svg: widget.plugin.store!.accounts
                          .addressIconsMap[beneficiary.address],
                    ),
                    title: UI.accountDisplayName(
                        beneficiary.address, accInfoBeneficiary),
                    subtitle: Text(dic['treasury.beneficiary']!),
                  ),
                  Visibility(
                      visible: hasProposals,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: ProposalArgsItem(
                          label: Text(dic['proposal']!),
                          content: Text(
                            hasProposals
                                ? '${proposal.council![0].proposal!.section}.${proposal.council![0].proposal!.method}'
                                : "",
                            style: Theme.of(context).textTheme.headline4,
                          ),
                          margin: EdgeInsets.only(left: 16, right: 16),
                        ),
                      )),
                  FutureBuilder(
                    future: _getExternalLinks(int.parse(proposal.id!)),
                    builder: (_, AsyncSnapshot<List?> snapshot) {
                      if (snapshot.hasData) {
                        return GovExternalLinks(snapshot.data);
                      }
                      return Container();
                    },
                  ),
                  Visibility(
                      visible: !isApproval,
                      child: Padding(
                        padding: EdgeInsets.only(left: 16, right: 16),
                        child: Divider(),
                      )),
                  Visibility(
                      visible: !isApproval,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: !hasProposals
                            ? RoundedButton(
                                text: dic['treasury.send'],
                                onPressed:
                                    isCouncil ? () => _showActions() : null,
                              )
                            : ProposalVoteButtonsRow(
                                isCouncil: isCouncil,
                                isVotedNo: isVotedNo,
                                isVotedYes: isVotedYes,
                                onVote: _onVote,
                              ),
                      )),
                ],
              ),
            ),
            Visibility(
                visible: hasProposals,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: BorderedTitle(title: dic['vote.voter']),
                )),
            Visibility(
                visible: hasProposals,
                child: ProposalVotingList(
                  plugin: widget.plugin,
                  council: hasProposals ? proposal.council![0] : null,
                ))
          ],
        ),
      ),
    );
  }
}
