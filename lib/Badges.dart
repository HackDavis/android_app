import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parse_server_sdk/parse.dart';
import 'PopOver.dart';

class BadgeWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => Badges();
}

class Badges extends State<BadgeWidget> with AutomaticKeepAliveClientMixin{
  var badges = [];
  @override
  void initState() {
    Future<dynamic> user = ParseUser.currentUser().then((response) => response.getCurrentUserFromServer());
    Future<ParseResponse> badges = ParseObject("Badge").getAll();
    Future.wait([user, badges]).then((list) {
      ParseUser user = list[0].result;
      ParseResponse badgeResponse = list[1];
      var badges = badgeResponse.result;
      List<dynamic> userCodes = user.get<List<dynamic>>("codes");
      if(userCodes == null) {
        user.set<List<dynamic>>("codes", []);
        user.pin();
      }
      userCodes = user.get<List<dynamic>>("codes");
      badges.sort((a, b) {
        if(userCodes.contains(a.get<String>("codes"))) {
          return -1;
        }
        else if(userCodes.contains(b.get<String>("codes"))) {
          return 1;
        }
        else {
          return 0;
        }
      });
      if(this.mounted == true) {
        setState(() => this.badges = badges);
      }
      else {
        this.badges = badges;
      }
    }).catchError((error) {
      print(error);
    });

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        body: Builder(builder: (context) =>
            Container(padding: MediaQuery.of(context).padding + EdgeInsets.all(10.0), child:
            GridView.count(crossAxisCount: 3, children: badges.map((f) => Text(f.get<String>("objectId"))).toList())
    )
    ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Add a badge",
          child: Icon(Icons.add),
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddBadge()))),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class AddBadge extends StatefulWidget {
  @override
  AddBadgeForm createState() => AddBadgeForm();
}

class AddBadgeForm extends State<AddBadge> {
  var controller = TextEditingController();
  bool invalid = false;
  @override
  Widget build(BuildContext context) {
    var columnChildren = <Widget>[];
    columnChildren += [
      Text("Add a badge", style: Theme.of(context).textTheme.headline),
      TextField(controller: controller, style: Theme.of(context).textTheme.body1, onChanged: (s) {
        if(invalid) {
          setState(() {
            invalid = false;
          });
        }
      },),
      FlatButton(child: Text("Submit", style: Theme.of(context).textTheme.button), onPressed: () {
        var query = QueryBuilder<ParseObject>(ParseObject("Badge"));
        query.whereContains("codes", controller.text);
        query.query().then((response) {
          print(response.result);
          if(response.result != null) {
            Navigator.of(context).pop(controller.text);
          }
          else {
            setState(() {
              invalid = true;
            });
          }
        });
      },)
    ];
    if(invalid) {
      columnChildren.insert(2, Align(
        alignment: Alignment.centerLeft,
          child: PopOver(text: "Badge Number is Wrong", popOverColor: Colors.red, brightness: Brightness.dark,))
      );
    }
    return Scaffold(
      body: Builder(builder: (context) => Padding(padding: MediaQuery.of(context).padding + EdgeInsets.all(10.0),
        child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: columnChildren,)
      )
    )
      )
    );
  }

}