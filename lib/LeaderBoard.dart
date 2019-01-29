import 'package:flutter/material.dart';
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
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Builder(builder: (context) => Container(padding: MediaQuery.of(context).padding,child: ListView(
          padding: EdgeInsets.all(15.0),
          children: teams.map((e) => Padding(padding: EdgeInsets.only(top: 10.0, bottom: 10.0), child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(children: [Text("#${e.rank}", style: Theme.of(context).textTheme.body1, textScaleFactor: 1.2,),
              Text(" - ${e.name}", style: Typography.whiteMountainView.body1, textScaleFactor: 1.2,)],),
              Text("${e.count} Badges", style: Theme.of(context).textTheme.body1, textScaleFactor: 1.2,)
            ],
          ))).toList(),
        )
        )
        )
    );
  }
}