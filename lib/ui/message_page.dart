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
          if(snapshot.hasError||!snapshot.hasData){
            return Center(
              child: Text("未登录"),
            );
          }
          return ListView.builder(
            itemBuilder: (context, index) {
              return Card(

                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          FlutterLogo(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("住户A"),
                          ),
                          Expanded(child: Text("你好！我是住在天马花园1509-1的住户1，诚邀你到我家做客",overflow: TextOverflow.ellipsis,maxLines: 20,))
                        ],
                      ),
                      Text("2019/03/11 10:11")
                    ],
                  ),
                ),
              );
            },
            itemCount: 3,
          );
        }
      ),
    );
  }
}
