import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'home/home_view.dart';

class MainView extends StatefulWidget {
  const MainView({Key? key}) : super(key: key);

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _currentIdx = 0;

  final _pageTitle = [
    '홈',
    '리스트',
    '추천',
    '마이페이지'
  ];


  final _pages = <Widget>[
    const HomeView(),
    Container(
      child: Center(
        child: Text('리스트'),
      ),
    ),
    Container(
      child: Center(
        child: Text('추천'),
      ),
    ),
    Container(
      child: Center(
        child: Text('마이페이지'),
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
