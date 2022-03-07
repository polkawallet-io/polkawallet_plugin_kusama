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
        values.add(ls);
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

  static int sortValidatorList(
      Map addressIndexMap, ValidatorData a, ValidatorData b, int sortType) {
    if (a.commission == null || a.commission == 0) {
      return 1;
    }
    if (b.commission == null || b.commission == 0) {
      return -1;
    }
    switch (sortType) {
      case 0:
        return a.rankReward! < b.rankReward! ? 1 : -1;
      case 1:
        return a.rankBondTotal! > b.rankBondTotal! ? 1 : -1;
      case 2:
        return a.commission == b.commission
            ? a.rankReward! < b.rankReward!
                ? 1
                : -1
            : a.commission > b.commission
                ? 1
                : -1;
      case 3:
        final infoA = addressIndexMap[a.accountId];
        if (infoA != null && infoA['identity'] != null) {
          final List judgements = infoA['identity']['judgements'];
          if (judgements != null && judgements.length > 0) {
            return -1;
          }
        }
        return 1;
      default:
        return -1;
    }
  }

  static List<ValidatorData> filterValidatorList(List<ValidatorData> ls,
      List<bool> filters, String search, Map accIndexMap) {
    ls.retainWhere((i) {
      // filters[0], no 20%+ comm
      if (filters[0]) {
        if (i.commission > 20) return false;
      }

      // filters[1], only with an ID
      final Map? accInfo = accIndexMap[i.accountId];
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
          i.accountId!.toLowerCase().contains(value);
    });
    return ls;
  }

  static List<List> filterCandidateList(
      List<List> ls, String filter, Map accIndexMap) {
    ls.retainWhere((i) {
      String value = filter.trim().toLowerCase();
      String accName = '';
      Map? accInfo = accIndexMap[i[0]];
      if (accInfo != null) {
        accName = accInfo['identity']['display'] ?? '';
      }
      return i[0].toLowerCase().contains(value) ||
          accName.toLowerCase().contains(value);
    });
    return ls;
  }
}
