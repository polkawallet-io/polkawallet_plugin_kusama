import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_kusama/pages/governance/council/council.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/accountInfo.dart';
import 'package:polkawallet_ui/components/borderedTitle.dart';
import 'package:polkawallet_ui/components/roundedCard.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/i18n.dart';

class CandidateDetailPage extends StatefulWidget {
  CandidateDetailPage(this.plugin, this.keyring);

  final PluginKusama plugin;
  final Keyring keyring;

  static final String route = '/gov/candidate';

  @override
  _CandidateDetailPageState createState() => _CandidateDetailPageState();
}

class _CandidateDetailPageState extends State<CandidateDetailPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.plugin.store.gov.councilVotes != null) {
        final List info = ModalRoute.of(context).settings.arguments;
        final voters = widget.plugin.store.gov.councilVotes[info[0]];
        widget.plugin.service.gov.updateIconsAndIndices(voters.keys.toList());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).getDic(i18n_full_dic_kusama, 'gov');
    final List info = ModalRoute.of(context).settings.arguments;
    final decimals = widget.plugin.networkState.tokenDecimals;
    final symbol = widget.plugin.networkState.tokenSymbol;
    return Scaffold(
      appBar: AppBar(
          title: Text(
              I18n.of(context).getDic(i18n_full_dic_ui, 'common')['detail']),
          centerTitle: true),
      body: SafeArea(
        child: Observer(
          builder: (_) {
            final iconsMap = widget.plugin.store.accounts.addressIconsMap;
            final accInfo =
                widget.plugin.store.accounts.addressIndexMap[info[0]];
            TextStyle style = Theme.of(context).textTheme.headline4;

            Map voters;
            List voterList = [];
            if (widget.plugin.store.gov.councilVotes != null) {
              voters = widget.plugin.store.gov.councilVotes[info[0]];
              voterList = voters.keys.toList();
            }
            return ListView(
              children: <Widget>[
                RoundedCard(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      AccountInfo(
                        accInfo: accInfo,
                        address: info[0],
                        icon: iconsMap[info[0]],
                      ),
                      Divider(),
                      Padding(
                        padding: EdgeInsets.only(top: 8, bottom: 8),
                        child: Text(
                            '${Fmt.token(BigInt.parse(info[1].toString()), decimals)} $symbol',
                            style: style),
                      ),
                      Text(dic['backing'])
                    ],
                  ),
                ),
                voterList.length > 0
                    ? Container(
                        padding: EdgeInsets.only(top: 16, left: 16, bottom: 8),
                        color: Theme.of(context).cardColor,
                        child: BorderedTitle(
                          title: dic['vote.voter'],
                        ),
                      )
                    : Container(),
                Container(
                  color: Theme.of(context).cardColor,
                  child: Column(
                    children: voterList.map((i) {
                      return CandidateItem(
                        accInfo:
                            widget.plugin.store.accounts.addressIndexMap[i],
                        icon: iconsMap[i],
                        balance: [i, voters[i]],
                        tokenSymbol: symbol,
                        decimals: decimals,
                        noTap: true,
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
