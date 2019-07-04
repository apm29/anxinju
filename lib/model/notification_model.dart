import 'package:ai_life/index.dart';

class NotificationModel extends ChangeNotifier{

  int _unreadNotificationCount = 1;

  set unreadNotificationCount(int count){
    if(_unreadNotificationCount==count){
      return;
    }
    _unreadNotificationCount = count;
    notifyListeners();
  }

  int get unreadNotificationCount => _unreadNotificationCount;
  String get unreadNotificationCountText {
    return _unreadNotificationCount==0?"":_unreadNotificationCount.toString();
  }




  static NotificationModel of(BuildContext context) {
    return Provider.of<NotificationModel>(context, listen: false);
  }

}