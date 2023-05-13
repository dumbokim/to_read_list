import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'home/home_view.dart';

class MainView extends StatefulWidget {
  const MainView({Key? key}) : super(key: key);

  @override
  State<MainView> createState() => _MainViewState();
}

const _pageTitle = [
  '홈',
  '리스트',
  '추천',
  '마이페이지'
];

class _MainViewState extends State<MainView> {
  int _currentIdx = 0;

  final _pages = <Widget>[
    const HomeView(),
    Container(
      child: Center(
        child: Text(_pageTitle[1]),
      ),
    ),
    Container(
      child: Center(
        child: Text(_pageTitle[2]),
      ),
    ),
    Container(
      child: Center(
        child: Text(_pageTitle[3]),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(_pageTitle[_currentIdx]),
        ),
        body: CupertinoTabScaffold(
            tabBar: CupertinoTabBar(
              onTap: (int index) {
                setState(() {
                  _currentIdx = index;
                });
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home)),
                BottomNavigationBarItem(icon: Icon(Icons.list_alt)),
                BottomNavigationBarItem(icon: Icon(Icons.card_giftcard)),
                BottomNavigationBarItem(icon: Icon(Icons.person)),
              ],
            ),
            tabBuilder: (BuildContext context, int index) {
              return _pages[index];
            }),
      ),
    );
  }
}
