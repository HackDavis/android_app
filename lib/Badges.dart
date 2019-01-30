import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parse_server_sdk/parse.dart';
import 'PopOver.dart';

class BadgeWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => Badges();
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

class Badges extends State<BadgeWidget> with AutomaticKeepAliveClientMixin{
  var badges = <Badge>[];
  ParseUser user;
  @override
  void initState() {
    Future<dynamic> user = ParseUser.currentUser().then((response) => response.getCurrentUserFromServer());
    Future<ParseResponse> badges = ParseObject("Badge").getAll();
    Future.wait([user, badges]).then((list) {
      ParseUser user = list[0].result;
      this.user = user;
      ParseResponse badgeResponse = list[1];
      var badges = badgeResponse.result;
      List<dynamic> userCodes = user.get<List<dynamic>>("codes");

      if(userCodes == null) {
        user.set<List<dynamic>>("codes", []);
        user.pin();
        user.save();
      }
      userCodes = user.get<List<dynamic>>("codes");

      List<Badge> mapped = badges.map<Badge>((badge) {
        return Badge(
          badge.get<String>("title"), userCodes.contains(badge.get<String>("codes")), badge
        );
      }).toList();

      mapped.sort((a, b) {
        if(a.isUnlocked && !b.isUnlocked) {
          return -1;
        }
        else if(b.isUnlocked && !a.isUnlocked) {
          return 1;
        }
        else {
          return 0;
        }
      });

      if(this.mounted == true) {
        setState(() => this.badges = mapped);
      }
      else {
        this.badges = mapped;
      }

      var futures = mapped.map((e) => e.loadImage());

      Future.wait(futures).then((badges) {
        badges.sort((a, b) {
          if(a.isUnlocked && !b.isUnlocked) {
            return -1;
          }
          else if(b.isUnlocked && !a.isUnlocked) {
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
      });
    });

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);

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
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddBadge())).then((response){
            if(response != null) {
              List<dynamic> codes = this.user.get<List<dynamic>>("codes");
              codes.add(response);
              this.user.set("codes", codes);
              this.user.pin();
              this.user.save();
              this.badges.forEach((e) {
                if (e.base.get<String>("codes") == response) {
                  e.isUnlocked = true;
                  if (this.mounted) {
                    setState(() {});
                  }
                }
              });
            }
          })),
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