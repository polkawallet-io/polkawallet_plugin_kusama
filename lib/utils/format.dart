import 'package:polkawallet_plugin_chainx/store/staking/types/validatorData.dart';
import 'package:polkawallet_ui/utils/index.dart';

class PluginFmt {
  static Map formatRewardsChartData(Map chartData) {
    List<List> formatChart(String chartName, Map data) {
      List<List> values = [];
      List<String> labels = [];
      List chartValues = data[chartName]['chart'];

      chartValues.asMap().forEach((index, ls) {
        if (index == chartValues.length - 1) {
          List average = [];
          List.of(ls).asMap().forEach((i, v) {
            num avg = v - chartValues[chartValues.length - 2][i];
            average.add(avg);
          });
          values.add(average);
        } else {
          values.add(ls);
        }
      });

      List<String>.from(data[chartName]['labels']).asMap().forEach((k, v) {
        if ((k - 2) % 10 == 0) {
          labels.add(v);
        } else {
          labels.add('');
        }
      });
      return [values, labels];
    }

    List<List> rewards = formatChart('rewards', chartData);
    List<List> points = formatChart('points', chartData);
    List<List> stakes = formatChart('stakes', chartData);

    return {
      'rewards': rewards,
      'stakes': stakes,
      'points': points,
    };
  }

  static int sortValidatorList(Map addressIndexMap, ValidatorData a, ValidatorData b, int sortType) {
    switch (sortType) {
      case 0:
        return BigInt.parse(a.totalNomination) < BigInt.parse(b.totalNomination) ? 1 : -1;
      case 1:
        return BigInt.parse(a.selfBonded) < BigInt.parse(b.selfBonded) ? 1 : -1;
      case 2:
        return BigInt.parse(a.rewardPotBalance) < BigInt.parse(b.rewardPotBalance) ? 1 : -1;
      case 3:
        return 1;
      default:
        return -1;
    }
  }

  static List<ValidatorData> filterValidatorList(List<ValidatorData> ls, String filter, Map accIndexMap) {
    ls.retainWhere((i) {
      final Map accInfo = accIndexMap[i.accountId];
      final value = filter.trim().toLowerCase();
      return UI.accountDisplayNameString(i.accountId, accInfo).toLowerCase().contains(value) || i.accountId.toLowerCase().contains(value);
    });
    return ls;
  }

  static List<List> filterCandidateList(List<List> ls, String filter, Map accIndexMap) {
    ls.retainWhere((i) {
      String value = filter.trim().toLowerCase();
      String accName = '';
      Map accInfo = accIndexMap[i[0]];
      if (accInfo != null) {
        accName = accInfo['identity']['display'] ?? '';
      }
      return i[0].toLowerCase().contains(value) || accName.toLowerCase().contains(value);
    });
    return ls;
  }
}
