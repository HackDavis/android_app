import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse.dart';
import 'package:flutter/services.dart';
import 'PopOver.dart';
class Login extends StatefulWidget {
  @override
  LoginForm createState() => LoginForm();

}
class LoginForm extends State<Login> {
  TextEditingController userName = TextEditingController();
  static const platform = const MethodChannel('hackdavis.io/login');
  bool teamExists = false;
  bool invalid = false;
  bool full = false;
  @override
  void initState() {
    super.initState();
  }

  Future<bool> validate(s) {
    if(userName.text.length == 0) {
      setState(() => invalid = true);
      return Future.value(false);
    }
    var query = QueryBuilder<ParseObject>(ParseObject("_User"));
    query.whereEqualTo("teamName", userName.text);
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
        return Future.value(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> columnChildren = [
      TextField(controller: userName,
        onChanged: (s) {
          if(teamExists || invalid || full) {
            setState(() {
              teamExists = false;
              invalid = false;
              full = false;
            });
          }
        },
        onSubmitted: validate,),
      FlatButton(child: Text("Login", style: Theme.of(context).textTheme.button),
        onPressed: () {
            /*try {
              platform.invokeMethod("loginAnonymous",
                  <String, dynamic>{"teamName": userName.text}).then((result) {
                              Navigator.of(context).pop(result);
              });
            }
            on PlatformException catch (e) {
              print(e);
            } */
          validate(userName.text).then((valid){
            if(valid) {
              ParseUser(null, null, null).loginAnonymous().then((response) {
                var user = response.result;
                user.set<String>("teamName", userName.text);
                user.pin();
                user.save();
                Navigator.of(context).pop(response);
              });
            }
          });
        },)
    ];
    if(teamExists) {
      columnChildren.insert(1, Align(alignment: Alignment.centerLeft, child:
          PopOver(text: "Team exists", popOverColor: Colors.green, brightness: Brightness.dark,)
      )
      );
    }
    else if(invalid) {
      columnChildren.insert(1, Align(alignment: Alignment.centerLeft, child:
      PopOver(text: "Please enter a team name", popOverColor: Colors.red, brightness: Brightness.dark,)
      )
      );
    }
    else if(full) {
      columnChildren.insert(1, Align(alignment: Alignment.centerLeft, child:
      PopOver(text: "That team is full", popOverColor: Colors.red, brightness: Brightness.dark,)
      )
      );
    }
    return WillPopScope(onWillPop: () => null, child: Scaffold(
        body: Builder(builder: (context) => Container(padding: MediaQuery.of(context).padding + EdgeInsets.all(10.0), child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: columnChildren)
        )
        )
        )
    )
    );
  }


  }
