import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


const GradientColorList = [
  Color(0x668900a1),
  Color(0x666c15b6),
  Color(0x663d52c9),
  Color(0x661d7ae1),
  Color(0x661496f1),
  Color(0x661496f1),
  Color(0x661496f1),
  Color(0x661496f1),
  Color(0x661496f1),
  Color(0x661496f1),
];

class EaseIconGradientButton extends StatelessWidget {
  final index;
  final text;
  final VoidCallback onPressed;
  final IconData icon;

  EaseIconGradientButton(this.index, this.text, this.onPressed, this.icon);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed??(){},
      splashColor: GradientColorList[index + 1],
      borderRadius: BorderRadius.horizontal(left: Radius.circular(100),right: Radius.circular(100)),
      child: Container(
        constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width/5
        ),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: GradientColorList.sublist(index, index + 2),
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: GradientColorList[index].withAlpha(0xcf),
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: GradientColorList[index].withBlue(0xff).withAlpha(0xa1),
                fontFamily: "Determination",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EaseIconButton extends StatelessWidget {
  final String assetImageUrl;
  final String buttonLabel;
  final VoidCallback onPressed;
  final IconData iconData;
  final Color iconColor;

  const EaseIconButton({
    Key key,
    this.assetImageUrl,
    this.buttonLabel,
    this.onPressed,
    this.iconData,
    this.iconColor,
  })  : assert(iconData != null || assetImageUrl != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              SizedBox(
                width: ScreenUtil().setWidth(100),
                height: ScreenUtil().setWidth(100),
                child: assetImageUrl != null
                    ? Image.asset(
                        assetImageUrl,
                      )
                    : Icon(
                        iconData,
                        color: iconColor,
                      ),
              ),
              Text(
                buttonLabel,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class EaseTile extends StatelessWidget {
  final String title;
  final IconData iconData;
  final VoidCallback onPressed;
  final int badge;

  const EaseTile(
      {Key key, this.title, this.iconData, this.onPressed, this.badge = 0})
      : super(key: key);

  static  double kBadgeSize = ScreenUtil().setWidth(0);
  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: onPressed ?? () {},
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        child: Material(
          elevation: 1,
          color: Colors.white,
          child: Stack(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: <Widget>[
                    Icon(iconData),
                    SizedBox(
                      width: 16,
                    ),
                    Expanded(
                      child: Text(title ?? ""),
                    ),
                  ],
                ),
              ),
              (badge == null || badge == 0)
                  ? Container()
                  : Align(
                      alignment: Alignment.topRight,
                      child: Transform.translate(
                        child: Container(
                          padding: EdgeInsets.all(4),
                          constraints: BoxConstraints(
                            minWidth: kBadgeSize,
                            minHeight: kBadgeSize,
                          ),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Colors.red),
                          child: Text(
                            badge<10?" $badge":badge>99?"99+":badge.toString(),
                            style: Theme.of(context).textTheme.caption.copyWith(
                                  color: Colors.white,
                                ),
                          ),
                        ),
                        offset: Offset(6, -6),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class EaseGrid extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final bool start;
  final bool end;

  const EaseGrid({
    Key key,
    this.title,
    this.onPressed,
    this.start = false,
    this.end = false,
  })  : assert(start != null),
        assert(end != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed ?? () {},
      child: Container(
        margin: EdgeInsets.only(
            left: start ? 16 : 3, right: end ? 16 : 3, top: 4, bottom: 4),
        child: Material(
          elevation: 1,
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(12)),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.blueGrey,
                          offset: Offset(-1, -1),
                          blurRadius: 1)
                    ],
                  ),
                  height: 6,
                  width: 6,
                ),
                Expanded(
                  child: Text(
                    title ?? "",
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EaseTitle extends StatelessWidget {
  final String title;
  final int badge;

  final String subtitle;

  const EaseTitle({Key key, this.title, this.badge = 0, this.subtitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        margin: EdgeInsets.only(left: 8, right: 8, top: 4),
        child: Material(
          elevation: 1,
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12), topRight: Radius.circular(12)),
          child: Stack(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 2,
                      constraints: BoxConstraints(minHeight: 12),
                      color: Colors.deepPurpleAccent,
                      margin: EdgeInsets.all(6),
                    ),
                    SizedBox(
                      width: 6,
                    ),
                    Text(title ?? ""),
                    SizedBox(
                      width: 6,
                    ),
                    Expanded(
                      child: Text(
                        subtitle ?? "",
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
                  ],
                ),
              ),
              (badge == null || badge == 0)
                  ? Container()
                  : Align(
                      alignment: Alignment.topRight,
                      child: Transform.translate(
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Colors.red),
                          child: Text(
                            badge.toString(),
                            style: Theme.of(context).textTheme.caption.copyWith(
                                  color: Colors.white,
                                ),
                          ),
                        ),
                        offset: Offset(6, -6),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

final colorTween = ColorTween(begin: Colors.lightBlue, end: Colors.purple);
List<Color> colorList = List.generate(4, (int index) {
  return colorTween.transform((index + 1) / 4);
});

class EaseChip extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final int index;

  const EaseChip({Key key, this.text, this.onPressed, this.index = 0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed ?? () {},
      child: Container(
        constraints:
            BoxConstraints(minWidth: MediaQuery.of(context).size.width / 4),
        margin: EdgeInsets.only(left: 5, right: 5, top: 6),
        decoration: BoxDecoration(
          color: colorList[index].withAlpha(0xcf),
          borderRadius: BorderRadius.all(Radius.circular(8)),
          gradient: LinearGradient(colors: [
            colorList[index].withAlpha(0xdd),
            colorList[index + 1].withAlpha(0xdd),
          ], stops: [
            0.2,
            0.99
          ]),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[300],
              offset: Offset(1, 1),
            ),
          ],
        ),
        padding: EdgeInsets.all(6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.blueGrey,
                      offset: Offset(-1, -1),
                      blurRadius: 1)
                ],
              ),
              height: 6,
              width: 6,
            ),
            SizedBox(
              width: 6,
            ),
            Text(
              text,
              style: Theme.of(context)
                  .textTheme
                  .caption
                  .copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class EaseTitleWrap extends StatelessWidget {
  final List<Widget> children;

  const EaseTitleWrap({Key key, this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        elevation: 1,
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 8, left: 8, right: 8),
          child: Wrap(
            alignment: WrapAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }
}
