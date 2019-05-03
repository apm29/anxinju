import 'dart:io';

import 'package:ease_life/ui/camera_page.dart';
import 'package:image_picker/image_picker.dart';

import 'index.dart';
typedef OnFileProcess = Function(Future<File>,File localFile);
void showImageSourceDialog(
    File file,BuildContext context,ValueCallback onValue,OnFileProcess onFileProcess) {
  showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
            onClosing: () {},
            builder: (context) {
              return IntrinsicHeight(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          showPicker(file, onFileProcess);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("相册"),
                        )),
                    FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          showCamera(file, onFileProcess,context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("拍照"),
                        )),
                  ],
                ),
              );
            });
      }).then((v) {
      onValue(v);
  });
}

void showPicker(File file, OnFileProcess onFileProcess) {
  var future = ImagePicker.pickImage(source: ImageSource.gallery);
  onFileProcess(future,file);
}

void showCamera(File file,OnFileProcess onFileProcess,BuildContext context) {
  var future =
  Navigator.of(context).push<File>(MaterialPageRoute(builder: (context) {
    return CameraPage(
      capturedFile: file,
    );
  }));
  onFileProcess(future,file);
}


void startAudioRecord(){

}
