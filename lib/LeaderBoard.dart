import 'package:flutter/cupertino.dart';
import 'package:parse_server_sdk/parse.dart';
class LeaderBoard extends StatefulWidget {
  @override
  Leaders createState() => Leaders();
}

class Team {
  String name;
  int rank;
  int count;
  Team(this.name, this.rank, this.count);
}

class Leaders extends State<LeaderBoard> {
  List<Team> teams = [];
  @override
  void initState() {
    ParseObject('_User').getAll().then((response) {
      print(response.result);
      Map<String, Team> sTeams = {};
      for(var obj in response.result) {
        String name = obj.get<String>("teamName");
        int count = obj.get<List<dynamic>>("codes").length;
        if(sTeams[name] == null) {
          sTeams[name] = Team(name, 1, 0);
        }
        sTeams[name].count += count;
      }
      List<Team> sorted = sTeams.values.toList();
      sorted.sort((a, b) => b.count - a.count);
      int curCount = 1000000;
      int curRank = 1;
      for(Team t in sorted) {
        if(t.count < curCount) {
          curCount = t.count;
          t.rank = curRank++;
        }
        else {
          t.rank = curRank;
        }
      }
      setState(() {
        teams = sorted;
      });
    }, onError: (error) => print(error));
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(middle: Text("Leaderboard",)),
        child: Builder(builder: (context) => Container(padding: MediaQuery.of(context).padding,child: ListView(
          padding: EdgeInsets.all(15.0),
          children: teams.map((e) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("#${e.rank} - ${e.name}"),
              Text("${e.count} Badges")
            ],
          )).toList(),
        )
        )
        )
    );
  }
}