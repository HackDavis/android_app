import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parse_server_sdk/parse.dart';
import 'PopOver.dart';

class BadgeWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => Badges();
}

class Badges extends State<BadgeWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Builder(builder: (context) =>
            Container(padding: MediaQuery.of(context).padding, child:
            GridView.count(crossAxisCount: 3, children: <Widget>[

            ],)
    )
    ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Add a badge",
          child: Icon(Icons.add),
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddBadge()))),
    );
  }
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
      Text("Add a badge code", style: Theme.of(context).textTheme.headline),
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
      body: Builder(builder: (context) => Padding(padding: MediaQuery.of(context).padding,
      child: Column(children: columnChildren,))
      )
    );
  }

}