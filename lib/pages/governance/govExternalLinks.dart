import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_ui/components/jumpToBrowserLink.dart';

class GovExternalLinks extends StatelessWidget {
  GovExternalLinks(this.links);

  final List? links;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Visibility(
            visible: links!.length > 0,
            child: Padding(
              padding: EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  JumpToBrowserLink(
                    links!.length > 0 ? links![0]['link'] : "",
                    text: links!.length > 0 ? links![0]['name'] : "",
                  ),
                  links!.length > 1
                      ? JumpToBrowserLink(
                          links![1]['link'],
                          text: links![1]['name'],
                        )
                      : Container(width: 80)
                ],
              ),
            )),
        Visibility(
            visible: links!.length > 2,
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  JumpToBrowserLink(
                    links!.length > 2 ? links![2]['link'] : "",
                    text: links!.length > 3 ? links![2]['name'] : "",
                  ),
                  links!.length > 3
                      ? JumpToBrowserLink(
                          links![3]['link'],
                          text: links![3]['name'],
                        )
                      : Container(width: 80)
                ],
              ),
            ))
      ],
    );
  }
}
