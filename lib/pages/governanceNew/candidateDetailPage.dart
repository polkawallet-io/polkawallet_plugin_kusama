import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_kusama/pages/governanceNew/councilPage.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/accountInfo.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginScaffold.dart';
import 'package:polkawallet_ui/components/v3/plugin/roundedPluginCard.dart';
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
        final List info =
            ModalRoute.of(context)!.settings.arguments as List<dynamic>;
        final voters = widget.plugin.store.gov.councilVotes![info[0]]!;
        widget.plugin.service.gov.updateIconsAndIndices(voters.keys.toList());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov')!;
    final List? info =
        ModalRoute.of(context)!.settings.arguments as List<dynamic>?;
    final decimals = widget.plugin.networkState.tokenDecimals![0];
    final symbol = widget.plugin.networkState.tokenSymbol![0];
    return PluginScaffold(
      appBar: PluginAppBar(
          title: Text(
              I18n.of(context)!.getDic(i18n_full_dic_ui, 'common')!['detail']!),
          centerTitle: true),
      body: SafeArea(
        child: Observer(
          builder: (_) {
            final iconsMap = widget.plugin.store.accounts.addressIconsMap;
            final accInfo =
                widget.plugin.store.accounts.addressIndexMap[info![0]];
            TextStyle? style = Theme.of(context)
                .textTheme
                .headline4
                ?.copyWith(color: Colors.white);

            Map? voters;
            List voterList = [];
            if (widget.plugin.store.gov.councilVotes != null &&
                widget.plugin.store.gov.councilVotes!.length > 0) {
              voters = widget.plugin.store.gov.councilVotes![info[0]];
              voterList = voters!.keys.toList();
            }
            return ListView(
              children: <Widget>[
                RoundedPluginCard(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      AccountInfo(
                        network: widget.plugin.basic.name,
                        accInfo: accInfo,
                        address: info[0],
                        icon: iconsMap[info[0]],
                        isPlugin: true,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 8, bottom: 8),
                        child: Text(
                            '${Fmt.token(BigInt.parse(info[1].toString()), decimals)} $symbol',
                            style: style),
                      ),
                      Text(
                        dic['backing'],
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                ),
                Visibility(
                    visible: voterList.length > 0,
                    child: Padding(
                      padding: EdgeInsets.only(left: 16, top: 16),
                      child: Text(
                        dic['vote.voter'],
                        style: Theme.of(context).textTheme.headline3?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    )),
                Container(
                  color: Color(0xFFFFFFFF).withAlpha(25),
                  child: Column(
                    children: voterList.map((i) {
                      return CandidateItem(
                        accInfo:
                            widget.plugin.store.accounts.addressIndexMap[i],
                        icon: iconsMap[i],
                        balance: [i, voters![i]],
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
