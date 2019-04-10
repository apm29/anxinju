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

class BaseResponse {
  String status;
  String token;
  String text;

  bool success() => status == "1";
}

class UserInfoModel extends BaseResponse {
  String status;
  UserInfoWrapper data;
  String token;
  String text;

  UserInfoModel({this.status, this.data, this.token, this.text});

  UserInfoModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null ? new UserInfoWrapper.fromJson(json['data']) : null;
    token = json['token'];
    text = json['text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    data['token'] = this.token;
    data['text'] = this.text;
    return data;
  }

  factory UserInfoModel.error(String msg) {
    return UserInfoModel(status: "0", text: msg);
  }

  factory UserInfoModel.success(UserInfoWrapper data){
    return UserInfoModel(status: "1",data: data);
  }
}

class UserInfoWrapper {
  UserInfo userInfo;

  UserInfoWrapper({this.userInfo});

  UserInfoWrapper.fromJson(Map<String, dynamic> json) {
    userInfo = json['userInfo'] != null
        ? new UserInfo.fromJson(json['userInfo'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.userInfo != null) {
      data['userInfo'] = this.userInfo.toJson();
    }
    return data;
  }
}

class UserInfo {
  String userId;
  String userName;
  String mobile;
  int isCertification;

  UserInfo({this.userId, this.userName, this.mobile, this.isCertification});

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
