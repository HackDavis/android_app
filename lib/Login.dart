import 'package:flutter/cupertino.dart';
import 'package:parse_server_sdk/parse.dart';
class Login extends StatefulWidget {
  @override
  LoginForm createState() => LoginForm();

}
class LoginForm extends State<Login> {
  TextEditingController userName = TextEditingController();
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        child: Builder(builder: (context) => Container(padding: MediaQuery.of(context).padding, child: Column(children: [
          CupertinoTextField(placeholder: "Team Name", controller: userName),
          CupertinoButton(child: Text("Login"), onPressed: () {
            var query = QueryBuilder<ParseObject>(ParseObject("_User"));
            query.whereEqualTo("teamName", userName.text);
            query.query().then((response) {
              print(response.result);
            });
            var user = ParseUser(userName.text, null, null);
            /*user.login().then((response) {
              print(response);
              Navigator.pop(context);
            });*/

          },)
        ])
        )
        )
    );
  }

}