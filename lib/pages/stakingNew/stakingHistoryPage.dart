import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/actions/stakingDetailPage.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/api/subscan.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/TransferIcon.dart';
import 'package:polkawallet_ui/components/listTail.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginScaffold.dart';
import 'package:polkawallet_ui/utils/format.dart';

class StakingHistoryPage extends StatefulWidget {
  StakingHistoryPage(this.plugin, {Key? key}) : super(key: key);

  final PluginKusama plugin;

  static final String route = '/staking/txs';

  @override
  State<StakingHistoryPage> createState() => _StakingHistoryPageState();
}

class _StakingHistoryPageState extends State<StakingHistoryPage> {
  bool _loading = false;
  int _txsPage = 1;
  bool _isLastPage = false;
  ScrollController? _scrollController;

  int tx_list_page_size = 15;

  Future<void> _updateStakingTxs({int? page}) async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _txsPage = page ?? _txsPage;
    });
    Map res = await widget.plugin.service.staking
        .updateStakingTxs(page ?? _txsPage, size: tx_list_page_size);
    if (mounted) {
      setState(() {
        _loading = false;
        _txsPage += 1;
      });

      // ignore: unnecessary_null_comparison
      if (res == null ||
          res['extrinsics'] == null ||
          res['extrinsics'].length < tx_list_page_size) {
        setState(() {
          _isLastPage = true;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController!.addListener(() {
      if (_scrollController!.position.pixels >=
          _scrollController!.position.maxScrollExtent) {
        if (!_isLastPage) {
          _updateStakingTxs();
        }
      }
    });

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (widget.plugin.store.staking.txs.length < tx_list_page_size) {
        _updateStakingTxs(page: 0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'staking')!;
    final dicCommon = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'common')!;
    return PluginScaffold(
        appBar: PluginAppBar(
          title: Text(dic['txs']!),
          centerTitle: true,
        ),
        body: Observer(builder: (_) {
          return ListView.builder(
            physics: BouncingScrollPhysics(),
            controller: _scrollController,
            itemCount: widget.plugin.store.staking.txs.length + 1,
            itemBuilder: (context, index) {
              if (index >= widget.plugin.store.staking.txs.length) {
                return ListTail(
                  isLoading: widget.plugin.store.staking.txsLoading,
                  isEmpty: widget.plugin.store.staking.txs.length == 0,
                  color: Colors.white,
                );
              }
              final i = widget.plugin.store.staking.txs[index];
              return Container(
                decoration: BoxDecoration(
                  color: Color(0x14ffffff),
                  border: Border(
                      bottom: BorderSide(width: 0.5, color: Color(0x24ffffff))),
                ),
                child: ListTile(
                  dense: true,
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: i.success! ? Colors.white : Color(0xFFFF7849),
                          width: 1.5),
                      borderRadius:
                          const BorderRadius.all(const Radius.circular(8)),
                      color: Colors.transparent,
                    ),
                    child: SvgPicture.asset(
                      'packages/polkawallet_plugin_kusama/assets/images/staking/${i.success! ? 'icon_success' : 'icon_failed'}.svg',
                      color: i.success! ? Colors.white : Color(0xFFFF7849),
                    ),
                  ),
                  title: Text(i.call!,
                      style: Theme.of(context).textTheme.headline5?.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                  subtitle: Text(
                      Fmt.dateTime(DateTime.fromMillisecondsSinceEpoch(
                          i.blockTimestamp! * 1000)),
                      style: Theme.of(context)
                          .textTheme
                          .headline5
                          ?.copyWith(color: Colors.white, fontSize: 10)),
                  trailing: i.success!
                      ? Text(
                          dicCommon['success']!,
                          style: Theme.of(context)
                              .textTheme
                              .headline4
                              ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                        )
                      : Text(
                          dicCommon['failed']!,
                          style: Theme.of(context)
                              .textTheme
                              .headline4
                              ?.copyWith(
                                  color: Color(0xFFFF7849),
                                  fontWeight: FontWeight.w600),
                        ),
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed(StakingDetailPage.route, arguments: i);
                  },
                ),
              );
            },
          );
        }));
  }
}
