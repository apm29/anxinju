import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';

void main() async {
//  File file = File("yjw.jpg");
//  if(! await file.exists()){
//    file.createSync();
//  }
//  var base64 = await getImageBase64(file);
//  File txt = File("base.txt");
//  if(! await txt.exists()){
//    txt.createSync();
//  }
//  txt.writeAsStringSync(base64,flush: true,mode: FileMode.write);
//  //Dio().post("http://192.168.0.20:8089/facecompare/compare/",data: FormData.from({
//  //  'idNo':"330681199112151718",
//  //  'imageBase64str':base64
//  //})).then((resp){
//  //  print('${resp.data.toString()}');
//  //});

  var str = "2019-07-28 11:28:08";
  var dateTime = DateTime.parse(str);
  var now = DateTime.now();
  var inDays = dateTime.difference(now).inDays;
  print(inDays.abs());
//  getRange(1, 2).forEach(print);
//  print('---');
//  getStreamInt(1, 10).listen(print);
}

Future<String> getImageBase64(File file) async {
  return file.readAsBytes().then((bytes) {
    return "data:image/jpeg;base64,${base64Encode(bytes)}";
  });
}

Iterable<int> getRange(int start, int finish) sync* {
  if (start <= finish) {
    yield start;
    yield* getRange(start + 1, finish);
  }
}

Stream<int> getStreamInt(int start, int finish)async*{
  if (start <= finish) {
    yield start;
    yield* getStreamInt(start + 1, finish);
  }
}
