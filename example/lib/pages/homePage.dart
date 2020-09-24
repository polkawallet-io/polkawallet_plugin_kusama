import 'package:flutter/material.dart';
import 'package:polkawallet_sdk/plugin/index.dart';
import 'package:polkawallet_sdk/plugin/homeNavItem.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage(this.network, this.networkName);

  final PolkawalletPlugin network;
  final NetworkName networkName;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final PageController _pageController = PageController();

  int _tabIndex = 0;

  List<BottomNavigationBarItem> _buildNavItems(List<HomeNavItem> items) {
    return items.map((e) {
      final active = items[_tabIndex].text == e.text;
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
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.networkName == NetworkName.polkadot ? 'pink' : 'black';
    final List<HomeNavItem> pages = [
      HomeNavItem(
        text: 'Assets',
        icon: Image.asset('assets/images/assets.png'),
        iconActive: Image.asset('assets/images/assets_$color.png'),
        content: Text('aaaaa'),
      )
    ];
    pages.addAll(widget.network.navItems);
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _tabIndex = index;
          });
        },
        children: pages.map((e) => SafeArea(child: e.content)).toList(),
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
        items: _buildNavItems(pages),
      ),
    );
  }
}
