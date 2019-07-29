import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'base_response.dart';
import 'package:ease_life/remote/api.dart';

const List<Color> colors =const [
  Colors.redAccent,
  Colors.purple,
  Colors.lightBlue,
  Colors.teal,
  Colors.pinkAccent,
  Colors.deepPurpleAccent,
  Colors.blueAccent,
  Colors.green,
  Colors.teal,
  Colors.lightBlue,
  Colors.lightBlue,
  Colors.purple,
  Colors.cyan,
  Colors.lightGreen
];

class AnnouncementModel extends ChangeNotifier {
  List<AnnouncementType> _announcementTypes;

  set announcementTypes(newValue) {
    if (_announcementTypes == newValue) {
      return;
    }
    _announcementTypes = newValue;
    notifyListeners();
  }

  List<Announcement> _announcementList;

  set announcementList(newValue) {
    if (listEquals(_announcementList, newValue)) {
      return;
    }
    _announcementList = newValue;
    notifyListeners();
  }

  AnnouncementModel() {
    tryFetchAllAnnouncement();
  }

  Future tryFetchAllAnnouncement() async {
    return Future.delayed(Duration(seconds: 0)).then((_) {
      Api.getAllNoticeType().then((resp) {
        if (resp.success) {
          announcementTypes = resp.data;
        }
        return Api.getNewNotice(resp.data);
      }).then((resp) {
        print('$resp');
        if (resp.success) {
          announcementList = resp.data;
        }
        return;
      });
    });
  }

  String get typesString =>
      _announcementTypes?.map((e) => e?.typeId)?.toList()?.join(",") ?? "";

  List<Announcement> get announcements =>_announcementList ?? [];

  List<AnnouncementType> get announcementTypes => _announcementTypes ?? [];

  String typeTitle(int index) {
    return announcementTypes.firstWhere((type) {
          return type.typeId == announcements[index].noticeType;
        }, orElse: () => null)?.typeName ??
        "";
  }

  String title(int index) {
    return announcements[index].noticeTitle;
  }

  String typeTitleByDetail(Announcement detail){
    return announcementTypes.firstWhere((type) {
      return type.typeId == detail.noticeType;
    }, orElse: () => null)?.typeName ??
        "";
  }

  Gradient bannerColor(int index) {
    var colorIndex = (announcements[index].noticeType);
    return LinearGradient(
      colors: [
        colors[colorIndex].withAlpha(0xff),
        colors[colorIndex].withAlpha(0xa1),
      ],
    );
  }

  static AnnouncementModel of(BuildContext context) {
    return Provider.of<AnnouncementModel>(context, listen: false);
  }
}
