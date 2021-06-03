import 'package:polkawallet_plugin_kusama/store/staking/types/validatorData.dart';
import 'package:polkawallet_ui/utils/index.dart';

class PluginFmt {
  static Map formatRewardsChartData(Map chartData) {
    List<List> formatChart(List chartValues) {
      List<List> values = [];

      chartValues.asMap().forEach((index, ls) {
        if (ls[0].toString().contains('0x')) {
          ls = List.of(ls).map((e) => int.parse(e.toString())).toList();
        }
        if (index == chartValues.length - 1) {
          List average = [];
          List.of(ls).asMap().forEach((i, v) {
            final avg = v - values[values.length - 1][i];
            average.add(avg);
          });
          values.add(average);
        } else {
          values.add(ls);
        }
      });

      return values;
    }

    final List<String> labels = [];
    List<String>.from(chartData['rewards']['labels']).asMap().forEach((k, v) {
      if ((k - 2) % 10 == 0) {
        labels.add(v);
      } else {
        labels.add('');
      }
    });

    List rewards = formatChart(List.of(chartData['rewards']['chart']));
    List points = formatChart(List.of(chartData['points']['chart']));
    List stakes = formatChart(List.of(chartData['stakes']['chart']));
    return {
      'rewards': [rewards, labels],
      'stakes': [stakes, labels],
      'points': [points, labels],
    };
  }

  static List<ValidatorData> filterValidatorList(List<ValidatorData> ls,
      List<bool> filters, String search, Map accIndexMap) {
    ls.retainWhere((i) {
      // filters[0], no 20%+ comm
      if (filters[0]) {
        if (i.commission > 20) return false;
      }

      // filters[1], only with an ID
      final Map accInfo = accIndexMap[i.accountId];
      if (filters[1]) {
        if (accInfo == null || accInfo['identity']['display'] == null) {
          return false;
        }
      }

      // filter by search input
      final value = search.trim().toLowerCase();
      return UI
              .accountDisplayNameString(i.accountId, accInfo)
              .toLowerCase()
              .contains(value) ||
          i.accountId.toLowerCase().contains(value);
    });
    return ls;
  }

  static List<List> filterCandidateList(
      List<List> ls, String filter, Map accIndexMap) {
    ls.retainWhere((i) {
      String value = filter.trim().toLowerCase();
      String accName = '';
      Map accInfo = accIndexMap[i[0]];
      if (accInfo != null) {
        accName = accInfo['identity']['display'] ?? '';
      }
      return i[0].toLowerCase().contains(value) ||
          accName.toLowerCase().contains(value);
    });
    return ls;
  }
}
