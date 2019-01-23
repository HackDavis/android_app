import 'package:flutter/cupertino.dart';
class Badges extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Badges'),
        ),
        child: Builder(builder: (context) => Container(padding: MediaQuery.of(context).padding, child: GridView(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3))
    )
    )
    );
  }
}