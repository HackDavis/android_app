import 'package:flutter/cupertino.dart';
import 'package:parse_server_sdk/parse.dart';
import 'package:flutter/services.dart';
class Login extends StatefulWidget {
  @override
  LoginForm createState() => LoginForm();

}
class LoginForm extends State<Login> {
  TextEditingController userName = TextEditingController();
  static const platform = const MethodChannel('hackdavis.io/login');
  bool teamExists = false;
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    List<Widget> columnChildren = [
      CupertinoTextField(controller: userName,
        onChanged: (s) {
          if(teamExists) {
            setState(() => teamExists = false);
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
      CupertinoButton(child: Text("Login"),
        onPressed: () {
          try {
            platform.invokeMethod("loginAnonymous", <String, dynamic>{"teamName": userName.text}).then((result){
              Navigator.of(context).pop(result);
            });
          }
          on PlatformException catch(e) {
            print(e);
          }
        },)
    ];
    if(teamExists) {
      columnChildren.insert(1, Align(alignment: Alignment.centerLeft, child: Text("Team Exists",style: TextStyle(color: CupertinoColors.activeGreen),)));
    }
    return CupertinoPageScaffold(
        child: Builder(builder: (context) => Container(padding: MediaQuery.of(context).padding, child: Column(children: columnChildren)
        )
        )
    );
  }

}