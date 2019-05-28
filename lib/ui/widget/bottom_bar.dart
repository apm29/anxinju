import 'package:ease_life/index.dart';

import '../main_page.dart';

class BottomBar extends StatefulWidget {

  final PageController controller;

  @override
  BottomBarState createState() => BottomBarState();

  BottomBar(Key key,this.controller) : super(key: key);
}

class BottomBarState extends State<BottomBar> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 24,
              color:
              _currentIndex == PAGE_HOME ? Colors.blueAccent : Colors.grey,
            ),
            title: Text("主页")),
//        BottomNavigationBarItem(
//            icon: Image.asset(
//              "images/search.png",
//              width: 24,
//              height: 24,
//              color: _currentIndex == PAGE_SEARCH ? Colors.blueAccent : Colors.grey,
//            ),
//            title: Text("搜索")),
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
              color:
              _currentIndex == PAGE_MINE ? Colors.blueAccent : Colors.grey,
            ),
            title: Text("我的")),
      ],
      onTap: (index) {
        if (_currentIndex != index) {
          setState(() {
            _currentIndex = index;
          });
          widget.controller.jumpToPage(index);
        }
      },
      currentIndex: _currentIndex,
      fixedColor: Colors.blue,
      type: BottomNavigationBarType.fixed,
    );
  }

  void changePage(int currentIndex) {
    setState(() {
      _currentIndex = currentIndex;
    });
  }
}
