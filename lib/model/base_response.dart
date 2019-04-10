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
  T data;
  String token;
  String text;
  String msg;

  BaseResponse();

  factory BaseResponse.fromJson(Map<String, dynamic> json) {
    var baseResponse = BaseResponse()
      ..status = json['status'] as String
      ..token = json['token'] as String
      ..text = json['text'] as String;
    switch (T) {
      case UserInfoData:
        baseResponse.data = UserInfoData.fromJson(json['data']);
    }
    return baseResponse;
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{
      'status': status,
      'token': token,
      'text': text
    };
    switch(T){
      case UserInfoData:
        map['data'] = (data as UserInfoData).toJson();
        break;
    }
    return map;
  }

  factory BaseResponse.error(String msg) {
    return BaseResponse()
      ..msg = msg
      ..status = "0";
  }

  factory BaseResponse.success(String msg,{T data}) {
    return BaseResponse()
      ..msg = msg
      ..data = data
      ..status = "1";
  }

  bool requestSuccess() => status == "1";
}

class UserInfo {
  String userId;
  String userName;
  String mobile;
  int isCertification;

  UserInfo();

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo()
      ..userId = json['userId'] as String
      ..userName = json['userName'] as String
      ..mobile = json['mobile'] as String
      ..isCertification = json['isCertification'] as int;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'userId': userId,
      'userName': userName,
      'mobile': mobile,
      'isCertification': isCertification
    };
  }
}

class UserInfoData {
  UserInfo userInfo;

  UserInfoData();

  factory UserInfoData.fromJson(Map<String, dynamic> json) {
    return UserInfoData()
      ..userInfo = json['userInfo'] == null
          ? null
          : UserInfo.fromJson(json['userInfo'] as Map<String, dynamic>);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'userInfo': userInfo.toJson()};
  }
}
