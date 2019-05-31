import 'package:ease_life/index.dart';

class MessagePage extends StatefulWidget {
  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("消息"),
      ),
      body: StreamBuilder<UserInfo>(
          stream: BlocProviders.of<ApplicationBloc>(context).currentUser,
          builder: (context, snapshot) {
            if (snapshot.hasError || !snapshot.hasData) {
              return buildVisitor(context);
            }
            return StreamBuilder<List<NoticeDetail>>(
                stream:
                    BlocProviders.of<ApplicationBloc>(context).homeNoticeStream,
                builder: (context, snapshot) {
                  var list = snapshot.data ?? [];
                  return StreamBuilder<List<NoticeType>>(
                      stream: BlocProviders.of<ApplicationBloc>(context)
                          .noticeTypeStream,
                      builder: (context, snapshot) {
                        var types = snapshot.data ?? [];
                        return ListView.builder(
                          itemBuilder: (context, index) {
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: ExpansionTile(
                                  leading: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 6),
                                    decoration: BoxDecoration(
                                        color: colors[list[index].noticeType %
                                            colors.length],
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8))),
                                    child: Text(
                                      types.firstWhere((type) {
                                        return type.typeId ==
                                            list[index].noticeType;
                                      }).typeName,
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                  title: Text(list[index].noticeTitle),
                                  children: <Widget>[
                                    GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return WebViewExample(
                                                "$BASE_URL#/contentDetails?contentId=${list[index].noticeId}");
                                          }));
                                        },
                                        child: Text(list[index].noticeContent)),
                                  ],
                                ),
                              ),
                            );
                          },
                          itemCount: list.length,
                        );
                      });
                });
          }),
    );
  }
}
