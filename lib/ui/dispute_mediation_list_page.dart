import 'package:ease_life/index.dart';
import 'package:ease_life/model/mediation_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:ease_life/remote/kf_dio_utils.dart';
import 'package:ease_life/ui/widget/gradient_button.dart';
import 'package:intl/intl.dart';
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
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.blue,
            title: Text(
              "纠纷调解",
              style: TextStyle(color: Colors.white),
            ),
            brightness: Brightness.dark,
            iconTheme: IconThemeData(color: Colors.white),
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
            elevation: 4,
            forceElevated: true,
            floating: true,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.deepOrangeAccent,
              labelColor: Colors.white,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12),
                  )),
              tabs: [
                Tab(
                  text: "进行中",
                  icon: Icon(Icons.av_timer, color: Colors.white),
                ),
                Tab(
                  text: "已完成",
                  icon: Icon(Icons.check, color: Colors.white),
                ),
                Tab(
                  text: "申请列表",
                  icon: Icon(Icons.list, color: Colors.white),
                ),
              ],
              isScrollable: true,
            ),
          ),
          SliverFillRemaining(
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

  final dateFormat = DateFormat("yyyy-MM-dd HH:mm");

  Widget _buildMediationTile(MediationRecord data) {
    var title = (data.title == null || data.title.isEmpty) ? "无标题" : data.title;
    var result = (data.mediationFinished) ? data.result : "未完成";
    var desc = (data.description == null || data.description.isEmpty)
        ? "未提交描述信息"
        : data.description;

    var time = dateFormat.format(
        DateTime.fromMillisecondsSinceEpoch(int.parse(data.startTime) * 1000));
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
                title: title,
              );
            }));
          },
          child: ListTile(
            title: Text("$title($result)"),
            subtitle: Text("开始时间:$time"),
            contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
            leading: Icon(
              data.mediationFinished ? Icons.check : Icons.access_time,
              color: Colors.lightGreen,
            ),
            trailing: Text(desc),
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
        child: Container(
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                backgroundColor: Colors.white,
                title: DefaultTextStyle(
                  style: Theme.of(context).textTheme.caption,
                  overflow: TextOverflow.ellipsis,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text.rich(
                        TextSpan(
                          style: Theme.of(context).textTheme.subtitle,
                          text: data.title,
                          children: [
                            TextSpan(
                              text: "(${data.statusString})",
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle
                                  .copyWith(color: data.statusColor),
                            ),
                          ],
                        ),
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
                            return InkWell(
                              onTap: () {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  return PicturePage(url);
                                }));
                              },
                              child: SizedBox(
                                height: MediaQuery.of(context).size.width / 4,
                                width: MediaQuery.of(context).size.width / 4,
                                child: Hero(
                                  tag: url,
                                  child: Image.network(
                                    url,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )),
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var filledColor = Colors.blue[50];
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme.copyWith(color: Colors.white),
        backgroundColor: Colors.blue,
        title: Text(
          "添加调解申请",
          style: Theme.of(context).textTheme.title.copyWith(
            color: Colors.white
          ),
        ),
        elevation: 0,
      ),
      body: _buildBody(context, filledColor),
      bottomNavigationBar: _buildBottomAction(),
    );
  }

  Widget _buildBody(BuildContext context, Color filledColor) {
    return ApplyStepperWidget(
      child: Container(
        child: Form(
          key: _formKey,
          autovalidate: true,
          child: Material(
            textStyle: Theme.of(context)
                .textTheme
                .body1
                .copyWith(color: Colors.blue),
            elevation: 1,
            color: Colors.white,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    constraints: BoxConstraints(minWidth: 122),
                    child: Text("调解标题:"),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(154),
                    child: TextFormField(
                      key: ValueKey("title"),
                      style: Theme.of(context).textTheme.body1,
                      validator: (s) =>
                      (s.length >= 4) ? null : "标题长度必须大于等于4个字符",
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        fillColor: filledColor,
                        filled:
                        _formKey.currentState?.validate() ?? false,
                      ),
                      controller: _titleController,
                      maxLength: 20,
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Divider(),
                  SizedBox(
                    height: 8,
                  ),
                  Container(
                    constraints: BoxConstraints(minWidth: 122),
                    child: Text(
                      "调解描述:",
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(480),
                    child: TextFormField(
                      maxLines: 50,
                      style: Theme.of(context).textTheme.body1,
                      key: ValueKey("desc"),
                      validator: (s) =>
                      (s.length >= 10) ? null : "描述长度必须大于等于10字符",
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        fillColor: filledColor,
                        filled:
                        _formKey.currentState?.validate() ?? false,
                      ),
                      controller: _descController,
                      maxLength: 140,
                      enableInteractiveSelection: true,
                      keyboardAppearance: Brightness.dark,
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Divider(),
                  SizedBox(
                    height: 8,
                  ),
                  Container(
                    constraints: BoxConstraints(minWidth: 122),
                    child: Text("申请人住址:"),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Consumer<MediationApplicationAddModel>(
                    builder: (BuildContext context,
                        MediationApplicationAddModel model,
                        Widget child) {
                      return Container(
                        height: ScreenUtil().setHeight(116),
                        decoration: BoxDecoration(
                          color: model.currentHouse != null
                              ? filledColor
                              : null,
                          border: Border.all(color: Colors.grey[500]),
                          borderRadius: BorderRadius.all(
                            Radius.circular(6),
                          ),
                        ),
                        child: DropdownButton<HouseDetail>(
                          iconEnabledColor: Colors.blue,
                          isExpanded: true,
                          iconSize: 36,
                          items: model.houseList
                              .map((user) => DropdownMenuItem(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 8.0),
                              child: Text(
                                user.addr,
                                style: Theme.of(context)
                                    .textTheme
                                    .body1,
                              ),
                            ),
                            value: user,
                          ))
                              .toList(),
                          onChanged: (item) {
                            model.currentHouse = item;
                          },
                          isDense: true,
                          hint: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              "选择申请人住址",
                              style: Theme.of(context).textTheme.caption,
                            ),
                          ),
                          value: model.currentHouse,
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Container(
                    constraints: BoxConstraints(minWidth: 122),
                    child: Text("调解员:"),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Consumer<MediationApplicationAddModel>(
                    builder: (BuildContext context,
                        MediationApplicationAddModel model,
                        Widget child) {
                      return Container(
                        height: ScreenUtil().setHeight(116),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[500]),
                          borderRadius: BorderRadius.all(
                            Radius.circular(6),
                          ),
                          color: model.currentMediator != null
                              ? filledColor
                              : null,
                        ),
                        child: DropdownButton<UserInfo>(
                          iconEnabledColor: Colors.blue,
                          isExpanded: true,
                          iconSize: 36,
                          items: model.mediatorList
                              .map((user) => DropdownMenuItem(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 8.0),
                              child: Text(
                                user.userName,
                                style: Theme.of(context)
                                    .textTheme
                                    .body1
                                    .copyWith(),
                              ),
                            ),
                            value: user,
                          ))
                              .toList(),
                          onChanged: (item) {
                            model.currentMediator = item;
                          },
                          isDense: true,
                          hint: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              "选择调解人",
                              style: Theme.of(context).textTheme.caption,
                            ),
                          ),
                          value: model.currentMediator,
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Divider(),
                  SizedBox(
                    height: 12,
                  ),
                  Text("点击加号添加图片描述:"),
                  SizedBox(
                    height: 12,
                  ),
                  Consumer<MediationApplicationAddModel>(
                    builder: (BuildContext context,
                        MediationApplicationAddModel model,
                        Widget child) {
                      List<Widget> list = model.images
                          .map(
                            (url) => Container(
                          height:
                          MediaQuery.of(context).size.width / 4,
                          width:
                          MediaQuery.of(context).size.width / 4,
                          decoration: BoxDecoration(
                            border: Border.all(
                                width: 0.5, color: Colors.blue[200]),
                          ),
                          margin: EdgeInsets.all(8),
                          child: Stack(
                            children: <Widget>[
                              Positioned.fill(
                                child: Image.network(
                                  url,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent
                                      loadingProgress) {
                                    if (loadingProgress == null)
                                      return child;
                                    return Center(
                                      child:
                                      CircularProgressIndicator(
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
                              color: Colors.blue[200],
                            ),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.add,
                              size: 60,
                              color: Colors.blue,
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
                    height: 60,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    return Consumer<MediationApplicationAddModel>(
      builder: (BuildContext context, MediationApplicationAddModel value,
          Widget child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: GradientButton(
                Text(
                  "提交申请",
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                gradient: LinearGradient(colors: [
                    Colors.redAccent,Colors.deepOrange,Colors.redAccent
                ]),
                unconstrained: false,
                borderRadius: 0,
                padding: EdgeInsets.symmetric(vertical: 12),
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    if (value.validate()) {
                      var districtId = DistrictModel.of(context)
                          .getCurrentDistrictId()
                          .toString();
                      var kfBaseResp = await ApiKf.mediationApply(
                        districtId,
                        ChatGroupConfig.APP_ID,
                        value.currentMediator.userName,
                        value.currentMediator.userId,
                        _titleController.text,
                        _descController.text,
                        value.currentHouse.addr,
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
            ),
          ],
        );
      },
    );
  }
}

class ApplyStepperWidget extends StatelessWidget {
  final Widget child;

  ApplyStepperWidget({
    Key key,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.caption,
      child: Stepper(
        physics: BouncingScrollPhysics(),
        currentStep: 0,
        type: StepperType.vertical,
        steps: [
          Step(
            title: Text("提交调解申请"),
            content: child,
            state: StepState.editing,
            isActive: true,
          ),
          Step(
            title: Text("提交管理员审核"),
            content: Icon(Icons.check),
            state: StepState.indexed,
            isActive: true,
          ),
          Step(
            title: Text("开始调解"),
            content: Icon(Icons.check),
            state: StepState.indexed,
            isActive: true,
          ),
        ],
        controlsBuilder: (BuildContext context,
            {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
          return Container();
        },
      ),
    );
  }
}
