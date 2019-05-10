import 'dart:io';

import 'package:amap_base_location/amap_base_location.dart';
import 'package:ease_life/ui/camera_page.dart';
import 'package:ease_life/ui/web_view_example.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'index.dart';
import 'ui/login_page.dart';

List<Color> colors = [
  Color(0xfffb333d),
  Color(0xff3d5ffe),
  Color(0xff16a723),
  Color(0xfffebf1f),
];

typedef OnFileProcess = Function(Future<File>, File localFile);

void showImageSourceDialog(File file, BuildContext context,
    ValueCallback onValue, OnFileProcess onFileProcess) {
  FocusScope.of(context).requestFocus(FocusNode());
  showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
            onClosing: () {},
            builder: (context) {
              return LayoutBuilder(
                builder: (context, constraint) {
                  return IntrinsicHeight(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                              showPicker(file, onFileProcess);
                            },
                            child: Container(
                              width: constraint.biggest.width,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(18.0),
                              child: Text("相册"),
                            )),
                        InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                              showCameraPicker(file, onFileProcess);
                            },
                            child: Container(
                              width: constraint.biggest.width,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(18.0),
                              child: Text("拍照"),
                            )),
                      ],
                    ),
                  );
                },
              );
            });
      }).then((v) {
    onValue(v);
  });
}

void showPicker(File file, OnFileProcess onFileProcess) {
  var future = ImagePicker.pickImage(source: ImageSource.gallery);
  onFileProcess(future, file);
}

void showCameraPicker(File file, OnFileProcess onFileProcess) {
  var future = ImagePicker.pickImage(source: ImageSource.camera);
  onFileProcess(future, file);
}

void showCamera(File file, OnFileProcess onFileProcess, BuildContext context) {
  var future =
      Navigator.of(context).push<File>(MaterialPageRoute(builder: (context) {
    return CameraPage(
      capturedFile: file,
    );
  }));
  onFileProcess(future, file);
}

void startAudioRecord() {}

//只能作用于带exif的image
Future<File> rotateWithExifAndCompress(File file) async {
  if (!Platform.isAndroid) {
    return FlutterImageCompress.compressWithFile(file.path).then((listInt) {
      if (listInt == null) {
        return null;
      }
      file.writeAsBytesSync(listInt, flush: true, mode: FileMode.write);
      return file;
    });
  }
  return Future.value(file).then((file) {
    if (file == null) {
      return null;
    }
    //通过exif旋转图片
    return FlutterExifRotation.rotateImage(path: file.path);
  }).then((f) {
    //压缩图片
    return FlutterImageCompress.compressWithFile(
      f.path,
      quality: 80,
    );
  }).then((listInt) {
    if (listInt == null) {
      return null;
    }
    file.writeAsBytesSync(listInt, flush: true, mode: FileMode.write);
    return file;
  });
}

Widget buildVisitor(BuildContext context) {
  return GestureDetector(
    onTap: () {
      Navigator.of(context).pushNamed(LoginPage.routeName);
    },
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.sms_failed,
            color: Colors.blue,
            size: 40,
          ),
          SizedBox(
            height: 12,
          ),
          Text(
            "未登录,点击登录",
            style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 17,
                color: Colors.grey[700]),
          ),
        ],
      ),
    ),
  );
}

Future<Location> getLocation() async {
  return AMapLocation().getLocation(LocationClientOptions());
}

///
/// 先获取index数据在导航到指定的webview
///
void routeToWebIndex(BuildContext context, String indexId,
    {bool refresh = true}) {
  getIndex(refresh).then((list) {
    return list.firstWhere((index) {
      return index.area == "mine";
    }, orElse: () {
      return null;
    });
  }).then((index) {
    if (index == null) {
      Fluttertoast.showToast(msg: "获取路由数据失败");
    } else {
      routeToWeb(context, indexId, index);
    }
  });
}

List<Index> indexInfo;

Future<List<Index>> getIndex(bool refresh) {
  return (refresh || indexInfo == null || indexInfo.length == 0)
      ? Api.getIndex().then((v) {
          indexInfo = v;
          return v;
        })
      : Future.value(indexInfo);
}

void routeToWeb(BuildContext context, String id, Index index) {
  var indexWhere = index.menu.indexWhere((i) => i.id == id);
  if (indexWhere < 0) {
    return;
  }
  var url = index.menu[indexWhere].url;
  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
    return WebViewExample(url);
  }));
}
