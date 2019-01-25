import 'package:flutter/cupertino.dart';

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
          trailing: CupertinoButton(child: Icon(CupertinoIcons.plus_circled),
              onPressed: () => Navigator.push(context, CupertinoPageRoute(builder:
                  (context) => AddBadge()))),
        ),
        child: Builder(builder: (context) =>
            Container(padding: MediaQuery.of(context).padding, child:
            GridView(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3))
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
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoNavigationBarBackButton(color: CupertinoColors.activeBlue),
      ),
      child: Column(children: <Widget>[
        Text("Add a badge code"),
        CupertinoTextField(controller: controller,),
        CupertinoButton(child: Text("Submit"), onPressed: () {
          Navigator.of(context).pop();
        },)
      ],)
    );
  }

}