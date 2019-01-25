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

class ScheduleItem {
  String name;
  String description;
  DateTime startTime;
  DateTime endTime;
  ScheduleItem(this.name, this.description, this.startTime, this.endTime);
}

class ScheduleState extends State<Schedule> {
  List<ScheduleItem> items = [];
  @override
  void initState() {
    ParseObject('Schedule').getAll().then((response) {
      List<ScheduleItem> mItems = response.result.map<ScheduleItem>((element) => ScheduleItem(
        element.get<String>("name"), element.get<String>("description"),
          element.get<DateTime>("startTime"), element.get<DateTime>("endTime")
      )).toList();
      setState(() {
        items = mItems;
      });
    }, onError: (error) => print(error));
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return ListView(
        padding: EdgeInsets.only(top: 0),
        children: items.map((e) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:[
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
          Text(e.name),
          Text("${e.startTime.hour.toString()}:${e.startTime.minute.toString()}")
        ]),
        Text(e.description)
      ]
    )).toList());
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
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Hackathon Ends: "),
          Text(computed, textScaleFactor: 3,)
    ]);
  }

}
