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

class UserInfoWrapper {
  UserInfo userInfo;

  UserInfoWrapper(this.userInfo);

  @override
  String toString() {
    return "{\"userInfo\":\"$userInfo\"}";
  }

  UserInfoWrapper.fromJson(Map<String, dynamic> json) {
    userInfo =
        UserInfo.fromJson(json["userInfo"] is Map ? json["userInfo"] : {});
  }
}

class UserInfo {
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

class DistrictInfo {
  int districtId;
  String districtName;
  String districtAddr;
  String districtPic;
  String companyId;

  DistrictInfo(this.districtId, this.districtName, this.districtAddr,
      this.districtPic, this.companyId);

  @override
  String toString() {
    return '{"districtId":$districtId,"districtName":"$districtName","districtAddr":"$districtAddr","districtPic":"$districtPic","companyId":"$companyId"}';
  }

  DistrictInfo.fromJson(Map<String, dynamic> json) {
    districtId = json['districtId'];
    districtName = json['districtName'];
    districtAddr = json['districtAddr'];
    districtPic = json['districtPic'];
    companyId = json['companyId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['districtId'] = this.districtId;
    data['districtName'] = this.districtName;
    data['districtAddr'] = this.districtAddr;
    data['districtPic'] = this.districtPic;
    data['companyId'] = this.companyId;
    return data;
  }
}

class Index {
  String area;
  List<MenuItem> menu;

  @override
  String toString() {
    return '{"area":"$area",[${menu.join(",")}]}';
  }

  Index.fromJson(Map<String, dynamic> json) {
    this.area = json['area'];
    if (json['menu'] != null) {
      menu = new List<MenuItem>();
      json['menu'].forEach((v) {
        menu.add(new MenuItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['area'] = this.area;
    if (this.menu != null) {
      data['menu'] = this.menu.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MenuItem {
  String id;
  String remark;
  String url;

  MenuItem(this.id, this.remark, this.url);

  @override
  String toString() {
    return '{"id":"$id","remark":"$remark","url":"$url"}';
  }

  MenuItem.fromJson(Map<String, dynamic> json) {
    this.id = json['id'];
    this.remark = json['remark'];
    this.url = json['url'];
  }

  Map<String, String> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['remark'] = this.remark;
    data['url'] = this.url;
    return data;
  }
}

class UserDetail {
  String userId;
  String myName;
  String sex;
  String phone;
  String nickName;
  String avatar;
  String idCard;

  UserDetail(
      {this.userId,
      this.myName,
      this.sex,
      this.phone,
      this.nickName,
      this.avatar,
      this.idCard});

  UserDetail.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    myName = json['myName'];
    sex = json['sex'];
    phone = json['phone'];
    nickName = json['nickName'];
    avatar = json['avatar'];
    idCard = json['idCard'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['myName'] = this.myName;
    data['sex'] = this.sex;
    data['phone'] = this.phone;
    data['nickName'] = this.nickName;
    data['avatar'] = this.avatar;
    data['idCard'] = this.idCard;
    return data;
  }

  @override
  String toString() {
    return '{"userId":"$userId","myName":"$myName","sex":"$sex","phone":"$phone","nickName":"$nickName","avatar":"$avatar","idCard":"$idCard"}';
  }
}

class ImageDetail {
  String orginPicPath;
  String thumbnailPath;

  ImageDetail({this.orginPicPath, this.thumbnailPath});

  ImageDetail.fromJson(Map<String, dynamic> json) {
    orginPicPath = json['orginPicPath'];
    thumbnailPath = json['thumbnailPath'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['orginPicPath'] = this.orginPicPath;
    data['thumbnailPath'] = this.thumbnailPath;
    return data;
  }
}

class FileDetail {
  String filePath;

  FileDetail({this.filePath});

  FileDetail.fromJson(Map<String, dynamic> json) {
    filePath = json['filePath'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['filePath'] = this.filePath;
    return data;
  }
}