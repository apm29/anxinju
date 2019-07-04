import 'package:ease_life/index.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (context, constraint) {
        return SizedBox(
          width: constraint.biggest.width,
          child: Stack(
            children: <Widget>[
              Positioned.fill(child: Image.asset("images/splash.png")),
              SafeArea(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(child: Container()),
                      Expanded(
                        child: Container(),
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      LayoutBuilder(
                        builder: (context, constraint) {
                          return SizedBox(
                            width: constraint.biggest.width,
                            child: Container(
                              margin: EdgeInsets.all(16),
                              child: OutlineButton(
                                borderSide:
                                    BorderSide(color: Colors.greenAccent),
                                onPressed: () {
                                  appSp.setBool(
                                      PreferenceKeys.keyFirstEntryTag, false);
                                  Navigator.of(context)
                                      .pushReplacementNamed("/");
                                },
                                child: Text(
                                  "立即体验",
                                  style: TextStyle(color: Colors.greenAccent),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      }),
    );
  }
}
