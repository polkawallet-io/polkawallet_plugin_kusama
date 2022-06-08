import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/validators/validatorChartsPage.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/store/staking/types/validatorData.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/accountInfo.dart';
import 'package:polkawallet_ui/components/v3/addressIcon.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginInfoItem.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginScaffold.dart';
import 'package:polkawallet_ui/components/v3/plugin/roundedPluginCard.dart';
import 'package:polkawallet_ui/utils/consts.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/index.dart';

class ValidatorDetailPage extends StatelessWidget {
  ValidatorDetailPage(this.plugin, this.keyring);
  static final String route = '/staking/validator';

  final PluginKusama plugin;
  final Keyring keyring;

  @override
  Widget build(BuildContext context) {
    final dicStaking =
        I18n.of(context)!.getDic(i18n_full_dic_kusama, 'staking')!;
    final ValidatorData detail =
        ModalRoute.of(context)!.settings.arguments as ValidatorData;
    return Observer(
      builder: (_) {
        final int decimals = plugin.networkState.tokenDecimals![0];

        final accInfo = plugin.store.accounts.addressIndexMap[detail.accountId];
        final accIcon = plugin.store.accounts.addressIconsMap[detail.accountId];

        final int nominatorsCount = detail.isElected!
            ? detail.nominators.length
            : plugin.store.staking.nominationsCount![detail.accountId] ?? 0;

        final maxNomPerValidator = int.parse(plugin.networkConst['staking']
                ['maxNominatorRewardedPerValidator']
            .toString());

        return PluginScaffold(
          appBar: PluginAppBar(
              title: Text(dicStaking['validator']!), centerTitle: true),
          body: SafeArea(
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (_, i) {
                if (i == 0) {
                  return RoundedPluginCard(
                    borderRadius:
                        const BorderRadius.all(const Radius.circular(14)),
                    margin: EdgeInsets.all(16),
                    child: Column(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0x0FFFFFFF),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(14),
                                topRight: Radius.circular(14)),
                          ),
                          child: Column(
                            children: [
                              Container(height: 16),
                              Visibility(
                                  visible: detail.isBlocking!,
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 16),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(right: 4),
                                          child: Image.asset(
                                            'packages/polkawallet_plugin_kusama/assets/images/staking/icon_block_nom.png',
                                            width: 16,
                                          ),
                                        ),
                                        Text(
                                          dicStaking['blocking']!,
                                          style: TextStyle(color: Colors.white),
                                        )
                                      ],
                                    ),
                                  )),
                              Visibility(
                                  visible:
                                      nominatorsCount >= maxNomPerValidator,
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 16),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(right: 4),
                                          child: Image.asset(
                                            'packages/polkawallet_plugin_kusama/assets/images/staking/icon_over_sub.png',
                                            width: 16,
                                          ),
                                        ),
                                        Text(
                                          dicStaking['oversubscribe']!,
                                          style: TextStyle(color: Colors.white),
                                        )
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                        AccountInfo(
                          network: plugin.basic.name,
                          accInfo: accInfo,
                          address: detail.accountId,
                          icon: accIcon,
                          isPlugin: true,
                          charts: GestureDetector(
                            onTap: () => Navigator.of(context).pushNamed(
                                ValidatorChartsPage.route,
                                arguments: detail),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  dicStaking['validator.chart']!,
                                  style: TextStyle(
                                      color: PluginColorsDark.primary,
                                      fontSize: 14),
                                ),
                                Padding(
                                    padding: EdgeInsets.only(left: 2),
                                    child: Icon(
                                      Icons.insert_chart_outlined,
                                      color: PluginColorsDark.primary,
                                      size: 15,
                                    )),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0x0FFFFFFF),
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(14),
                                bottomRight: Radius.circular(14)),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 8, left: 24),
                                child: Row(
                                  children: <Widget>[
                                    PluginInfoItem(
                                      title: dicStaking['stake.own'],
                                      content:
                                          Fmt.token(detail.bondOwn, decimals),
                                      contentCrossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      titleStyle: Theme.of(context)
                                          .textTheme
                                          .headline5
                                          ?.copyWith(color: Colors.white),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline1
                                          ?.copyWith(
                                              fontSize: 22,
                                              color: Colors.white),
                                    ),
                                    PluginInfoItem(
                                      title: dicStaking['stake.other'],
                                      content:
                                          Fmt.token(detail.bondOther, decimals),
                                      contentCrossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      titleStyle: Theme.of(context)
                                          .textTheme
                                          .headline5
                                          ?.copyWith(color: Colors.white),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline1
                                          ?.copyWith(
                                              fontSize: 22,
                                              color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 8, left: 24, bottom: 8),
                                child: Row(
                                  children: <Widget>[
                                    PluginInfoItem(
                                      title: dicStaking['commission'],
                                      content: NumberFormat('0.00%')
                                          .format(detail.commission / 100),
                                      contentCrossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      titleStyle: Theme.of(context)
                                          .textTheme
                                          .headline5
                                          ?.copyWith(color: Colors.white),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline1
                                          ?.copyWith(
                                              fontSize: 22,
                                              color: Colors.white),
                                    ),
                                    PluginInfoItem(
                                      title: dicStaking['reward'],
                                      content:
                                          '${detail.stakedReturnCmp.toStringAsFixed(2)}%',
                                      contentCrossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      titleStyle: Theme.of(context)
                                          .textTheme
                                          .headline5
                                          ?.copyWith(color: Colors.white),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline1
                                          ?.copyWith(
                                              fontSize: 22,
                                              color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                }
                if (i == 1) {
                  if (nominatorsCount == 0) return Container();

                  final addresses = detail.isElected!
                      ? detail.nominators.map((e) => e['who']).toList()
                      : [];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 16, top: 16),
                        child: Text(
                          dicStaking['nominators']!,
                          style: Theme.of(context)
                              .textTheme
                              .headline3
                              ?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                        ),
                      ),
                      FutureBuilder(
                          future: plugin.service.gov
                              .updateIconsAndIndices(addresses),
                          builder: (_, __) => Container()),
                    ],
                  );
                }
                if (detail.isElected!) {
                  return RoundedPluginCard(
                      margin: EdgeInsets.all(16),
                      borderRadius:
                          const BorderRadius.all(const Radius.circular(16)),
                      child: ListView.separated(
                          separatorBuilder: (context, index) => Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Divider(),
                              ),
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: detail.nominators.length,
                          itemBuilder: (context, index) {
                            final item = detail.nominators[index];
                            return ListTile(
                              dense: true,
                              leading: AddressIcon(item['who'],
                                  size: 32,
                                  svg: plugin.store.accounts
                                      .addressIconsMap[item['who']]),
                              title: UI.accountDisplayName(
                                  item['who'],
                                  plugin.store.accounts
                                      .addressIndexMap[item['who']],
                                  textColor: Colors.white),
                              trailing: Text(
                                '${Fmt.balance(item['value'].toString(), plugin.networkState.tokenDecimals![0])} ${plugin.networkState.tokenSymbol![0]}',
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          }));
                }
                return Container();
              },
            ),
          ),
        );
      },
    );
  }
}
