import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

class Triangle extends CustomPainter {
  final Color color;
  Triangle(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    var paint = new Paint()
      ..color = this.color
      ..style = PaintingStyle.fill;

    Offset centerTop = new Offset(size.width / 2, 0);
    Offset triangleLeft = centerTop - new Offset(10.0, 0);
    Offset triangleRight = centerTop + new Offset(10.0, 0);
    Offset triangleTop = centerTop - new Offset(0, 10.0);

    Path triangle = new Path()
      ..addPolygon([triangleLeft, triangleTop, triangleRight, triangleLeft], true);
    canvas.drawPath(triangle, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class PopOver extends StatelessWidget {
  final Brightness brightness;
  final Color popOverColor;
  final String text;
  PopOver({@required this.text, this.brightness, this.popOverColor});
  @override
  Widget build(BuildContext context) {
    Color pColor = popOverColor;
    if(pColor == null) {
      pColor = Color.fromRGBO(0, 0, 0, 0.3);
    }
    Color textColor = Color.fromRGBO(0, 0, 0, 1);
    if(this.brightness == Brightness.dark) {
      textColor = Color.fromRGBO(255, 255, 255, 1);
    }
    return Padding(padding: EdgeInsets.only(top: 10.0), child: CustomPaint(
        foregroundPainter: Triangle(pColor),
        child:

        DecoratedBox(decoration: BoxDecoration(color: this.popOverColor,
            borderRadius: BorderRadius.circular(5.0)),
            child: Padding(padding: EdgeInsets.all(10.0) , child: Text(this.text,style: TextStyle(color: textColor),)
            )
        )
    )
    );
  }

}