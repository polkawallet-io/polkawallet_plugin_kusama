import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_sdk/plugin/index.dart';

class ListItemData {
  ListItemData({this.title, this.subtitle});
  final String title;
  final String subtitle;
}

class SelectListPage extends StatelessWidget {
  static const route = '/select';

  @override
  Widget build(BuildContext context) {
    final List<ListItemData> list = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(title: Text('Select')),
      body: SafeArea(
        child: ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) {
              return ListTile(
                title: Text(list[i].title),
                subtitle: Text(list[i].subtitle),
                trailing: Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () {
                  Navigator.of(context).pop(i);
                },
              );
            }),
      ),
    );
  }
}
