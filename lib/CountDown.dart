import 'package:flutter/cupertino.dart';
import 'package:parse_server_sdk/parse.dart';
import 'dart:async';

class CountDown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(
      builder: (context) => CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(middle: Text("HackDavis")),
          child: Builder(builder: (context) {
            assert(debugCheckHasMediaQuery(context));
            EdgeInsets navEdge = MediaQuery.of(context).padding;
            return Container(margin: navEdge + EdgeInsets.all(10.0), child: Column(children: <Widget>[
              Time(),
              Expanded(child: Schedule())
            ],),
            );
          }
          )
      )
    );
  }
}

class Schedule extends StatefulWidget {
  @override
  ScheduleState createState() => ScheduleState();

}

class ScheduleState extends State<Schedule> {
  @override
  void initState() {

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return ListView(children: <Widget>[

    ],);
  }

}

class Time extends StatefulWidget {
  @override
  TimeTicker createState() => TimeTicker();

}

class TimeTicker extends State<Time> {
  DateTime currentTime;
  Timer timer;
  DateTime hackathon = DateTime(2019, 2, 10, 12);

  @override
  void initState() {
    super.initState();
    timer = new Timer.periodic(Duration(seconds: 1), (Timer timer){
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
    int minutes = delta.inHours % Duration.minutesPerHour;
    int seconds = delta.inSeconds % Duration.secondsPerMinute;
    String computed = "${delta.inHours.toString()}:$minutes:$seconds";
    return Text(computed, textAlign: TextAlign.center, textScaleFactor: 2,);
  }

}
