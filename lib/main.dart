import 'package:flutter/cupertino.dart';
import 'CountDown.dart';
import 'Badges.dart';
import 'LeaderBoard.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
        title: "HackDavis",
        home: CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            items: <BottomNavigationBarItem> [
              BottomNavigationBarItem(icon: Icon(CupertinoIcons.clock)),
              BottomNavigationBarItem(icon: Icon(CupertinoIcons.check_mark)),
              BottomNavigationBarItem(icon: Icon(CupertinoIcons.flag)),
            ],
          ),
          tabBuilder: (BuildContext context, int index) {
            switch(index) {
              case 0: return CountDown();
              case 1: return Badges();
              case 2: return LeaderBoard();
            }
          },
        ));
  }
}