import 'package:ease_life/index.dart';

class NotFoundPage extends StatefulWidget {

  final String routeName;

  const NotFoundPage({Key key, this.routeName}) : super(key: key);

  @override
  _NotFoundPageState createState() => _NotFoundPageState();
}

class _NotFoundPageState extends State<NotFoundPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PageNotFound"),
      ),
      body: Center(
        child: Text("404\nPAGE NOT FOUND \nRoute Name: ${widget.routeName}",textAlign: TextAlign.center,),
      ),
    );
  }
}
