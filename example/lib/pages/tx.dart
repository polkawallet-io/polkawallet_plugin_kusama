import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';

class NetworkSelectPage extends StatefulWidget {
  NetworkSelectPage(this.network);

  final PluginKusama network;

  static const String route = '/tx';

  @override
  _TxPageState createState() => _TxPageState();
}

class _TxPageState extends State<NetworkSelectPage> {
  // final String _testPubKey =
  //     '0xe611c2eced1b561183f88faed0dd7d88d5fafdf16f5840c63ec36d8c31136f61';
  // final String _testAddress =
  //     '16CfHoeSifpXMtxVvNAkwgjaeBXK8rAm2CYJvQw4MKMjVHgm';
  // final String _testAddressGav =
  //     'FcxNWVy5RESDsErjwyZmPCW6Z8Y3fbfLzmou34YZTrbcraL';

  // final _testPass = 'a123456';

  // bool _submitting = false;
  String _status;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('keyring API'),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            ListTile(
              title: Text('send tx status: $_status'),
            ),
            Divider(),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
