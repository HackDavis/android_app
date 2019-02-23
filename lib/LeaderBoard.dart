import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse.dart';

class LeaderBoard extends StatelessWidget {
  final List<Team> teams;

  LeaderBoard(this.teams);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Builder(
            builder: (context) => Container(
                padding: MediaQuery.of(context).padding,
                child: ListView(
                  padding: EdgeInsets.all(15.0),
                  children: teams
                      .map((e) => Padding(
                          padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Flexible(
                                  child: Text(
                                "#${e.rank} - ${e.name}",
                                style: (e.rank <= 3
                                    ? Theme.of(context).textTheme.body1
                                    : Typography.whiteMountainView.body1),
                                textScaleFactor: 1.2,
                              )),
                              Container(
                                  margin: EdgeInsets.only(left: 50.0),
                                  child: Text(
                                    "${e.count} Badges",
                                    style: Theme.of(context).textTheme.body1,
                                    textScaleFactor: 1.2,
                                  ))
                            ],
                          )))
                      .toList(),
                ))));
  }
}

class Team {
  String name;
  int rank;
  int count;
  Team(this.name, this.rank, this.count);
}
