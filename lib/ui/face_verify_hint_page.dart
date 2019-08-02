import 'dart:async';
import 'dart:io';

import 'package:ease_life/model/base_response.dart';
import 'package:ease_life/model/user_model.dart';
import 'package:ease_life/remote/api.dart';
import 'package:ease_life/res/configs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'house_member_apply_page.dart';
import 'main_page.dart';
import 'widget/gradient_button.dart';

class FaceVerifyHintPage extends StatelessWidget {
  FaceVerifyHintPage() : super();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        return Consumer<FaceVerifyHintModel>(
          builder:
              (BuildContext context, FaceVerifyHintModel model, Widget child) {
            return Scaffold(
              backgroundColor: Colors.grey[300],
              body: Container(
                padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Material(
                      elevation: 5,
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(8)),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              color: Colors.transparent,
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Image.asset(
                                  'images/ic_face_id.png',
                                  height: 32,
                                  width: 32,
                                ),
                                SizedBox(
                                  width: 12,
                                ),
                                Icon(Icons.compare_arrows),
                                SizedBox(
                                  width: 12,
                                ),
                                Material(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4)),
                                  clipBehavior: Clip.antiAlias,
                                  child: Image.file(
                                    model.faceImageFile,
                                    height: 32,
                                    width: 32,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            model.failed
                                ? Container()
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      model.faceVerifyStatus != null
                                          ? Text.rich(
                                              TextSpan(
                                                text: "人脸对比结果:",
                                                children: [
                                                  TextSpan(
                                                    text:
                                                        "${model.faceVerifyStatus.getVerifyText()}",
                                                    style: TextStyle(
                                                      color: model.faceVerifyStatus
                                                                  ?.isVerified() ??
                                                              false
                                                          ? Colors.green
                                                          : Colors.redAccent,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )
                                          : Text("人脸对比中.."),
                                      SizedBox(
                                        width: 12,
                                      ),
                                      (model.faceVerifyStatus != null &&
                                                  !(model.faceVerifyStatus
                                                      .isInVerify())) ||
                                              model.faceVerifyStatus == null
                                          ? Container()
                                          : SizedBox(
                                              height:
                                                  ScreenUtil().setHeight(50),
                                              width: ScreenUtil().setHeight(50),
                                              child:
                                                  CircularProgressIndicator(),
                                            )
                                    ],
                                  )
                          ],
                        ),
                      ),
                    ),
                    (model.faceVerifyStatus != null &&
                                (model.faceVerifyStatus.isInVerify())) ||
                            model.faceVerifyStatus == null
                        ? Container()
                        : Material(
                            elevation: 5,
                            borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(8)),
                            color: Colors.white,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 24, horizontal: 16),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    color: Colors.transparent,
                                  ),
                                  SizedBox(
                                    height: 12,
                                  ),
                                  Text(
                                    model.houseTitle,
                                    style: Theme.of(context).textTheme.title,
                                  ),
                                  SizedBox(
                                    height: 12,
                                  ),
                                  model.loading
                                      ? LinearProgressIndicator()
                                      : Text(
                                          model.resultText,
                                          style:
                                              Theme.of(context).textTheme.body1,
                                        ),
                                  SizedBox(
                                    height: 12,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox(
                                        width: 12,
                                      ),
                                      model.failed || model.verifyFinished
                                          ? GradientButton(
                                              Text("返回主页"),
                                              onPressed: () async {
                                                await UserModel.of(context)
                                                    .refreshUserData(context);
                                                model.goHome(context);
                                              },
                                            )
                                          : Container(),
                                      SizedBox(
                                        width: 12,
                                      ),
                                      model.needApply && model.verifyFinished
                                          ? GradientButton(
                                              Text("申请成为家庭成员"),
                                              onPressed: () async {
                                                await UserModel.of(context)
                                                    .refreshUserData(context);
                                                Navigator.of(context).pushNamed(
                                                    MemberApplyPage.routeName);
                                              },
                                            )
                                          : Container(),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class FaceVerifyHintModel extends ChangeNotifier {
  final File faceImageFile;
  final bool isAgain;
  final String idCard;

  FaceVerifyHintModel(this.faceImageFile, this.isAgain, this.idCard) {
    startVerify(faceImageFile, isAgain, idCard);
  }

  Future startVerify(File faceImageFile, bool isAgain, String idCard) async {
    verifyFinished = false;
    bool success = await houseVerify(faceImageFile, idCard, isAgain);
    if (success) {
      await faceVerify();
      verifyFinished = true;
    }
  }

  String _houseTitle;
  String _resultText;
  UserVerifyStatus _faceVerifyStatus;
  bool _loading = true;
  bool _failed = false;
  bool _verifyFinished = false;
  bool _needApply = false;

  UserVerifyStatus get faceVerifyStatus => _faceVerifyStatus;

  set faceVerifyStatus(UserVerifyStatus value) {
    _faceVerifyStatus = value;
    notifyListeners();
  }

  bool get needApply => _needApply;

  set needApply(bool value) {
    _needApply = value;
    notifyListeners();
  }

  bool get verifyFinished => _verifyFinished;

  set verifyFinished(bool value) {
    _verifyFinished = value;
    notifyListeners();
  }

  bool get failed => _failed;

  set failed(bool value) {
    _failed = value;
    notifyListeners();
  }

  String get houseTitle => _houseTitle;

  set houseTitle(String value) {
    _houseTitle = value;
    notifyListeners();
  }

  String get resultText => _resultText;

  set resultText(String value) {
    _resultText = value;
    notifyListeners();
  }

  bool get loading => _loading;

  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future houseVerify(File faceImageFile, String idCard, bool isAgain) async {
    houseTitle = "正在上传人脸图片";
    loading = true;
    var respFile = await Api.uploadPic(faceImageFile.path);
    if (respFile.success) {
      houseTitle = "正在对比身份证";
      loading = true;
      BaseResponse<UserVerifyInfo> respFace =
          await Api.verify(respFile.data.orginPicPath, idCard, isAgain);
      loading = false;
      if (respFace.success) {
        houseTitle = "对比身份证成功";
        if ((respFace.data.rows?.length ?? 0) == 0) {
          //无房
          resultText = '${respFace.text}';
          needApply = true;
          return true;
        } else {
          resultText = respFace.data.rows
              .map((h) =>
                  "成为: ${h.addr} 的 ${h.isHouseOwner ? "${Strings.hostClass}" : "成员"}")
              .join(",\n");
          return true;
        }
      } else {
        failed = true;
        houseTitle = "对比身份证失败";
        resultText = '${respFace.text}';
        return false;
      }
    } else {
      failed = true;
      houseTitle = "上传人脸失败";
      resultText = '${respFile.text}';
      loading = false;
      return false;
    }
  }

  Future faceVerify() async {
    int count = 4;
    while (count >= 0) {
      try {
        count--;
        var response = await Api.getUserVerify();
        faceVerifyStatus = response.data;
        if (response.success && !response.data.isInVerify()) {
          verifyFinished = true;
          continue;
        }
        await Future.delayed(Duration(milliseconds: 2000));
      } catch (e) {
        print(e);
        continue;
      }
    }
  }

  void goHome(BuildContext context) {
    Navigator.of(context)
        .popUntil((s) => s.settings.name == MainPage.routeName);
  }
}
