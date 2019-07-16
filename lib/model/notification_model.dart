import 'package:ease_life/model/user_model.dart';
import 'package:fake_push/fake_push.dart';

import '../index.dart';

class NotificationModel extends ChangeNotifier {
  StreamSubscription<String> _receiveDeviceToken;
  StreamSubscription<Message> _receiveMessage;
  StreamSubscription<Message> _receiveNotification;
  StreamSubscription<String> _launchNotification;
  StreamSubscription<String> _resumeNotification;

  int _unreadNotificationCount = 1;

  set unreadNotificationCount(int count) {
    if (_unreadNotificationCount == count) {
      return;
    }
    _unreadNotificationCount = count;
    notifyListeners();
  }

  int get unreadNotificationCount => _unreadNotificationCount;

  String get unreadNotificationCountText {
    return _unreadNotificationCount == 0
        ? ""
        : _unreadNotificationCount.toString();
  }

  NotificationModel(BuildContext context) {
    startListen(context);
  }

  static NotificationModel of(BuildContext context) {
    return Provider.of<NotificationModel>(context, listen: false);
  }

  Push _push = Push();

  void startListen(BuildContext context) async {
    print("start receive notification");

    _receiveDeviceToken = _push.receiveDeviceToken().listen((String data) {
      print('deviceToken:$data');
      userSp.setString(KEY_DEVICE_TOKEN, data);
      UserModel.of(context).tryFetchUserInfoAndLogin();
    });
    _receiveMessage = _push.receiveMessage().listen((Message msg) {
      print('Message:$msg');
    });
    _receiveNotification = _push.receiveNotification().listen((Message msg) {
      print('Notification:$msg');
    });
    _launchNotification = _push.launchNotification().listen((String msg) {
      print('launchNotification:$msg');
    });
    _resumeNotification = _push.resumeNotification().listen((String msg) {
      print('resumeNotification:$msg');
    });
    _push.startWork();
    bool notificationEnabled = await _push.areNotificationsEnabled();
    if (!notificationEnabled) {
      await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('提示'),
              content: const Text('开启通知权限可收到更多优质内容'),
              actions: <Widget>[
                FlatButton(
                  child: const Text('取消'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: const Text('设置'),
                  onPressed: () {
                    _push.openNotificationsSettings();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _receiveDeviceToken?.cancel();
    _receiveMessage?.cancel();
    _receiveNotification?.cancel();
    _launchNotification?.cancel();
    _resumeNotification?.cancel();
  }
}
