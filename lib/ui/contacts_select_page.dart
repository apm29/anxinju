import 'package:contacts_service/contacts_service.dart';
import 'package:ease_life/index.dart';
import 'package:android_intent/android_intent.dart';

class ContactsSelectPage extends StatefulWidget {
  @override
  _ContactsSelectPageState createState() => _ContactsSelectPageState();
}

class _ContactsSelectPageState extends State<ContactsSelectPage> {
  GlobalKey<RefreshIndicatorState> refresh = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("通讯录"),
        centerTitle: true,
      ),
      body: Container(
        margin: EdgeInsets.all(12),
        padding: EdgeInsets.all(12),
        color: Colors.grey[200],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]),
                  color: Colors.white),
              child: Row(
                children: <Widget>[
                  Icon(Icons.search),
                  Expanded(
                    child: TextField(
                      decoration:
                          InputDecoration.collapsed(hintText: "搜索名字/手机"),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                key: refresh,
                onRefresh: () async {
                  await BlocProviders.of<ContactsBloc>(context)
                      .getContactsAndNotify();
                  return null;
                },
                child: StreamBuilder<List<Contact>>(
                  stream:
                      BlocProviders.of<ContactsBloc>(context).contactsStream,
                  builder: (context, contactsSnap) {
                    if (contactsSnap.hasError ||
                        !contactsSnap.hasData ||
                        contactsSnap.data.length == 0) {
                      return Center(
                        child: Text("未获取到联系人信息"),
                      );
                    } else {
                      return ListView.builder(
                        itemBuilder: (context, index) {
                          var contact = contactsSnap.data[index];
                          var avatar = contact.avatar;
                          var phones = contact.phones.toList() ?? [];
                          return Container(
                            color: Colors.white,
                            margin: EdgeInsets.all(3),
                            child: ExpansionTile(
                              title: Row(
                                children: <Widget>[
                                  SizedBox(
                                    width: 50,
                                    child: avatar?.isNotEmpty??false
                                        ? Image.memory(avatar)
                                        : CircleAvatar(
                                            child: Text(contact.displayName
                                                .substring(0, 1)),
                                          ),
                                  ),
                                  Expanded(
                                      child: Text(
                                    contact.displayName,
                                    maxLines: 10,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                                ],
                              ),
                              children: contact.phones.map((i) {
                                return ListTile(
                                    title: Text(i.value),
                                    onTap: () {
//                                FlutterSms.sendSMS(message: "我小区已使用门禁，输入我家庭通行码123456即可进入小区，如您有车辆需进入请点击链接登记车牌.http://xxx.cn", recipients: [
//                                  contact.phones
//                                      .firstWhere((item) => item.label == "mobile")
//                                      .value
//                                ]);
                                      if (phones.isEmpty) {
                                        return;
                                      }
                                      var androidIntent = AndroidIntent(
                                          action: 'action_view',
                                          data: "smsto:${i.value}",
                                          arguments: {
                                            "sms_body":
                                                "我小区已使用门禁，输入我家庭通行码123456即可进入小区，如您有车辆需进入请点击链接登记车牌."
                                          });
                                      androidIntent.launch();
                                    });
                              }).toList(),
                            ),
                          );
                        },
                        itemCount: contactsSnap.data.length,
                      );
                    }
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
