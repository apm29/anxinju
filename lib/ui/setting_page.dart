import 'package:ease_life/index.dart';
import 'package:ease_life/model/notification_model.dart';
import 'package:ease_life/ui/widget/ease_widget.dart';
import 'package:flutter/material.dart';

class SettingPage extends StatelessWidget {
  static String routeName = "/setting";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("设置"),
      ),
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(vertical: 6, horizontal: 0),
            child: Material(
              color: Colors.white,
              elevation: 1,
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 24,
                  ),
                  Text("消息提醒"),
                  Expanded(
                    child: SizedBox(
                      width: 24,
                    ),
                  ),
                  Consumer<NotificationModel>(
                    builder: (BuildContext context, NotificationModel model,
                        Widget child) {
                      return Switch(
                        value: model.messageSound,
                        onChanged: (bool) {
                          model.messageSound = bool;
                        },
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
