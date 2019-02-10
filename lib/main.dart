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
        ),
      dividerColor: Colors.white30
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
  List<Badge> badges = [];

  void addBadge(response){
    if(response != null) {
      ParseUser.currentUser().then((user) {
        List<dynamic> codes = user.get<List<dynamic>>("codes");
        codes.add(response);
        user.set("codes", codes);
        user.pin();
        user.save();
        this.badges.forEach((e) {
          if (e.base.get<String>("codes") == response) {
            e.isUnlocked = true;
          }
        });
        this.badges.sort((a, b) {
          if(a.isUnlocked && !b.isUnlocked) {
            return -1;
          }
          else if(b.isUnlocked && !a.isUnlocked) {
            return 1;
          }
          else {
            return 0;
          }
        });
        if (this.mounted) {
          setState(() {});
        }
      });
    }
  }

  void getBadges() {
    Future<dynamic> user = ParseUser.currentUser().then((response) {
      if(response != null) {
        return response.getCurrentUserFromServer();
      }
      else {
        return Future.value(null);
      }
    }
    );
    Future<ParseResponse> badges = ParseObject("Badge").getAll();
    Future.wait([user, badges]).then((list) {
      ParseUser user = list[0]?.result;
      ParseResponse badgeResponse = list[1];
      var badges = badgeResponse.result;
      List<dynamic> userCodes = user?.get<List<dynamic>>("codes");

      if(userCodes == null) {
        user?.set<List<dynamic>>("codes", []);
        user?.pin();
        user?.save();
      }
      userCodes = user?.get<List<dynamic>>("codes");

      List<Badge> mapped = badges.map<Badge>((badge) {
        return Badge(
            badge.get<String>("title"), (userCodes?.contains(badge.get<String>("codes")) ?? false), badge
        );
      }).toList();

      mapped.sort((a, b) {
        if(a.isUnlocked && !b.isUnlocked) {
          return -1;
        }
        else if(b.isUnlocked && !a.isUnlocked) {
          return 1;
        }
        else {
          return 0;
        }
      });

      if(this.mounted == true) {
        setState(() => this.badges = mapped);
      }
      else {
        this.badges = mapped;
      }

      var futures = mapped.map((e) => e.loadImage());

      Future.wait(futures).then((badges) {
        if(this.mounted == true) {
          setState(() => this.badges = badges);
        }
        else {
          this.badges = badges;
        }
      });
    });
  }

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
    var query = QueryBuilder<ParseObject>(ParseObject("_User"));
    query.setLimit(400);
    query.query().then((response) {
      Map<String, Team> sTeams = {};
      if(response.result != null) {
        for (var obj in response.result) {
          String name = obj.get<String>("teamName");
          var codes = obj.get<List<dynamic>>("codes");
          if (codes == null) {
            codes = [];
          }
          var codesSet = Set.from(codes);
          int count = codesSet.length;
          if (sTeams[name] == null) {
            sTeams[name] = Team(name, 1, 0);
          }
          sTeams[name].count += count;
        }
        List<Team> sorted = sTeams.values.toList();
        sorted.sort((a, b) => b.count - a.count);
        int curCount = 1000000;
        int curRank = 0;
        for (Team t in sorted) {
          if (t.count < curCount) {
            curCount = t.count;
            t.rank = ++curRank;
          }
          else {
            t.rank = curRank;
          }
        }
        if (this.mounted) {
          setState(() {
            teams = sorted;
          });
        }
        else {
          teams = sorted;
        }
      }
    }, onError: (error) => print(error));
  }

  @override
  void initState() {
    if(currentUser == "waiting") {
    ParseUser.currentUser().then((response) {
      if (response == null) {
        Navigator.of(context).pushNamed("/login").then((result) {
          getBadges();
          setState(() => currentUser = result);
        });
      }
      else {
        getBadges();
        setState(() {
          currentUser = response;
        });
      }
    }
    );
  }
    getTeams();
    getSchedule();
    getBadges();
    super.initState();
    _tabController = new TabController(length: 3, vsync: this);
  }
  @override
  Widget build(BuildContext context) {
    if(currentUser == "waiting") {
      return Center(child: RefreshProgressIndicator());
    }
    return Scaffold(
      bottomNavigationBar: Container(decoration: BoxDecoration(border: Border(
        top: BorderSide(color: Theme.of(context).dividerColor)
      )), child: BottomNavigationBar(
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
          else if(index == 1) {
            getBadges();
          }
	        else if(index == 0) {
            getSchedule();	    
          }
          setState(() => currentIndex = index);
          _tabController.animateTo(index);
        },
      )),
        body: TabBarView(children: [
          CountDown(items),
          BadgeWidget(badges, addBadge),
          LeaderBoard(teams)
        ], controller: _tabController, physics: NeverScrollableScrollPhysics(),)
    );
  }
}

class MainWidget extends StatefulWidget {
  @override
  MainWidgetState createState() => MainWidgetState();
}
