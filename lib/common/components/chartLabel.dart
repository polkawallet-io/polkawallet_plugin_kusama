import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChartLabel extends StatelessWidget {
  ChartLabel({this.name, this.color});

  final String? name;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
            height: 8,
            width: 15,
            margin: EdgeInsets.only(right: 8),
            color: color),
        Text(
          name!,
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
