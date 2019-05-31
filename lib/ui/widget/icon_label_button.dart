import 'package:ease_life/index.dart';

class IconLabelButton extends StatefulWidget {
  @override
  _IconLabelButtonState createState() => _IconLabelButtonState();
}

class _IconLabelButtonState extends State<IconLabelButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:(){

      },
      child: Padding(
        padding:
        const EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            SizedBox(
                width: ScreenUtil()
                    .setWidth(100),
                height: ScreenUtil()
                    .setWidth(100),
                child: Image.asset(
                  "images/ic_visitor_manager.png",
                )),
            Text("访客管理")
          ],
        ),
      ),
    );
  }
}
