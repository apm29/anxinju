import 'package:ease_life/model/service_chat_model.dart';
import 'package:ease_life/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';

import '../utils.dart';

class ServiceChatPage extends StatefulWidget {
  static const String routeName = "/service_chat";

  @override
  _ServiceChatPageState createState() => _ServiceChatPageState();
}

class _ServiceChatPageState extends State<ServiceChatPage>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                ServiceChatModel.of(context).addUser(ChatUser(
                  "12121212121",
                  "http://axjkftest.ciih.net/uploads/20190429/16b340aa523c582f5f43eca7e4df8963.png",
                  "阿萨德",
                ));
              }),
        ],
      ),
      body: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    var userCount = ServiceChatModel.of(context).userCount;
    if (userCount == 0) {
      return Center(
        child: Text("暂无用户连接"),
      );
    }
    var _tabController = TabController(length: userCount, vsync: this);
    return Consumer<ServiceChatModel>(
      builder: (BuildContext context, ServiceChatModel serviceChatModel,
          Widget child) {
        return SingleChildScrollView(
          child: Column(
            children: <Widget>[
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.deepOrangeAccent,
                labelColor: Colors.white,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    )),
                tabs: serviceChatModel.currentChatUsers
                    .map((user) => Tab(
                          text: user.userName,
                          icon: SizedBox(
                            height: ScreenUtil().setHeight(120),
                            width: ScreenUtil().setHeight(120),
                            child: Image.network(
                              user.userAvatar,
                              loadingBuilder: imagePlaceHolder,
                            ),
                          ),
                        ))
                    .toList(),
                isScrollable: true,
              ),
            ],
          ),
        );
      },
    );
  }
}
