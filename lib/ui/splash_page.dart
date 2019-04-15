import 'package:ease_life/index.dart';


class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Stack(
          children: <Widget>[
            Positioned.fill(child: Placeholder()),
            Align(
              alignment: Alignment.bottomCenter,
              child: OutlineButton(
                onPressed: () {
                  sharedPreferences.setBool(PreferenceKeys.keyFirstEntryTag, false);
                  Navigator.of(context).pushNamed("/");
                },
                child: Text("立即体验"),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text("安心居",),
            )
          ],
        ),
      ),
    );
  }
}
