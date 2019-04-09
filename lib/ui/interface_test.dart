import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

var dio = Dio();

class InterfacePage extends StatefulWidget {
  @override
  _InterfacePageState createState() => _InterfacePageState();
}

class _InterfacePageState extends State<InterfacePage> {
  String resText;
  bool loading = false;
  var controller = TextEditingController();
  var controllerMobile = TextEditingController();
  String userId;
  @override
  Widget build(BuildContext context) {
    dio.options.baseUrl = "http://192.168.0.140:8080/permission/";
    dio.options.responseType = ResponseType.json;

    return Scaffold(
      appBar: AppBar(
        title: Text("接口测试"),
      ),
      body: Stack(
        children: <Widget>[
          loading
              ? Positioned.fill(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : Container(),
          ListView(
            children: <Widget>[
              Text(resText ?? "empty"),
              TextField(controller: controllerMobile,decoration: InputDecoration.collapsed(hintText: "输入手机号"),),
              RaisedButton(
                onPressed: () async {
                  setState(() {
                    loading = true;
                  });
                  Response<String> response =
                      await dio.post<String>("/user/getVerifyCode",
                          data: FormData.from({
                            "mobile": controllerMobile.text,
                          }));

                  setState(() {
                    resText = response.data;
                    loading = false;
                  });
                },
                child: Text("send sms"),
              ),
              TextField(controller: controller,decoration: InputDecoration.collapsed(hintText: "输入验证码"),),
              RaisedButton(
                onPressed: () async {
                  setState(() {
                    loading = true;
                  });
                  Response<Map> response = await dio.post<Map>("/user/register",
                      data: FormData.from({
                        "mobile": controllerMobile.text,
                        "userName": "apm29",
                        "password": "123456",
                        "code": controller.text,
                      }));

                  setState(() {
                    resText = response.data.toString();
                    loading = false;
                  });
                },
                child: Text("register"),
              ),
              RaisedButton(
                onPressed: () async {
                  setState(() {
                    loading = true;
                  });
                  Response<Map> response = await dio.post<Map>("/fastLogin",
                      data: FormData.from({
                        "mobile": controllerMobile.text,
                        "verifyCode": controller.text,
                      }));

                  setState(() {
                    resText = response.data.toString();
                    loading = false;
                  });
                },
                child: Text("fastLogin"),
              ),
              RaisedButton(
                onPressed: () async {
                  setState(() {
                    loading = true;
                  });
                  Response<Map> response = await dio.post<Map>("/login",
                      data: FormData.from({
                        "userName": "apm29",
                        "password": "123456",
                      }));

                  setState(() {
                    resText = response.data.toString();
                    if(response.data["status"]=="1")
                      userId = response.data["token"];
                    loading = false;
                  });
                },
                child: Text("login"),
              ),
              RaisedButton(
                onPressed: () async {
                  setState(() {
                    loading = true;
                  });
                  dio.options.headers = {
                    "Authorization": userId,
                  };
                  Response<Map> response = await dio.post<Map>("/user/getUserInfo");
                  setState(() {
                    resText = response.data.toString();
                    loading = false;
                  });
                },
                child: Text("getUserInfo"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
