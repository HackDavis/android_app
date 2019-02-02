import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parse_server_sdk/parse.dart';
import 'PopOver.dart';

class BadgeWidget extends StatelessWidget {
  final List<Badge>badges;
  final void Function(dynamic response) callback;

  BadgeWidget(this.badges, this.callback);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(builder: (context) =>
          Container(padding: MediaQuery.of(context).padding, child:
          GridView.count(crossAxisCount: 3, padding: EdgeInsets.all(10.0), children: badges.map((f) {
            var children = <Widget>[];
            if(f.isUnlocked) {
              ParseFile image = f.base.get<ParseFile>("image");
              if(image != null && image.file != null) {
                children.add(Padding(padding: EdgeInsets.all(10.0), child: Image.file(image.file)));
              }
              children.add(Text(f.title, style: Theme
                  .of(context)
                  .textTheme
                  .body1,
                textAlign: TextAlign.center,
                textScaleFactor: 0.75,));
            }
            else {
              children.add(Icon(Icons.lock, size: 55.0));
            }
            return Padding(
                padding: EdgeInsets.all(5.0),
                child: DecoratedBox(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: f.isUnlocked ? Color.fromRGBO(
                            255, 255, 255, 0.1) : Colors.transparent),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center,
                      children: children,)
                )
            );
          }).toList())
          )
      ),
      floatingActionButton: FloatingActionButton(
          tooltip: "Add a badge",
          child: Icon(Icons.add),
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddBadge())).then(this.callback)),
    );
  }
}

class Badge {
  String title;
  bool isUnlocked;
  ParseObject base;
  Badge(String title, this.isUnlocked, this.base) {
    this.title = title ?? "";
  }

  Future<Badge> loadImage() {
    ParseFile image = base.get<ParseFile>("image");
    if(image != null) {
      return image.loadStorage().then((ParseFile f) {
        if(f.file == null) {
          return image.download().then((ParseFile f){
            base.set<ParseFile>("image", f);
            return Future.value(this);
          });
        }
        else {
          base.set<ParseFile>("image", f);
          return Future.value(this);
        }
      });
    }
    else {
      return Future.value(this);
    }
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
      Text("Add a badge", style: Theme.of(context).textTheme.headline),
      Padding(padding: EdgeInsets.all(10.0) + EdgeInsets.only(bottom: 15.0), child: TextField(controller: controller, style: Theme.of(context).textTheme.body1, onChanged: (s) {
        if(invalid) {
          setState(() {
            invalid = false;
          });
        }
      },)),
      RaisedButton(child: Text("Submit"),
        textColor: Colors.black54,
        onPressed: () {
        var query = QueryBuilder<ParseObject>(ParseObject("Badge"));
        query.whereEqualTo("codes", controller.text);
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