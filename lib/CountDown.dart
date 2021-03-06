import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse.dart';
import 'dart:async';

class CountDown extends StatelessWidget {
  final List<ScheduleItem> items;

  CountDown(this.items);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Builder(builder: (context) {
      assert(debugCheckHasMediaQuery(context));
      EdgeInsets navEdge = MediaQuery.of(context).padding;
      return Container(
        margin: navEdge + EdgeInsets.only(top: 10.0),
        child: Column(
          children: <Widget>[Time(), Expanded(child: Schedule(items))],
        ),
      );
    }));
  }
}

class Schedule extends StatelessWidget {
  final List<ScheduleItem> items;

  Schedule(this.items);

  @override
  Widget build(BuildContext context) {
    return ListView(
        padding: EdgeInsets.only(top: 0),
        children: items.map((e) {
          var columnChildren = <Widget>[
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Flexible(
                  child: Text(
                e.name,
                style: Theme.of(context).textTheme.headline,
              )),
              Text(
                "${e.startTime.hour.toString()}:${e.startTime.minute.toString().padRight(2, "0")}",
                style: Theme.of(context).textTheme.body1,
                textScaleFactor: 1.25,
              )
            ])
          ];
          if (e.description != null && e.description != "") {
            columnChildren.add(Text(e.description,
                style: Typography.whiteMountainView.subhead));
          }
          return Padding(
              padding: EdgeInsets.all(15.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: columnChildren));
        }).toList());
  }
}

class ScheduleItem {
  String name;
  String description;
  DateTime startTime;
  DateTime endTime;
  ScheduleItem(this.name, this.description, this.startTime, this.endTime);
}

class Time extends StatefulWidget {
  @override
  TimeTicker createState() => TimeTicker();
}

class TimeTicker extends State<Time> {
  DateTime currentTime;
  Timer timer;
  DateTime hackathon = DateTime(2019, 2, 10, 12, 0, 0);

  @override
  void initState() {
    super.initState();
    timer = new Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() => currentTime = DateTime.now());
    });
  }

  @override
  void deactivate() {
    timer?.cancel();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    currentTime = DateTime.now();
    Duration delta = hackathon.difference(currentTime);
    int minutes = delta.inMinutes % Duration.minutesPerHour;
    int seconds = delta.inSeconds % Duration.secondsPerMinute;
    String computed = "${delta.inHours.toString()}:$minutes:$seconds";
    return Padding(
        padding: EdgeInsets.all(15.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Text("Hackathon Ends: "),
          Text(
            computed,
            textScaleFactor: 3,
          )
        ]));
  }
}
