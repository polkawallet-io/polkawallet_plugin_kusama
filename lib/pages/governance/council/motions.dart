import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:polkawallet_plugin_kusama/pages/governance/council/motionDetailPage.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/listTail.dart';
import 'package:polkawallet_ui/components/roundedCard.dart';

class Motions extends StatefulWidget {
  Motions(this.plugin);
  final PluginKusama plugin;

  @override
  _MotionsState createState() => _MotionsState();
}

class _MotionsState extends State<Motions> {
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      new GlobalKey<RefreshIndicatorState>();

  Future<void> _fetchData() async {
    widget.plugin.service!.gov.updateBestNumber();
    await widget.plugin.service!.gov.queryCouncilMotions();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _refreshKey.currentState?.show();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_kusama, 'gov');
    return GetBuilder(
      init: widget.plugin.store?.gov,
      builder: (_) {
        return RefreshIndicator(
          onRefresh: _fetchData,
          key: _refreshKey,
          child: widget.plugin.store!.gov.councilMotions.length == 0
              ? Center(
                  child: ListTail(isEmpty: true, isLoading: false),
                )
              : ListView.builder(
                  itemCount: widget.plugin.store!.gov.councilMotions.length + 1,
                  itemBuilder: (_, int i) {
                    if (i == widget.plugin.store!.gov.councilMotions.length) {
                      return Center(
                        child: ListTail(isEmpty: false, isLoading: false),
                      );
                    }
                    final e = widget.plugin.store!.gov.councilMotions[i];
                    return RoundedCard(
                      margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                      padding: EdgeInsets.only(top: 16, bottom: 16),
                      child: ListTile(
                        title: Text(
                            '#${e.votes!.index} ${e.proposal!.section}.${e.proposal!.method}'),
                        subtitle: Text(e.proposal!.meta!.documentation!.trim()),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              '${e.votes!.ayes!.length}/${e.votes!.threshold}',
                              style: Theme.of(context).textTheme.headline4,
                            ),
                            Text(dic!['yes']!),
                          ],
                        ),
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(MotionDetailPage.route, arguments: e);
                        },
                      ),
                    );
                  }),
        );
      },
    );
  }
}
