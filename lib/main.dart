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
        buttonColor: Color(0xFF7FFFD6),
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
  List<Team> teams = [];
  List<ScheduleItem> items = [];

  void getSchedule() {
    var query = QueryBuilder<ParseObject>(ParseObject("Schedule"))
      ..orderByAscending("startTime");
    query.query().then((response) {
      if(response.result != null) {
        List<ScheduleItem> mItems = response.result.map<ScheduleItem>((
            element) =>
            ScheduleItem(
                element.get<String>("name"), element.get<String>("description"),
                element.get<DateTime>("startTime"),
                element.get<DateTime>("endTime")
            )).toList();
        if(this.mounted) {
          setState(() {
            items = mItems;
          });
        }
        else {
          items = mItems;
        }
      }
    }, onError: (error) => print(error));
  }

  void getTeams() {
    ParseObject('_User').getAll().then((response) {
      Map<String, Team> sTeams = {};
      for(var obj in response.result) {
        String name = obj.get<String>("teamName");
        var codes = obj.get<List<dynamic>>("codes");
        if(codes == null) {
          codes = [];
        }
        int count = codes.length;
        if(sTeams[name] == null) {
          sTeams[name] = Team(name, 1, 0);
        }
        sTeams[name].count += count;
      }
      List<Team> sorted = sTeams.values.toList();
      sorted.sort((a, b) => b.count - a.count);
      int curCount = 1000000;
      int curRank = 0;
      for(Team t in sorted) {
        if(t.count < curCount) {
          curCount = t.count;
          t.rank = ++curRank;
        }
        else {
          t.rank = curRank;
        }
      }
      if(this.mounted) {
        setState(() {
          teams = sorted;
        });
      }
      else {
        teams = sorted;
      }
    }, onError: (error) => print(error));
  }

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
    getTeams();
    getSchedule();
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
          if(index == 2) {
            getTeams();
          }
          setState(() => currentIndex = index);
          _tabController.animateTo(index);
        },
      ),
        body: TabBarView(children: [
          CountDown(items),
          BadgeWidget(),
          LeaderBoard(teams)
        ], controller: _tabController, physics: NeverScrollableScrollPhysics(),)
    );
  }
}

class MainWidget extends StatefulWidget {
  @override
  MainWidgetState createState() => MainWidgetState();
}