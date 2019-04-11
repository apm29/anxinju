import 'package:ease_life/bloc/bloc_provider.dart';
import 'package:ease_life/bloc/user_bloc.dart';
import 'package:flutter/material.dart';

class AuthorizationPage extends StatefulWidget {
  @override
  _AuthorizationPageState createState() => _AuthorizationPageState();
}

class _AuthorizationPageState extends State<AuthorizationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("认证"),
      ),
      body: buildBody(),
    );
  }

  buildBody() {
    return Container();
//    return StreamBuilder<BlocData>(
//      builder: (context, snapshot) {
//        if (snapshot.data.init()) {
//          return OutlineButton(
//            child: Text("认证"),
//            onPressed: () {
//              BlocProvider.of(context)
//                  .verify("3323424234234", "http://www.baidu.com");
//            },
//          );
//        } else if (snapshot.data.loading()) {
//          return OutlineButton(
//            child: CircularProgressIndicator(),
//            onPressed: () {},
//          );
//        } else if (snapshot.data.error()) {
//          return OutlineButton(
//            child: Text("认证"),
//            onPressed: () {
//              BlocProvider.of(context)
//                  .verify("3323424234234", "http://www.baidu.com");
//            },
//          );
//        } else if (snapshot.data.success()) {
//          return OutlineButton(
//            child: Text("认证结果:${snapshot.data.response}"),
//            onPressed: () {
//              BlocProvider.of(context)
//                  .verify("3323424234234", "http://www.baidu.com");
//            },
//          );
//        }
//      },
//      stream: BlocProvider.of(context).verifyStream,
//      initialData: BlocData.init(),
//    );
  }
}
