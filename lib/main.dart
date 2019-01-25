import 'package:flutter/cupertino.dart';
import 'CountDown.dart';
import 'Badges.dart';
import 'LeaderBoard.dart';
import 'Login.dart';
import 'package:parse_server_sdk/parse.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  dynamic currentUser = "waiting";
  @override
  void initState() {
    Parse().initialize(
        "hackdavis2019",
        "https://hackdavisapp.herokuapp.com/parse");
    ParseUser.currentUser().then((response) {
      setState(() {
        currentUser = response;
      }
      );
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
        title: "HackDavis",
        home: MainWidget(currentUser),
        initialRoute: "/login",
        routes: {
          '/login': (context) => Login()
        });
  }
}

class MainWidget extends StatelessWidget {
  final dynamic user;
  MainWidget(this.user);
  @override
  Widget build(BuildContext context) {
    if(this.user == null) {
      Navigator.of(context).pushNamed("/login");
    }
    return CupertinoTabScaffold(
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
        );
  }
}