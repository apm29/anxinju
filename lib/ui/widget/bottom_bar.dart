import 'package:ease_life/index.dart';
import 'package:ease_life/model/main_index_model.dart';

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
                icon: Icon(
                  Icons.home,
                  size: 24,
                  color: currentPage == PAGE_HOME
                      ? Colors.blueAccent
                      : Colors.grey,
                ),
                title: Text("主页")),
            BottomNavigationBarItem(
                icon: Image.asset(
                  "images/search.png",
                  width: 24,
                  height: 24,
                  color: currentPage == PAGE_SEARCH
                      ? Colors.blueAccent
                      : Colors.grey,
                ),
                title: Text("搜索")),
//        BottomNavigationBarItem(
//            icon: Icon(
//              Icons.message,
//              size: 24,
//              color: _currentIndex == PAGE_MESSAGE ? Colors.blueAccent : Colors.grey,
//            ),
//            title: Text("消息")),
            BottomNavigationBarItem(
                icon: Image.asset(
                  "images/mine.png",
                  width: 24,
                  height: 24,
                  color: currentPage == PAGE_MINE
                      ? Colors.blueAccent
                      : Colors.grey,
                ),
                title: Text("我的")),
          ],
          onTap: (index) {
            MainIndexModel.of(context).currentIndex = index;
          },
          currentIndex: currentPage,
          fixedColor: Colors.blue,
          type: BottomNavigationBarType.fixed,
        );
      },
    );
  }
}
