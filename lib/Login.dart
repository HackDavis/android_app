import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse.dart';
import 'package:flutter/services.dart';
import 'PopOver.dart';
class Login extends StatefulWidget {
  @override
  LoginForm createState() => LoginForm();

}
class LoginForm extends State<Login> {
  TextEditingController teamName = TextEditingController();
  TextEditingController userName = TextEditingController();
  static const platform = const MethodChannel('hackdavis.io/login');
  bool teamExists = false;
  bool invalid = false;
  bool full = false;
  bool emptyName = false;
  @override
  void initState() {
    super.initState();
  }

  Future<bool> validate(s) {
    bool ok = true;
    if(teamName.text.length == 0) {
      setState(() => invalid = true);
      ok = false;
    }
    if(userName.text.length == 0) {
      setState(() => emptyName = true);
      ok = false;
    }
    if(!ok) {
      return Future.value(false);
    }
    var query = QueryBuilder<ParseObject>(ParseObject("_User"));
    query.whereEqualTo("teamName", teamName.text);
    return query.query().then((response) {
      if(response.result != null) {
        if(response.result.length > 4) {
          setState(() => full = true);
          return Future.value(false);
        }
        else {
          setState(() => teamExists = true);
          return Future.value(true);
        }
      }
      else {
        return Future.value(true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var teamNameField = Padding(padding: EdgeInsets.all(10.0) + EdgeInsets.only(bottom: 15.0), child: TextField(controller: teamName,
      onChanged: (s) {
        if(teamExists || invalid || full) {
          setState(() {
            teamExists = false;
            invalid = false;
            full = false;
          });
        }
      },
      onSubmitted: validate,));

    var userNameField = Padding(padding: EdgeInsets.all(10.0) + EdgeInsets.only(bottom: 15.0), child: TextField(controller: userName,
      onChanged: (s) {
        if(emptyName) {
          setState(() {
            emptyName = false;
          });
        }
      },
      onSubmitted: validate,));
    List<Widget> columnChildren = [
      Text("Your Name:", style: Theme.of(context).textTheme.subhead),
      userNameField,
      Text("Team Name:", style: Theme.of(context).textTheme.subhead),
      teamNameField,
      RaisedButton(child: Text("Login",),
        textColor: Colors.black54,
        onPressed: () {
            /*try {
              platform.invokeMethod("loginAnonymous",
                  <String, dynamic>{"teamName": teamName.text}).then((result) {
                              Navigator.of(context).pop(result);
              });
            }
            on PlatformException catch (e) {
              print(e);
            } */
          validate(teamName.text).then((valid){
            if(valid) {
              ParseUser(null, null, null).loginAnonymous().then((response) {
                var user = response.result;
                user.set<String>("teamName", teamName.text);
                user.set<String>("name", userName.text);
                user.pin();
                user.save();
                Navigator.of(context).pop(response);
              });
            }
          });
        },)
    ];
    int teamFieldIndex = columnChildren.indexOf(teamNameField) + 1;
    int userFieldIndex = columnChildren.indexOf(userNameField) + 1;
    if(teamExists) {
      columnChildren.insert(teamFieldIndex, Align(alignment: Alignment.centerLeft, child:
          PopOver(text: "Team exists", popOverColor: Colors.green, brightness: Brightness.dark,)
      )
      );
    }
    else if(invalid) {
      columnChildren.insert(teamFieldIndex, Align(alignment: Alignment.centerLeft, child:
      PopOver(text: "Please enter a team name", popOverColor: Colors.red, brightness: Brightness.dark,)
      )
      );
    }
    else if(full) {
      columnChildren.insert(teamFieldIndex, Align(alignment: Alignment.centerLeft, child:
      PopOver(text: "That team is full", popOverColor: Colors.red, brightness: Brightness.dark,)
      )
      );
    }
    if(emptyName) {
      columnChildren.insert(userFieldIndex, Align(alignment: Alignment.centerLeft, child:
      PopOver(text: "Please enter your name", popOverColor: Colors.red, brightness: Brightness.dark,)
      )
      );
    }
    return WillPopScope(onWillPop: () => null, child: Scaffold(
        body: Builder(builder: (context) => Container(padding: MediaQuery.of(context).padding + EdgeInsets.all(10.0), child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,
            children: columnChildren)
        )
        )
        )
    )
    );
  }


  }
