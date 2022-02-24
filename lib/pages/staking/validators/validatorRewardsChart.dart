import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RewardsChart extends StatelessWidget {
  final List<List<FlSpot>> seriesList;
  final double maxY, minY;
  final int maxX, minX, minXValue;
  final List<ChartLineInfo> lines;
  final List<String> labels;
  RewardsChart(this.seriesList, this.lines, this.labels, this.maxX, this.maxY,
      this.minX, this.minY, this.minXValue);

  factory RewardsChart.withData(
      List<ChartLineInfo> lines, List<List> values, List<String> labels) {
    double maxY = 0, minY = 0;
    int maxX = labels.length, minX = 0;
    int index = labels.indexWhere((element) => element.length > 0);
    int minXValue = int.parse(labels[index]) - index;

    List<List<FlSpot>> flSpotDatas = [];
    values.forEach((element) {
      List<FlSpot> fdatas = [];
      int i = 0;
      element.forEach((element1) {
        if (element1 > maxY) {
          maxY = element1 * 1.0;
        }
        if (element1 < minY) {
          minY = element1 * 1.0;
        }
        fdatas.add(FlSpot(i * 1.0, element1 * 1.0));
        i++;
      });
      flSpotDatas.add(fdatas);
    });

    return new RewardsChart(
      flSpotDatas,
      lines,
      labels,
      maxX,
      maxY,
      minX,
      minY,
      minXValue,
    );
  }

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
                    FlLine(color: Colors.white, strokeWidth: 2),
                    FlDotData(
                      show: true,
                      getDotPainter: (p0, p1, p2, p3) {
                        return FlDotCirclePainter(
                            radius: 3, color: Colors.white);
                      },
                    )))
                .toList();
          },
          touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Color(0x88000000),
              getTooltipItems: (datas) {
                int i = 0;
                return datas.map((e) {
                  return LineTooltipItem("", TextStyle(), children: [
                    (i++) == 0
                        ? TextSpan(
                            text: "X:${(minXValue + e.x).toInt()}\n",
                            style: TextStyle(color: Colors.white))
                        : TextSpan(),
                    TextSpan(
                        text: "${e.y.toStringAsFixed(6)}",
                        style: TextStyle(color: e.bar.colors[0])),
                  ]);
                }).toList();
              })),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          getTextStyles: (context, index) =>
              const TextStyle(fontSize: 12, color: Colors.white),
          getTitles: (value) {
            return "${(minXValue + value).toInt()}";
          },
          margin: 6,
        ),
        topTitles: SideTitles(showTitles: false),
        rightTitles: SideTitles(showTitles: false),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (context, index) =>
              const TextStyle(fontSize: 12, color: Colors.white),
          getTitles: (value) {
            return value.toStringAsFixed(2);
          },
          reservedSize: 50,
          margin: 3,
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: 0,
      maxX: maxX * 1.00,
      minY: minY,
      maxY: maxY * 1.05,
      lineBarsData: linesBarData(),
    );
  }

  List<LineChartBarData> linesBarData() {
    int i = 0;
    return this.seriesList.map((element) {
      Color color = lines[i++].color;
      return LineChartBarData(
        spots: element,
        isCurved: false,
        colors: [color],
        barWidth: 1,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: false,
        ),
        belowBarData: BarAreaData(
          show: true,
          colors: [color].map((color) => color.withOpacity(0.5)).toList(),
        ),
      );
    }).toList();
  }
}

class ChartLineInfo {
  ChartLineInfo(this.name, this.color);
  final String name;
  final Color color;
}
