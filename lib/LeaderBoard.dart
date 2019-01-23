import 'package:flutter/cupertino.dart';
class LeaderBoard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text("Leaderboard",)),
        child: Builder(builder: (context) => Container(padding: MediaQuery.of(context).padding,child: ListView(
      children: <Widget>[],
    )
        )
        )
    );
  }

}