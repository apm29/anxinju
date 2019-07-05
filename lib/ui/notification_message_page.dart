import 'package:ease_life/index.dart';

class NotificationMessagePage extends StatefulWidget {
  static String routeName = "/messages";

  @override
  _NotificationMessagePageState createState() =>
      _NotificationMessagePageState();
}

class MessageModel extends ChangeNotifier {
  List<NotificationMessage> _list = [];

  List<NotificationMessage> get list => _list;

  get count => _list?.length ?? 0;

  int currentPage = 1;
  int defaultRows = 10;

  MessageModel() {
    loadMore();
  }

  bool noMore = false;
  bool isAtEnd = true;
  bool isLoading = false;

  void loadMore() async {
    if (isLoading || !isAtEnd || noMore) {
      return;
    }
    isLoading = true;
    notifyListeners();
    var resp = await Api.getNotificationMessage(currentPage, defaultRows);
    if (resp.success) {
      if (resp.data == null || resp.data.length == 0) {
        //no more
        noMore = true;
      } else {
        list.addAll(resp.data);
        currentPage++;
        if (resp.data.length < defaultRows) {
          noMore = true;
        }
      }
      isLoading = false;
    }
    await Future.delayed(Duration(seconds: 2));
    notifyListeners();
  }

  Future refresh() async {
    currentPage = 1;
    noMore = false;
    isAtEnd = true;
    isLoading = false;
    _list.clear();
    return loadMore();
  }
}

class _NotificationMessagePageState extends State<NotificationMessagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("消息"),
      ),
      body: Consumer<MessageModel>(
        builder: (BuildContext context, MessageModel value, Widget child) {
          return NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              var model = Provider.of<MessageModel>(context, listen: false);
              model.isAtEnd = notification.metrics.maxScrollExtent <=
                  (notification.metrics.pixels);
              return false;
            },
            child: RefreshIndicator(
              onRefresh: () async {
                return value.refresh();
              },
              child: ListView.builder(
                key: PageStorageKey(100),
                itemBuilder: (context, index) {
                  if (index == value.list.length) {
                    return value.noMore
                        ? Container()
                        : value.isLoading
                            ? Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(),
                              )
                            : FlatButton.icon(
                                onPressed: () {
                                  value.loadMore();
                                },
                                icon: Icon(Icons.cached),
                                label: Text("Load More"),
                              );
                  }
                  var message = value.list[index];

                  return InkWell(
                    onTap: () {
                      toWebPage(context, "fkgl", checkHasHouse: true);
                    },
                    child: Container(
                      constraints: BoxConstraints(minHeight: 72),
                      margin: EdgeInsets.all(3),
                      child: Material(
                        color: Colors.white,
                        elevation: 1,
                        child: Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.symmetric(horizontal: 18,vertical: 12),
                          child: Text("${message.id} ${message.sendMsg}"),
                        ),
                      ),
                    ),
                  );
                },
                itemCount: value.count + 1,
              ),
            ),
          );
        },
      ),
    );
  }
}
