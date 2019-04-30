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
              child: Row(children: <Widget>[
                Text("姓名"),
                Expanded(child: TextField())
              ],),
            ),
            SliverToBoxAdapter(
              child: Row(children: <Widget>[
                Text("性别"),
                Expanded(child: TextField())
              ],),
            ),
            SliverToBoxAdapter(
              child: Row(children: <Widget>[
                Text("电话"),
                Expanded(child: TextField())
              ],),
            ),
            SliverToBoxAdapter(
              child: Row(children: <Widget>[
                Text("头像"),
                Expanded(child: TextField())
              ],),
            ),
            SliverToBoxAdapter(
              child: Row(children: <Widget>[
                Text("身份证"),
                Expanded(child: TextField())
              ],),
            ),
            SliverToBoxAdapter(
              child: OutlineButton(onPressed: (){
                Navigator.of(context).pushNamed("/camera");
              },child: Text("提交"),),
            )
          ],
        ),
      ),
    );
  }
}
