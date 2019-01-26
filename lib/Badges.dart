import 'package:flutter/cupertino.dart';
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
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Badges'),
          trailing: LayoutBuilder(builder: (context, constraints) => ConstrainedBox(constraints: constraints,
          child: CupertinoButton(child: Icon(CupertinoIcons.plus_circled),
              onPressed: () => Navigator.of(context).push<void>(CupertinoPageRoute(
                  builder:
                  (context) => AddBadge()))))),
        ),
        child: Builder(builder: (context) =>
            Container(padding: MediaQuery.of(context).padding, child:
            GridView.count(crossAxisCount: 3, children: <Widget>[

            ],)
    )
    )
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
      Text("Add a badge code"),
      CupertinoTextField(controller: controller, onChanged: (s) {
        if(invalid) {
          setState(() {
            invalid = false;
          });
        }
      },),
      CupertinoButton(child: Text("Submit"), onPressed: () {
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
          child: PopOver(text: "Badge Number is Wrong", popOverColor: CupertinoColors.destructiveRed, brightness: Brightness.dark,))
      );
    }
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: true,
      ),
      child: Builder(builder: (context) => Padding(padding: MediaQuery.of(context).padding,
      child: Column(children: columnChildren,))
      )
    );
  }

}