import 'package:ease_life/index.dart';
import 'package:ease_life/model/mediation_model.dart';
import 'package:ease_life/remote/kf_dio_utils.dart';
import 'package:ease_life/ui/widget/gradient_button.dart';
import 'package:oktoast/oktoast.dart';
import 'package:ease_life/model/district_model.dart';
import 'dispute_mediation_page.dart';

class MediationListPage extends StatefulWidget {
  static String routeName = "/mediationList";

  const MediationListPage({Key key}) : super(key: key);

  @override
  _MediationListPageState createState() => _MediationListPageState();
}

class _MediationListPageState extends State<MediationListPage>
    with TickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("纠纷调解"),
        actions: <Widget>[
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                onPressed: () {
                  _doAddApply(context).then((_) {
                    MediationApplyModel.of(context)
                        .getApplyMediation(context, true);
                  });
                },
                icon: Icon(Icons.add),
                tooltip: "添加纠纷调解申请",
              );
            },
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                text: "进行中",
              ),
              Tab(
                text: "已完成",
              ),
              Tab(
                text: "申请列表",
              ),
            ],
          ),
          Expanded(
            child: Consumer3<MediationHistoryModel, MediationRunningModel,
                MediationApplyModel>(
              builder: (BuildContext context,
                  MediationHistoryModel modelHistory,
                  MediationRunningModel modelRunning,
                  MediationApplyModel modelApply,
                  Widget child) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRunningMediation(context, modelRunning),
                    _buildCompletedMediation(context, modelHistory),
                    _buildAppliedMediation(context, modelApply),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedMediation(
      BuildContext context, MediationHistoryModel model) {
    return RefreshIndicator(
      onRefresh: () async {
        model.getHistoryMediation(context, true);
      },
      child: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          if (index == model.history.length) {
            return model.noMore
                ? index == 0
                    ? Container(
                        alignment: Alignment.center,
                        constraints: BoxConstraints(minHeight: 200),
                        child: Text(
                          "暂无记录",
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Container()
                : model.loading
                    ? Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(),
                      )
                    : FlatButton.icon(
                        onPressed: () {
                          model.getHistoryMediation(context, false);
                        },
                        icon: Icon(Icons.cached),
                        label: Text("加载更多"),
                      );
          }
          return _buildMediationTile(model.history[index]);
        },
        itemCount: model.history.length + 1,
      ),
    );
  }

  Widget _buildMediationTile(MediationRecord data) {
    return Container(
      margin: EdgeInsets.all(4),
      child: Material(
        color: Colors.white,
        elevation: 1,
        borderRadius: BorderRadius.all(Radius.circular(5)),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return DisputeMediationPage(
                chatRoomId: data.chatRoomId,
                isFinished: data.mediationFinished,
                title: data.title,
              );
            }));
          },
          child: ListTile(
            title: Text("${data.title}(${data.result})"),
            subtitle: Text(data.description??""),
            contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
            leading: Icon(
              data.mediationFinished ? Icons.check : Icons.access_time,
              color: Colors.lightGreen,
            ),
            trailing: Text(
                "开始时间:${DateTime.fromMillisecondsSinceEpoch(int.parse(data.startTime) * 1000)}"),
          ),
        ),
      ),
    );
  }

  Widget _buildRunningMediation(
      BuildContext context, MediationRunningModel model) {
    return RefreshIndicator(
      onRefresh: () async {
        model.getRunningMediation(context, true);
      },
      child: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          if (index == model.running.length) {
            return model.noMore
                ? index == 0
                    ? Container(
                        alignment: Alignment.center,
                        constraints: BoxConstraints(minHeight: 200),
                        child: Text(
                          "暂无记录",
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Container()
                : model.loading
                    ? Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(),
                      )
                    : FlatButton.icon(
                        onPressed: () {
                          model.getRunningMediation(context, false);
                        },
                        icon: Icon(Icons.cached),
                        label: Text("加载更多"),
                      );
          }
          return _buildMediationTile(model.running[index]);
        },
        itemCount: model.running.length + 1,
      ),
    );
  }

  Widget _buildAppliedMediation(
      BuildContext context, MediationApplyModel model) {
    return RefreshIndicator(
      onRefresh: () async {
        model.getApplyMediation(context, true);
      },
      child: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          if (index == model.apply.length) {
            return model.noMore
                ? index == 0
                    ? Container(
                        alignment: Alignment.center,
                        constraints: BoxConstraints(minHeight: 200),
                        child: Text(
                          "暂无记录",
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Container()
                : model.loading
                    ? Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(),
                      )
                    : FlatButton.icon(
                        onPressed: () {
                          model.getApplyMediation(context, false);
                        },
                        icon: Icon(Icons.cached),
                        label: Text("加载更多"),
                      );
          }
          return _buildApplyMediationTile(model.apply[index]);
        },
        itemCount: model.apply.length + 1,
      ),
    );
  }

  Widget _buildApplyMediationTile(MediationApply data) {
    return Container(
      margin: EdgeInsets.all(4),
      child: Material(
        color: Colors.white,
        elevation: 1,
        borderRadius: BorderRadius.all(Radius.circular(5)),
        child: InkWell(
          onTap: () {},
          child: Container(
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              child: ExpansionTile(
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          data.title,
                          style: Theme.of(context).textTheme.title,
                        ),
                        Expanded(child: Container()),
                        Text(
                          data.statusString,
                          style: TextStyle(color: data.statusColor),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text("申请人: "),
                        Text(data.applyUserName),
                        Expanded(child: Container()),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text("申请时间: "),
                        Text(data.date),
                        Expanded(child: Container()),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text("申请人地址: "),
                        Text(data.address),
                        Expanded(child: Container()),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text("受理人: "),
                        Text(data.acceptUserName),
                        Expanded(child: Container()),
                      ],
                    ),
                  ],
                ),
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: 24),
                        child: Text("图片描述:"),
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          children: data.images.map((url) {
                            return SizedBox(
                              height: MediaQuery.of(context).size.width / 4,
                              width: MediaQuery.of(context).size.width / 4,
                              child: Image.network(
                                url,
                                fit: BoxFit.cover,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  )
                ],
              )),
        ),
      ),
    );
  }

  Future _doAddApply(BuildContext context) async {
    return Navigator.of(context).pushNamed(MediationApplyPage.routeName);
  }
}

class MediationApplyPage extends StatefulWidget {
  static String routeName = "/applyMediation";

  @override
  _MediationApplyPageState createState() => _MediationApplyPageState();
}

class _MediationApplyPageState extends State<MediationApplyPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descController = TextEditingController();
  TextEditingController _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("添加调解申请"),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 24, horizontal: 18),
          child: DefaultTextStyle(
            style: Theme.of(context).textTheme.subtitle,
            child: Form(
              autovalidate: true,
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        constraints: BoxConstraints(minWidth: 122),
                        child: Text("调解标题:"),
                      ),
                      Expanded(
                        child: TextFormField(
                          key: ValueKey("title"),
                          validator: (s) =>
                              (s.length >= 4) ? null : "标题长度必须大于等于4个字符",
                          decoration: InputDecoration(
                            helperText: "标题",
                          ),
                          controller: _titleController,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        constraints: BoxConstraints(minWidth: 122),
                        child: Text("调解描述:"),
                      ),
                      Expanded(
                        child: TextFormField(
                          key: ValueKey("desc"),
                          validator: (s) =>
                              (s.length >= 10) ? null : "描述长度必须大于等于10字符",
                          decoration: InputDecoration(
                            helperText: "描述",
                          ),
                          controller: _descController,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        constraints: BoxConstraints(minWidth: 122),
                        child: Text("申请人住址:"),
                      ),
                      Expanded(
                        child: TextFormField(
                          key: ValueKey("addr"),
                          validator: (s) =>
                              (s.length >= 6) ? null : "申请人住址长度必须大于等于6字符",
                          decoration: InputDecoration(
                            helperText: "申请人住址",
                          ),
                          controller: _addressController,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Consumer<MediationApplicationAddModel>(
                    builder: (BuildContext context,
                        MediationApplicationAddModel model, Widget child) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            constraints: BoxConstraints(minWidth: 122),
                            child: Text("选择调解员:"),
                          ),
                          DropdownButton(
                            iconSize: 42,
                            items: model.mediatorList
                                .map((user) => DropdownMenuItem(
                                      child: Text(user.userName),
                                      value: user,
                                    ))
                                .toList(),
                            onChanged: (item) {
                              model.current = item;
                            },
                            isDense: true,
                            hint: Text("选择调解人"),
                            value: model.current,
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text("点击加号添加图片描述:"),
                  SizedBox(
                    height: 20,
                  ),
                  Consumer<MediationApplicationAddModel>(
                    builder: (BuildContext context,
                        MediationApplicationAddModel model, Widget child) {
                      List<Widget> list = model.images
                          .map(
                            (url) => Container(
                              height: MediaQuery.of(context).size.width / 4,
                              width: MediaQuery.of(context).size.width / 4,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 0.5,
                                ),
                              ),
                              margin: EdgeInsets.all(8),
                              child: Stack(
                                children: <Widget>[
                                  Positioned.fill(
                                    child: Image.network(
                                      url,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (BuildContext context,
                                          Widget child,
                                          ImageChunkEvent loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes
                                                : null,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment(1, -1),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.remove_circle,
                                        color: Colors.red[400],
                                      ),
                                      onPressed: () {
                                        model.remove(url);
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                          .toList();
                      list.add(
                        Container(
                          height: MediaQuery.of(context).size.width / 4,
                          width: MediaQuery.of(context).size.width / 4,
                          margin: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 0.5,
                            ),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.add,
                              size: 60,
                            ),
                            onPressed: () {
                              showImageSourceDialog(context).then((file) {
                                model.uploadImage(file.path);
                              });
                            },
                          ),
                        ),
                      );
                      return Wrap(
                        children: list,
                      );
                    },
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Consumer<MediationApplicationAddModel>(
                    builder: (BuildContext context,
                        MediationApplicationAddModel value, Widget child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          GradientButton(
                            Text("提交"),
                            onPressed: () async {
                              if (_formKey.currentState.validate()) {
                                if (value.validate()) {
                                  var districtId = DistrictModel.of(context)
                                      .getCurrentDistrictId()
                                      .toString();
                                  var kfBaseResp = await ApiKf.mediationApply(
                                    districtId,
                                    ChatGroupConfig.APP_ID,
                                    value.current.userName,
                                    value.current.userId,
                                    _titleController.text,
                                    _descController.text,
                                    _addressController.text,
                                    value.images,
                                  );
                                  if (kfBaseResp.success) {
                                    value.reset();
                                    Navigator.of(context).pop();
                                  }
                                  showToast(kfBaseResp.text);
                                }
                              } else {
                                showToast("请您按提示输入");
                              }
                            },
                          ),
                        ],
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
