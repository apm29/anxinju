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
///
///
/*
 *flutter packages pub run build_runner build --delete-conflicting-outputs
 */

class BaseResponse<T> {
  String status;
  String token;
  String text;
  T data;

  bool success() => status == "1";

  BaseResponse(this.status, this.token, this.text, this.data);

  @override
  String toString() {
    StringBuffer sb = new StringBuffer('{');
    sb.write("\"status\":\"$status\"");
    sb.write(",\"token\":$token");
    sb.write(",\"text\":\"$text\"");
    sb.write(",\"data\":\"$data\"");
    sb.write('}');
    return sb.toString();
  }
}

class DataWrapper {
  UserInfo userInfo;

  DataWrapper(this.userInfo);

  @override
  String toString() {
    return "{\"userInfo\":\"$userInfo\"}";
  }

  DataWrapper.fromJson(Map<String, dynamic> json) {
    userInfo =
        UserInfo.fromJson(json["userInfo"] is Map ? json["userInfo"] : {});
  }
}
enum ActionState{
  LOADING,ERROR,NORMAL
}

class UserInfo{
  String userId;
  String userName;
  String mobile;
  int isCertification;

  UserInfo({this.userId, this.userName, this.mobile, this.isCertification});

  @override
  String toString() {
    return '{"userId": "$userId", "userName": "$userName", "mobile": "$mobile", "isCertification": $isCertification}';
  }

  UserInfo.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    userName = json['userName'];
    mobile = json['mobile'];
    isCertification = json['isCertification'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['userName'] = this.userName;
    data['mobile'] = this.mobile;
    data['isCertification'] = this.isCertification;
    return data;
  }
}
