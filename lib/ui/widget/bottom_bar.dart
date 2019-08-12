import 'package:ease_life/index.dart';
import 'package:ease_life/model/main_index_model.dart';
import 'package:ease_life/model/user_model.dart';
import 'package:ease_life/model/user_role_model.dart';

import '../main_page.dart';

class BottomBar extends StatelessWidget {
  final int currentPage;

  BottomBar(this.currentPage, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MainIndexModel>(
      builder: (BuildContext context, MainIndexModel value, Widget child) {
        return BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Consumer<UserModel>(
                builder: (BuildContext context, UserModel roleModel,
                    Widget child) {
                  return Icon(
                    roleModel.isOnPropertyDuty ? Icons.call : Icons.home,
                    size: 24,
                  );
                },
              ),
              title: Consumer<UserModel>(
                builder: (BuildContext context, UserModel roleModel,
                    Widget child) {
                  return roleModel.isOnPropertyDuty ? Text("紧急呼叫") : Text("主页");
                },
              ),
            ),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.person,
                  size: 24,
                ),
                title: Text("我的")),
          ],
          onTap: (index) {
            MainIndexModel.of(context).currentIndex = index;
            SystemSound.play(SystemSoundType.click);
          },
          currentIndex: currentPage,
          fixedColor: Colors.blue,
          type: BottomNavigationBarType.fixed,
        );
      },
    );
  }
}
