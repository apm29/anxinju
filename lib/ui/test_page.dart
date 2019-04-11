import 'package:ease_life/bloc/bloc_provider.dart';
import 'package:ease_life/model/base_response.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var applicationBloc = BlocProviders.of<ApplicationBloc>(context);
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: StreamBuilder<UserInfo>(
            stream: applicationBloc.currentUser,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return snapshot.data.loading()
                    ? CircularProgressIndicator()
                    : FlatButton(
                        onPressed: () {
                          applicationBloc.logout();
                        },
                        child: Text("logout ${snapshot.data.toString()}"));
              } else {
                if (snapshot.hasError) {
                  Fluttertoast.showToast(msg: snapshot.error);
                }
                return FlatButton(
                    onPressed: () {
                      applicationBloc.login("apm29", "123456");
                    },
                    child: Text("login"));
              }
            }),
      ),
    );
  }
}
