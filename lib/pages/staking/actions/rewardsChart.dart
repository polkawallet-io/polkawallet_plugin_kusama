import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';

class RewardsChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool? animate;

  RewardsChart(this.seriesList, {this.animate});

  factory RewardsChart.withData(List<TimeSeriesAmount> data,
      {bool animate = true}) {
    return new RewardsChart(
      _formatData(data),
      animate: animate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.TimeSeriesChart(
      seriesList as List<Series<dynamic, DateTime>>,
      animate: animate,
      dateTimeFactory: const charts.LocalDateTimeFactory(),
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<TimeSeriesAmount, DateTime>> _formatData(
      List<TimeSeriesAmount> data) {
    return [
      new charts.Series<TimeSeriesAmount, DateTime>(
        id: 'Rewards',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeriesAmount data, _) => data.time,
        measureFn: (TimeSeriesAmount data, _) => data.amount,
        data: data,
      )
    ];
  }
}

class TimeSeriesAmount {
  final DateTime time;
  final double amount;

  TimeSeriesAmount(this.time, this.amount);
}
