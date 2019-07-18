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

  bool get success => status == "1";

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserInfo &&
          runtimeType == other.runtimeType &&
          userId == other.userId;

  @override
  int get hashCode => userId.hashCode;
}

class DistrictDetail {
  int districtId;
  String districtName;
  String districtAddr;
  String districtPic;
  String companyId;

  DistrictDetail(this.districtId, this.districtName, this.districtAddr,
      this.districtPic, this.companyId);

  @override
  String toString() {
    return '{"districtId":$districtId,"districtName":"$districtName","districtAddr":"$districtAddr","districtPic":"$districtPic","companyId":"$companyId"}';
  }

  DistrictDetail.fromJson(Map<String, dynamic> json) {
    districtId = json['districtId'];
    districtName = json['districtName'];
    districtAddr = json['districtAddr'];
    districtPic = json['districtPic'];
    companyId = json['companyId'].toString();
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

  @override
  bool operator ==(other) {
    if (other == null || other is! DistrictDetail) {
      return false;
    } else if (other is DistrictDetail) {
      return districtId == other.districtId &&
          districtName == other.districtName &&
          districtAddr == other.districtAddr &&
          districtPic == other.districtPic;
    }
    return false;
  }

  @override
  int get hashCode {
    return super.hashCode;
  }
}

class Index {
  String area;
  List<MenuItem> menu;

  @override
  String toString() {
    return '{"area":"$area","menu":[${menu.join(",")}]}';
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

  Map<String, dynamic> toJson() {
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

class AnnouncementType {
  int typeId;
  int typeUid;
  String typeName;

  AnnouncementType({this.typeId, this.typeUid, this.typeName});

  AnnouncementType.fromJson(Map<String, dynamic> json) {
    typeId = json['typeId'];
    typeUid = json['typeUid'];
    typeName = json['typeName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['typeId'] = this.typeId;
    data['typeUid'] = this.typeUid;
    data['typeName'] = this.typeName;
    return data;
  }
}

class Announcement {
  int noticeId;
  String noticeTitle;
  String noticeContent;
  int noticeType;
  String noticeScope;
  int districtId;
  String userId;
  int companyId;
  String userName;
  String companyName;
  String createTime;

  Announcement({
    this.noticeId,
    this.noticeTitle,
    this.noticeContent,
    this.noticeType,
    this.noticeScope,
    this.districtId,
    this.userId,
    this.companyId,
    this.userName,
    this.companyName,
    this.createTime,
  });

  Announcement.fromJson(Map<String, dynamic> json) {
    noticeId = json['noticeId'];
    noticeTitle = json['noticeTitle'];
    noticeContent = json['noticeContent'];
    noticeType = json['noticeType'];
    noticeScope = json['noticeScope'];
    districtId = json['districtId'];
    userId = json['userId'];
    companyId = json['companyId'];
    userName = json['userName'];
    companyName = json['companyName'];
    createTime = json['createTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['noticeId'] = this.noticeId;
    data['noticeTitle'] = this.noticeTitle;
    data['noticeContent'] = this.noticeContent;
    data['noticeType'] = this.noticeType;
    data['noticeScope'] = this.noticeScope;
    data['districtId'] = this.districtId;
    data['userId'] = this.userId;
    data['companyId'] = this.companyId;
    data['userName'] = this.userName;
    data['companyName'] = this.companyName;
    data['createTime'] = this.createTime;
    return data;
  }
}

///
///人脸认证/certification/userVerify 接口返回的结果信息
///
class UserVerifyInfo {
  List<HouseInfo> rows;

  UserVerifyInfo({this.rows});

  UserVerifyInfo.fromJson(Map<String, dynamic> json) {
    if (json['rows'] != null) {
      rows = new List<HouseInfo>();
      json['rows'].forEach((v) {
        rows.add(new HouseInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.rows != null) {
      data['rows'] = this.rows.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class HouseInfo {
  int isOwner;
  String addr;

  HouseInfo({this.isOwner, this.addr});

  bool get isHouseOwner => isOwner == 1;

  HouseInfo.fromJson(Map<String, dynamic> json) {
    isOwner = json['isOwner'];
    addr = json['addr'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isOwner'] = this.isOwner;
    data['addr'] = this.addr;
    return data;
  }
}

class UserType {
  int id;
  String userId;

  ///物业人员 1
  ///有房认证用户 2
  ///民警 3
  ///无房认证用户 4
  ///家庭成员 5
  ///无认证用户 6
  String roleCode;

  UserType({this.id, this.userId, this.roleCode});

  UserType.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    roleCode = json['roleCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['userId'] = this.userId;
    data['roleCode'] = this.roleCode;
    return data;
  }

  @override
  String toString() {
    return 'UserType{id: $id, userId: $userId, roleCode: $roleCode}';
  }
}

class HouseDetail {
  int id;
  int houseId;
  String districtId;
  String building;
  String unit;
  String house;
  String addr;
  String phone;
  String idcard;
  String name;
  String userId;
  String passCode;

  HouseDetail(
      {this.id,
      this.houseId,
      this.districtId,
      this.building,
      this.unit,
      this.house,
      this.addr,
      this.phone,
      this.idcard,
      this.name,
      this.userId,
      this.passCode});

  HouseDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    houseId = json['houseId'];
    districtId = json['districtId'];
    building = json['building'];
    unit = json['unit'];
    house = json['house'];
    addr = json['addr'];
    phone = json['phone'];
    idcard = json['idcard'];
    name = json['name'];
    userId = json['userId'];
    passCode = json['passCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['houseId'] = this.houseId;
    data['districtId'] = this.districtId;
    data['building'] = this.building;
    data['unit'] = this.unit;
    data['house'] = this.house;
    data['addr'] = this.addr;
    data['phone'] = this.phone;
    data['idcard'] = this.idcard;
    data['name'] = this.name;
    data['userId'] = this.userId;
    data['passCode'] = this.passCode;
    return data;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HouseDetail &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class AudioUploadInfo {
  String key;
  String url;

  AudioUploadInfo({this.key, this.url});

  AudioUploadInfo.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['key'] = this.key;
    data['url'] = this.url;
    return data;
  }
}

class UserVerifyStatus {
  ///
  /// code 0 未认证
  /// code 1 有房认证中
  /// code 2 无房认证中
  /// code 3 有房认证成功
  /// code 4 无房认证成功
  /// code 5 有房认证失败
  /// code 6 无房认证失败
  ///
  int code;

  String getDesc() {
    switch (code) {
      case 0:
        return "未认证";
      case 1:
        return "名下有房,\n人脸认证中";
      case 2:
        return "名下无房,\n人脸认证中";
      case 3:
        return "名下有房,\n人脸认证成功";
      case 4:
        return "名下无房,\n人脸认证成功";
      case 5:
        return "名下有房,\n人脸认证失败";
      case 6:
        return "名下无房,\n人脸认证失败";
      default:
        return null;
    }
  }

  UserVerifyStatus({this.code});

  UserVerifyStatus.fromJson(Map<String, dynamic> json) {
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    return data;
  }

  bool hasHouse() {
    return code == 1 || code == 3 || code == 5;
  }

  bool isVerified() {
    return code == 3 || code == 4;
  }

  String getVerifyText() {
    String text;
    switch (code) {
      case 0:
        text = "未认证";
        break;
      case 1:
        text = "认证中";
        break;
      case 2:
        text = "认证中";
        break;
      case 3:
        text = "已认证";
        break;
      case 4:
        text = "已认证";
        break;
      case 5:
        text = "认证失败";
        break;
      case 6:
        text = "认证失败";
        break;
      default:
        text = "未认证";
        break;
    }
    return text;
  }

  @override
  String toString() {
    return '{"code": $code  ${getDesc()}}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserVerifyStatus &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}

class NotificationMessage {
  int id;
  String userId;
  String sendMsg;
  Null title;
  int type;
  String picUrl;
  String createTime;

  NotificationMessage(
      {this.id,
      this.userId,
      this.sendMsg,
      this.title,
      this.type,
      this.picUrl,
      this.createTime});

  NotificationMessage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    sendMsg = json['sendMsg'];
    title = json['title'];
    type = json['type'];
    picUrl = json['picUrl'];
    createTime = json['createTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['userId'] = this.userId;
    data['sendMsg'] = this.sendMsg;
    data['title'] = this.title;
    data['type'] = this.type;
    data['picUrl'] = this.picUrl;
    data['createTime'] = this.createTime;
    return data;
  }
}
