import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_sdk/polkawallet_sdk.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _network = PluginKusama();

  bool _connected = false;

  Future<void> _startPlugin() async {
    final connected = await _network.start();
    if (connected != null) {
      setState(() {
        _connected = true;
      });
    }
  }

  void _showResult(BuildContext context, String title, res) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: SelectableText(res, textAlign: TextAlign.left),
          actions: [
            CupertinoButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _startPlugin();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Polkawallet SDK Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(_network),
      routes: {},
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage(this.network);

  final PolkawalletPlugin network;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final PageController _pageController = PageController();

  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final navItems = widget.network.navItems;
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _tabIndex = index;
          });
        },
        children: navItems.map((e) => SafeArea(child: e.content)).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        iconSize: 22.0,
        onTap: (index) {
          setState(() {
            _tabIndex = index;
          });
          _pageController.jumpToPage(index);
        },
        type: BottomNavigationBarType.fixed,
        items: navItems.map((e) {
          final active = navItems[_tabIndex].text == e.text;
          return BottomNavigationBarItem(
            icon: SizedBox(
              child: active ? e.iconActive : e.icon,
              width: 32,
              height: 32,
            ),
            title: Text(
              e.text,
              style: TextStyle(
                  fontSize: 14,
                  color: active ? Theme.of(context).primaryColor : Colors.grey),
            ),
          );
        }).toList(),
      ),
    );
  }
}
