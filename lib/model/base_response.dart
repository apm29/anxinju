import 'package:json_annotation/json_annotation.dart';
part 'base_response.g.dart';

///
/// {
/// "status": "1",
/// "data": {
///   "userInfo": {
///     "userId": "15547121604619016242",
///     "userName": "apm29",
///     "mobile": "17376508275",
///     "isCertification": 0
///   }
/// },
/// "token": "eyJhbGciOiJIUzI1NiJ9.eyJhbnhpbmp1IjoiMTU1NDcxMjE2MDQ2MTkwMTYyNDIiLCJjcmVhdGVkIjoxNTU0NzEzNjMwOTY0LCJleHAiOjE5ODY3MTM2MzB9.WRVxO1U8mV-EDriA2hh71XFEDUy9rMVBTUau6fTENL8",
/// "text": ""
/// }
///
@JsonSerializable()
class BaseResponse{
  String status;
  Map<String,dynamic> data;
  String token;
  String text;

  factory BaseResponse.fromJson(Map<String,dynamic> json){
    return _$BaseResponseFromJson(json);
  }
}