import 'package:polkawallet_plugin_kusama/store/staking/types/validatorData.dart';
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

  static int sortValidatorList(
      Map addressIndexMap, ValidatorData a, ValidatorData b, int sortType) {
    if (a.commission == null || a.commission.isEmpty) {
      return 1;
    }
    if (b.commission == null || b.commission.isEmpty) {
      return -1;
    }
    double comA = double.parse(a.commission.split('%')[0]);
    double comB = double.parse(b.commission.split('%')[0]);
    var cmpStake = a.total < b.total ? 1 : -1;
    switch (sortType) {
      case 0:
        return a.total != b.total
            ? cmpStake
            : comA > comB
                ? 1
                : -1;
      case 1:
        return a.points == b.points
            ? cmpStake
            : a.points < b.points
                ? 1
                : -1;
      case 2:
        return comA == comB
            ? cmpStake
            : comA > comB
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

  static List<ValidatorData> filterValidatorList(
      List<ValidatorData> ls, String filter, Map accIndexMap) {
    ls.retainWhere((i) {
      final Map accInfo = accIndexMap[i.accountId];
      final value = filter.trim().toLowerCase();
      return UI
              .accountDisplayNameString(i.accountId, accInfo)
              .toLowerCase()
              .contains(value) ||
          i.accountId.toLowerCase().contains(value);
    });
    return ls;
  }
}
