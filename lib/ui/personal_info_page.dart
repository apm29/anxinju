import 'package:ease_life/bloc/bloc_provider.dart';
import 'package:ease_life/model/base_response.dart';
import 'package:flutter/material.dart';

class PersonalInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("个人信息"),),
      body: StreamBuilder<UserInfoData>(
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Center(
              child: GestureDetector(
                onTap: (){
                  Navigator.of(context).pushNamed("/verify",arguments: snapshot.data);
                },
                child: Text("""
                用户名:${snapshot.data.userInfo.userName}
                电话:${snapshot.data.userInfo.mobile}
                用户ID:${snapshot.data.userInfo.userId}
                认证状态:${snapshot.data.userInfo.isCertification}
                """),
              ),
            );
          } else {
            return CircularProgressIndicator();
          }
        },
        stream: Stream.fromFuture(BlocProvider.of(context).getUserInfoData()),
      ),
    );
  }
}
