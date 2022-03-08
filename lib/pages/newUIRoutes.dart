import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_kusama/pages/governanceNew/candidateDetailPage.dart';
import 'package:polkawallet_plugin_kusama/pages/governanceNew/councilPage.dart';
import 'package:polkawallet_plugin_kusama/pages/governanceNew/councilVotePage.dart';
import 'package:polkawallet_plugin_kusama/pages/governanceNew/governancePage.dart';
import 'package:polkawallet_plugin_kusama/pages/governanceNew/referendumVotePage.dart';
import 'package:polkawallet_plugin_kusama/pages/governanceNew/treasuryPage.dart';
import 'package:polkawallet_plugin_kusama/pages/parasNew/contributePage.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';

Map<String, WidgetBuilder> getNewUiRoutes(
    PluginKusama plugin, Keyring keyring) {
  /// use new pages in testnet for now.
  final isTest = true;
  return isTest
      ? {
          //governanceNew
          GovernancePage.route: (_) => GovernancePage(plugin, keyring),
          CouncilPage.route: (_) => CouncilPage(plugin),
          CandidateDetailPage.route: (_) =>
              CandidateDetailPage(plugin, keyring),
          ReferendumVotePage.route: (_) => ReferendumVotePage(plugin, keyring),
          CouncilVotePage.route: (_) => CouncilVotePage(plugin, keyring),
          TreasuryPage.route: (_) => TreasuryPage(plugin, keyring),

          // paras
          ContributePage.route: (_) => ContributePage(plugin, keyring),
        }
      : {};
}
