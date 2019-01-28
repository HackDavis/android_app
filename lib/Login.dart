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
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    List<Widget> columnChildren = [
      TextField(controller: userName,
        onChanged: (s) {
          if(teamExists || invalid) {
            setState(() {
              teamExists = false;
              invalid = false;
            });
          }
        },
        onSubmitted: (s){
          var query = QueryBuilder<ParseObject>(ParseObject("_User"));
          query.whereEqualTo("teamName", userName.text);
          query.query().then((response) {
            if(response.result != null) {
              setState(() => teamExists = true);
            }
          });
        },),
      FlatButton(child: Text("Login", style: Theme.of(context).textTheme.button),
        onPressed: () {
          if(userName.text.length == 0) {
            setState(() {
              invalid = true;
            });
          }
          else {
            try {
              platform.invokeMethod("loginAnonymous",
                  <String, dynamic>{"teamName": userName.text}).then((result) {
                              Navigator.of(context).pop(result);
              });
            }
            on PlatformException catch (e) {
              print(e);
            }
          }
        },)
    ];
    if(teamExists) {
      columnChildren.insert(1, Align(alignment: Alignment.centerLeft, child:
          PopOver(text: "Team Exists", popOverColor: Colors.green, brightness: Brightness.dark,)
      )
      );
    }
    else if(invalid) {
      columnChildren.insert(1, Align(alignment: Alignment.centerLeft, child:
      PopOver(text: "Please Enter a Team Name", popOverColor: Colors.red, brightness: Brightness.dark,)
      )
      );
    }
    return WillPopScope(onWillPop: () => null, child: Scaffold(
        body: Builder(builder: (context) => Container(padding: MediaQuery.of(context).padding, child: Column(children: columnChildren)
        )
        )
    )
    );
  }


  }
