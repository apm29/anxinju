import 'package:ease_life/bloc/bloc_provider.dart';
import 'package:ease_life/model/base_response.dart';
import 'package:flutter/material.dart';

class PersonalInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("个人信息"),),
      body: StreamBuilder<UserInfo>(
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Center(
              child: GestureDetector(
                onTap: (){
                  Navigator.of(context).pushNamed("/verify",arguments: snapshot.data);
                },
                child: Text("""
                用户名:${snapshot.data.userName}
                电话:${snapshot.data.mobile}
                用户ID:${snapshot.data.userId}
                认证状态:${snapshot.data.isCertification}
                """),
              ),
            );
          } else {
            return CircularProgressIndicator();
          }
        },
        stream: BlocProviders.of<ApplicationBloc>(context).currentUser,
      ),
    );
  }
}
