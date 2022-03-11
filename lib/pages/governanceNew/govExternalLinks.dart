import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_ui/utils/index.dart';

class GovExternalLinks extends StatelessWidget {
  GovExternalLinks(this.links);

  final List? links;

  Widget buildItem(dynamic data, BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          UI.launchURL(data['link']);
        },
        child: Padding(
            padding: EdgeInsets.only(left: 15),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    color: Color.fromARGB(255, 84, 85, 86),
                  ),
                  alignment: Alignment.center,
                  child: Image.asset(
                      "packages/polkawallet_plugin_kusama/assets/images/gov/${data['name']}.png",
                      height: 28),
                ),
                Text(
                  data['name'],
                  style: Theme.of(context).textTheme.headline5?.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w300),
                )
              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: (links ?? []).map((e) => buildItem(e, context)).toList(),
    );
  }
}
