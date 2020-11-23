import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:polkawallet_ui/ui.dart';
import 'package:polkawallet_sdk/plugin/index.dart';
import 'package:polkawallet_sdk/plugin/homeNavItem.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({
    this.network,
    this.keyring,
    this.assetsContent,
    this.profileContent,
  });

  final PolkawalletPlugin network;
  final Keyring keyring;
  final Widget assetsContent;
  final Widget profileContent;

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
    final List<HomeNavItem> pages = [
      HomeNavItem(
        text: 'Assets',
        icon: Icon(
          Icons.account_balance_wallet,
          color: Theme.of(context).disabledColor,
          size: 32,
        ),
        iconActive: Icon(
          Icons.account_balance_wallet,
          color: widget.network.basic.primaryColor,
          size: 32,
        ),
        content: widget.assetsContent,
      )
    ];
    pages.addAll(widget.network.getNavItems(context, widget.keyring));
    pages.add(HomeNavItem(
      text: 'Profile',
      icon: Icon(
        CupertinoIcons.profile_circled,
        color: Theme.of(context).disabledColor,
        size: 34,
      ),
      iconActive: Icon(
        CupertinoIcons.profile_circled,
        color: widget.network.basic.primaryColor,
        size: 34,
      ),
      content: widget.profileContent,
    ));
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _tabIndex = index;
          });
        },
        children: pages
            .map((e) => Scaffold(
                    body: PageWrapperWithBackground(SafeArea(
                  child: e.content,
                ))))
            .toList(),
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
