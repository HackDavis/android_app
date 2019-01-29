import 'package:flutter/material.dart';
import 'CountDown.dart';
import 'Badges.dart';
import 'LeaderBoard.dart';
import 'Login.dart';
import 'package:parse_server_sdk/parse.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {

  @override
  void initState() {
    Parse().initialize(
        "hackdavis2019",
        "https://hackdavisapp.herokuapp.com/parse");
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    var theme = ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF091822),
        canvasColor: Color(0xFF091822),
        primaryColor: Color(0xFF7FFFD6),
        textTheme: Typography.whiteMountainView.apply(
            bodyColor: Color(0xFF7FFFD6)
        )
    );
    return MaterialApp(
      title: "HackDavis",
      home: MainWidget(),
      initialRoute: "/",
      routes: {
        '/login': (context) => Login()
      },
      theme: theme,
    );
  }
}

class MainWidgetState extends State<MainWidget> with SingleTickerProviderStateMixin{
  dynamic currentUser = "waiting";
  int currentIndex = 0;
  TabController _tabController;
  final _widgets = [
    CountDown(),
    BadgeWidget(),
    LeaderBoard()
  ];
  @override
  void initState() {
    if(currentUser == "waiting") {
    ParseUser.currentUser().then((response) {
      if (response == null) {
        Navigator.of(context).pushNamed("/login").then((result) =>
        setState(() => currentUser = result));
      }
      else {
        setState(() {
          currentUser = response;
        });
      }
    }
    );
  }
    super.initState();
    _tabController = new TabController(length: 3, vsync: this);
  }
  @override
  Widget build(BuildContext context) {
    if(currentUser == "waiting") {
      return Center(child: RefreshProgressIndicator());
    }
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem> [
          BottomNavigationBarItem(title: Text("Schedule"), icon: Icon(Icons.alarm)),
          BottomNavigationBarItem(title: Text("Badges"), icon: Icon(Icons.bookmark)),
          BottomNavigationBarItem(title: Text("Leaderboard"), icon: Icon(Icons.flag)),
        ],
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() => currentIndex = index);
          _tabController.animateTo(index);
        },
      ),
        body: TabBarView(children: _widgets, controller: _tabController, physics: NeverScrollableScrollPhysics(),)
    );
  }
}

class MainWidget extends StatefulWidget {
  @override
  MainWidgetState createState() => MainWidgetState();
}