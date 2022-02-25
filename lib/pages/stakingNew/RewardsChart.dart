import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:polkawallet_ui/utils/format.dart';

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
    if (datas.length == 1) {
      minY = 0;
      maxX = datas.keys.toList()[0].add(Duration(days: 7));
    }

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
    const Color(0xFFFFA07E),
  ];
  List<Color> chartBelowBarColors = [
    const Color(0xFFFFA07E),
    const Color(0x12FFD0C0),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(right: 10, top: 10),
      child: LineChart(
        mainData(context),
      ),
    );
  }

  LineChartData mainData(BuildContext context) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0x26FFFFFF),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0x26FFFFFF),
            strokeWidth: 1,
          );
        },
      ),
      lineTouchData: LineTouchData(
          enabled: true,
          getTouchedSpotIndicator: (data, ints) {
            return ints
                .map((e) => TouchedSpotIndicatorData(
                    FlLine(color: Colors.white, strokeWidth: 2),
                    FlDotData(
                      show: true,
                      getDotPainter: (p0, p1, p2, p3) {
                        return FlDotCirclePainter(
                            radius: 3,
                            color: gradientColors[0],
                            strokeColor: Colors.white);
                      },
                    )))
                .toList();
          },
          touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Color(0x70000000),
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
                        text: "${DateFormat.yMd().format(time.toLocal())}\n",
                        style: Theme.of(context).textTheme.headline5?.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600)),
                    TextSpan(
                        text:
                            "${Fmt.priceFloorFormatter(e.y / yBase, lengthMax: 6)}",
                        style: Theme.of(context).textTheme.headline5?.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600)),
                  ]);
                }).toList();
              })),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          getTextStyles: (context, index) => Theme.of(context)
              .textTheme
              .headline5
              ?.copyWith(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600),
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
          getTextStyles: (context, index) => Theme.of(context)
              .textTheme
              .headline5
              ?.copyWith(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600),
          getTitles: (value) {
            return Fmt.priceFloorFormatter(value / yBase, lengthMax: 5);
          },
          reservedSize: 30,
          margin: 7,
        ),
      ),
      borderData: FlBorderData(show: false),
      backgroundColor: Color(0xFF282A2D),
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
              radius: 1.5, color: Colors.white, strokeColor: Colors.white);
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        gradientFrom: Offset(0, 0),
        gradientTo: Offset(0, 1),
        colors: chartBelowBarColors,
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
