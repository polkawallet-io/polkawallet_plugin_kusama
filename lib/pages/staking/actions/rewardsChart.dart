import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RewardsChart extends StatelessWidget {
  final List<FlSpot> seriesList;
  final bool? animate;
  final double maxY, minY;
  final DateTime? maxX, minX;
  static int xBase = 10, yBase = 1000000;
  RewardsChart(this.seriesList, this.maxX, this.maxY, this.minX, this.minY,
      {this.animate});

  factory RewardsChart.withData(List<TimeSeriesAmount> data,
      {bool animate = true}) {
    double maxY = 0, minY = 0;
    DateTime? maxX, minX;
    Map<DateTime, double> datas = Map();
    data.forEach((element) {
      var dateString = DateFormat.yMd().format(element.time.toLocal());
      if (datas[DateFormat.yMd().parse(dateString)] == null) {
        datas[DateFormat.yMd().parse(dateString)] = element.amount * yBase;
      } else {
        datas[DateFormat.yMd().parse(dateString)] =
            datas[DateFormat.yMd().parse(dateString)]! + element.amount * yBase;
      }
    });
    datas.forEach((key, value) {
      if (value > maxY) {
        maxY = value;
      }
      if (value < minY) {
        minY = value;
      }
      if (maxX == null ||
          key.millisecondsSinceEpoch > maxX!.millisecondsSinceEpoch) {
        maxX = key;
      }
      if (minX == null ||
          key.millisecondsSinceEpoch < minX!.millisecondsSinceEpoch) {
        minX = key;
      }
    });

    List<FlSpot> flSpotDatas = [];
    datas.forEach((key, value) {
      flSpotDatas.add(FlSpot(
          (key.millisecondsSinceEpoch - minX!.millisecondsSinceEpoch) /
              (maxX!.millisecondsSinceEpoch - minX!.millisecondsSinceEpoch) *
              xBase,
          value));
    });
    return new RewardsChart(
      flSpotDatas,
      maxX,
      maxY,
      minX,
      minY,
      animate: animate,
    );
  }

  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(right: 10, top: 10),
      child: LineChart(
        mainData(),
      ),
    );
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xffcccccc),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xffcccccc),
            strokeWidth: 1,
          );
        },
      ),
      lineTouchData: LineTouchData(
          enabled: true,
          getTouchedSpotIndicator: (data, ints) {
            return ints
                .map((e) => TouchedSpotIndicatorData(
                    FlLine(color: Colors.black, strokeWidth: 2),
                    FlDotData(
                      show: true,
                      getDotPainter: (p0, p1, p2, p3) {
                        return FlDotCirclePainter(
                            radius: 3, color: Colors.black);
                      },
                    )))
                .toList();
          },
          touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Color(0x50000000),
              getTooltipItems: (datas) {
                return datas.map((e) {
                  var time = DateTime.fromMillisecondsSinceEpoch((e.x /
                              xBase *
                              (maxX!.millisecondsSinceEpoch -
                                  minX!.millisecondsSinceEpoch) +
                          minX!.millisecondsSinceEpoch)
                      .toInt());
                  return LineTooltipItem("", TextStyle(), children: [
                    TextSpan(
                        text: "${DateFormat.yMd().format(time.toLocal())}\n"),
                    TextSpan(text: "${(e.y / yBase).toStringAsFixed(6)}"),
                  ]);
                }).toList();
              })),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          getTextStyles: (context, index) => const TextStyle(fontSize: 12),
          getTitles: (value) {
            int b = xBase ~/ 2;
            if (seriesList.length < 3) {
              b = xBase;
            }
            if (value.toInt() % b == 0) {
              var time = DateTime.fromMillisecondsSinceEpoch((value /
                          xBase *
                          (maxX!.millisecondsSinceEpoch -
                              minX!.millisecondsSinceEpoch) +
                      minX!.millisecondsSinceEpoch)
                  .toInt());
              return "${DateFormat.yMd().format(time.toLocal())}";
            }
            return "";
          },
          margin: 8,
        ),
        topTitles: SideTitles(showTitles: false),
        rightTitles: SideTitles(showTitles: false),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (context, index) => const TextStyle(fontSize: 12),
          getTitles: (value) {
            return (value / yBase).toString();
          },
          reservedSize: 40,
          margin: 3,
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: 0,
      maxX: xBase * 1.05,
      minY: minY,
      maxY: maxY * 1.05,
      lineBarsData: linesBarData(),
    );
  }

  List<LineChartBarData> linesBarData() {
    final LineChartBarData lineChartBarData1 = LineChartBarData(
      spots: this.seriesList,
      isCurved: false,
      colors: gradientColors,
      barWidth: 1,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (flSpot, p1, lineChartBarData, p3) {
          return FlDotCirclePainter(
              radius: 1.5, color: flSpot.y < 0 ? Colors.red : Colors.black);
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        colors: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
      ),
    );
    return [lineChartBarData1];
  }
}

class TimeSeriesAmount {
  final DateTime time;
  final double amount;

  TimeSeriesAmount(this.time, this.amount);
}
