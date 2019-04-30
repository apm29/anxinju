import 'package:ease_life/index.dart';

class UserDetailAuthPage extends StatefulWidget {
  @override
  _UserDetailAuthPageState createState() => _UserDetailAuthPageState();
}

class _UserDetailAuthPageState extends State<UserDetailAuthPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _genderController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _avatarController = TextEditingController();
  TextEditingController _idCardController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("用户信息"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Row(
                children: <Widget>[
                  Text("姓名"),
                  Expanded(
                      child: TextField(
                    controller: _nameController,
                  ))
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: ListTile(
                leading: Text("性别"),
                title: TextField(
                  decoration: InputDecoration(
                    hintText: "请输入性别",
                    border: OutlineInputBorder(
                      gapPadding: 0
                    )
                  ),
                  controller: _genderController,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Row(
                children: <Widget>[
                  Text("电话"),
                  Expanded(
                      child: TextField(
                    controller: _phoneController,
                  ))
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Row(
                children: <Widget>[
                  Text("头像"),
                  Expanded(
                      child: TextField(
                    controller: _avatarController,
                  ))
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Row(
                children: <Widget>[
                  Text("身份证"),
                  Expanded(
                      child: TextField(
                    controller: _idCardController,
                  ))
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: OutlineButton(
                onPressed: () {
                  Navigator.of(context).pushNamed("/camera");
                },
                child: Text("提交"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
