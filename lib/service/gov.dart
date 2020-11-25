import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/store/index.dart';
import 'package:polkawallet_sdk/api/api.dart';
import 'package:polkawallet_sdk/api/types/gov/treasuryOverviewData.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';

class ApiGov {
  ApiGov(this.plugin, this.keyring)
      : api = plugin.sdk.api,
        store = plugin.store;

  final PluginKusama plugin;
  final Keyring keyring;
  final PolkawalletApi api;
  final PluginStore store;

  Future<void> subscribeBestNumber() async {
    api.setting.subscribeBestNumber((int bestNum) {
      store.gov.setBestNumber(bestNum);
    });
  }

  Future<void> unsubscribeBestNumber() async {
    api.setting.unsubscribeBestNumber();
  }

  Future<void> updateBestNumber() async {
    final int bestNumber = await api.service.webView
        .evalJavascript('api.derive.chain.bestNumber()');
    store.gov.setBestNumber(bestNumber);
  }

  Future<List> getReferendumVoteConvictions() async {
    final List res = await api.gov.getReferendumVoteConvictions();
    store.gov.setReferendumVoteConvictions(res);
    return res;
  }

  Future<List> queryReferendums() async {
    final List data = await api.gov.queryReferendums(keyring.current.address);
    store.gov.setReferendums(data);
    return data;
  }

  Future<List> queryProposals() async {
    final data = await api.gov.queryProposals();
    store.gov.setProposals(data);
    final List<String> addresses = [];
    data.forEach((e) {
      addresses.add(e.proposer);
      addresses.addAll(e.seconds);
    });
    final icons = await api.account.getAddressIcons(addresses);
    store.accounts.setAddressIconsMap(icons);
    final indexes = await api.account.queryIndexInfo(addresses);
    store.accounts.setAddressIndex(indexes);
    return data;
  }

  Future<Map> queryCouncilVotes() async {
    final Map votes = await api.gov.queryCouncilVotes();
    store.gov.setCouncilVotes(votes);
    return votes;
  }

  Future<Map> queryUserCouncilVote() async {
    final Map votes =
        await api.gov.queryUserCouncilVote(keyring.current.address);
    store.gov.setUserCouncilVotes(votes);
    return votes;
  }

  Future<Map> queryCouncilInfo() async {
    Map info = await api.gov.queryCouncilInfo();
    if (info != null) {
      List all = [];
      all.addAll(info['members'].map((i) => i[0]));
      all.addAll(info['runnersUp'].map((i) => i[0]));
      all.addAll(info['candidates']);
      store.gov.setCouncilInfo(info);
      final indexes = await api.account.queryIndexInfo(all);
      store.accounts.setAddressIndex(indexes);
      final icons = await api.account.getAddressIcons(all);
      store.accounts.setAddressIconsMap(icons);
    }
    return info;
  }

  Future<List<CouncilMotionData>> queryCouncilMotions() async {
    final data = await api.gov.queryCouncilMotions();
    store.gov.setCouncilMotions(data);
    return data;
  }
}
