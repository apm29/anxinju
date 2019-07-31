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
                      _doAddApply(context, canAppend: false).then((back) {
                        if (back != null)
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
            })).then((_){
              MediationHistoryModel.of(context).getHistoryMediation(context, true);
              MediationRunningModel.of(context).getRunningMediation(context, true);
            });
          },
          child: ListTile(
            title: Text.rich(
              TextSpan(
                style: Theme.of(context).textTheme.subtitle,
                text: title,
                children: [
                  TextSpan(
                    text: "($result)",
                    style: Theme.of(context).textTheme.subtitle.copyWith(
                          color: data.statusColor,
                        ),
                  ),
                ],
              ),
            ),
            subtitle: Text(
              "开始时间:$time",
              style: Theme.of(context).textTheme.caption,
            ),
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
          return _buildApplyMediationTile(model.apply[index], context);
        },
        itemCount: model.apply.length + 1,
      ),
    );
  }

  Widget _buildApplyMediationTile(MediationApply data, BuildContext context) {
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
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Divider(
                        color: Colors.grey[300],
                        indent: 24,
                        endIndent: 48,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(left: 24),
                            child: Text("文字描述: "),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: Text(
                              data.description,
                              maxLines: 1000,
                              style: Theme.of(context).textTheme.caption,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Divider(
                        color: Colors.grey[300],
                        indent: 24,
                        endIndent: 48,
                      ),
                      Row(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(left: 24),
                            child: Text("图片描述:"),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          (data.images == null || data.images.length == 0)
                              ? Text(
                                  "暂无图片",
                                  style: Theme.of(context).textTheme.caption,
                                )
                              : Expanded(
                                  child: Wrap(
                                    alignment: WrapAlignment.start,
                                    children: data.images.map((url) {
                                      return InkWell(
                                        onTap: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return PicturePage(url);
                                          }));
                                        },
                                        child: SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              4,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              4,
                                          child: Hero(
                                            tag: url,
                                            child: Image.network(
                                              url,
                                              fit: BoxFit.cover,
                                              loadingBuilder: imagePlaceHolder,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                        ],
                      ),
                      Divider(
                        color: Colors.grey[300],
                        indent: 24,
                        endIndent: 48,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(left: 24),
                            child: Text("追加描述: "),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _buildAppendedContent(data, context),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 6,
                      ),
                    ],
                  )
                ],
              ),
            )),
      ),
    );
  }

  List<Widget> _buildAppendedContent(
      MediationApply data, BuildContext context) {
    List<Widget> list = <Widget>[];
    data.appendContent.forEach(
      (content) {
        list.add(
          Text(
            content.appendContent,
            maxLines: 1000,
            style: Theme.of(context).textTheme.caption,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
    if (list.length == 0) {
      list.add(
        Text(
          "暂无",
          maxLines: 1000,
          style: Theme.of(context).textTheme.caption,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
    if (data.status != "3") {
      list.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            GradientButton(
              Text("追加描述"),
              onPressed: () async {
                _doAddApply(context, id: data.id, showDetail: false)
                    .then((back) {
                  if (back != null)
                    MediationApplyModel.of(context)
                        .getApplyMediation(context, true);
                });
              },
            ),
            SizedBox(
              width: 12,
            ),
            GradientButton(
              Text("查看详情"),
              onPressed: () async {
                _doAddApply(context, id: data.id).then((back) {
                  if (back != null)
                    MediationApplyModel.of(context)
                        .getApplyMediation(context, true);
                });
              },
            ),
          ],
        ),
      );
    } else {
      list.add(Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          GradientButton(
            Text("查看详情"),
            onPressed: () async {
              _doAddApply(context, id: data.id, canAppend: false).then((back) {
                if (back != null)
                  MediationApplyModel.of(context)
                      .getApplyMediation(context, true);
              });
            },
          ),
        ],
      ));
    }
    return list;
  }

  Future _doAddApply(
    BuildContext context, {
    int id,
    showDetail = true,
    canAppend = true,
  }) async {
    return Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return ChangeNotifierProvider(
        child: MediationApplyPage(
          id,
          showDetail,
          canAppend,
        ),
        builder: (context) {
          return MediationApplicationAddModel(context);
        },
      );
    }));
  }
}

class MediationApplyPage extends StatefulWidget {
  static String routeName = "/applyMediation";
  final int id;
  final bool showDetail;
  final bool canAppend;

  MediationApplyPage(this.id, this.showDetail, this.canAppend);

  @override
  _MediationApplyPageState createState() => _MediationApplyPageState();
}

class _MediationApplyPageState extends State<MediationApplyPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final GlobalKey<FormState> _formKeyAppend = GlobalKey();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descController = TextEditingController();
  TextEditingController _appendContentController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  bool editable = false;
  int currentStep = 0;

  @override
  void didChangeDependencies() {
    editable = widget.id == null;
    super.didChangeDependencies();
    if (!editable) {
      currentStep = 2;
      if (widget.showDetail) {
        currentStep = 0;
      }
      MediationApplicationAddModel.of(context)
          .getMediationApplyDetail(widget.id)
          .then((_) {
        var model = MediationApplicationAddModel.of(context);
        if (!editable) {
          _titleController.text = model.title;
          _descController.text = model.desc;
        }
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var filledColor = Colors.blue[50];
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme.copyWith(color: Colors.white),
        backgroundColor: Colors.blue,
        title: Text(
          editable ? "添加调解申请" : "调解申请详情",
          style:
              Theme.of(context).textTheme.title.copyWith(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: _buildBody(context, filledColor),
      bottomNavigationBar: _buildBottomAction(),
      resizeToAvoidBottomPadding: true,
      resizeToAvoidBottomInset: false,
      floatingActionButton: !editable && widget.canAppend
          ? FloatingActionButton.extended(
              onPressed: () {
                setState(() {
                  currentStep = currentStep == 0 ? 2 : 0;
                });
              },
              label: Text(currentStep == 2 ? "查看申请详情" : "继续追加描述"),
            )
          : null,
    );
  }

  static const double kVerticalPadding = 8;

  Widget _buildBody(BuildContext context, Color filledColor) {
    return ApplyStepperWidget(
      currentStep: editable ? 0 : currentStep,
      userCurrentStep: getUserCurrentStep(),
      stepOne: _buildStepOne(context, filledColor),
      stepTwo: _buildStepTwo(context, filledColor),
    );
  }

  int getUserCurrentStep() {
    if (widget.showDetail && !widget.canAppend && widget.id == null) {
      return 1;
    } else if (!widget.showDetail && widget.canAppend) {
      return 2;
    } else if (widget.showDetail && widget.canAppend) {
      return 2;
    } else if (widget.showDetail && !widget.canAppend) {
      return 3;
    } else {
      return 4;
    }
  }

  Widget _buildStepOne(
    BuildContext context,
    Color filledColor,
  ) {
    return Container(
      child: Form(
        key: _formKey,
        autovalidate: true,
        child: Material(
          textStyle:
              Theme.of(context).textTheme.body1.copyWith(color: Colors.blue),
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
                  height: kVerticalPadding,
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(154),
                  child: TextFormField(
                    key: ValueKey("title"),
                    enabled: editable,
                    style: Theme.of(context).textTheme.body1,
                    validator: (s) => (s.length >= 4) ? null : "标题长度必须大于等于4个字符",
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      fillColor: filledColor,
                      filled: (!editable) ||
                          (_formKey.currentState?.validate() ?? false),
                    ),
                    controller: _titleController,
                    maxLength: 20,
                  ),
                ),
                SizedBox(
                  height: kVerticalPadding,
                ),
                Divider(),
                SizedBox(
                  height: kVerticalPadding,
                ),
                Container(
                  constraints: BoxConstraints(minWidth: 122),
                  child: Text(
                    "调解描述:",
                  ),
                ),
                SizedBox(
                  height: kVerticalPadding,
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(480),
                  child: TextFormField(
                    maxLines: 50,
                    style: Theme.of(context).textTheme.body1,
                    key: ValueKey("desc"),
                    enabled: editable,
                    validator: (s) =>
                        (s.length >= 10) ? null : "描述长度必须大于等于10字符",
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      fillColor: filledColor,
                      filled: (!editable) ||
                          (_formKey.currentState?.validate() ?? false),
                    ),
                    controller: _descController,
                    maxLength: 140,
                    enableInteractiveSelection: true,
                    keyboardAppearance: Brightness.dark,
                    textInputAction: TextInputAction.done,
                  ),
                ),
                SizedBox(
                  height: kVerticalPadding,
                ),
                Divider(),
                SizedBox(
                  height: kVerticalPadding,
                ),
                Container(
                  constraints: BoxConstraints(minWidth: 122),
                  child: Text("申请人住址:"),
                ),
                SizedBox(
                  height: kVerticalPadding,
                ),
                Consumer<MediationApplicationAddModel>(
                  builder: (BuildContext context,
                      MediationApplicationAddModel model, Widget child) {
                    return Container(
                      height: ScreenUtil().setHeight(116),
                      decoration: BoxDecoration(
                        color: model.currentHouse != null
                            ? filledColor
                            : Colors.transparent,
                        border: Border.all(color: Colors.grey[500]),
                        borderRadius: BorderRadius.all(
                          Radius.circular(6),
                        ),
                      ),
                      child: editable
                          ? DropdownButton<HouseDetail>(
                              iconEnabledColor: Colors.blue,
                              isExpanded: true,
                              iconSize: 36,
                              items: model.houseList
                                  .map((user) => DropdownMenuItem(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
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
                            )
                          : Row(
                              children: <Widget>[
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      model.currentHouse?.addr ?? "",
                                      style: Theme.of(context)
                                          .textTheme
                                          .body1
                                          .copyWith(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    );
                  },
                ),
                SizedBox(
                  height: kVerticalPadding,
                ),
                Container(
                  constraints: BoxConstraints(minWidth: 122),
                  child: Text("调解员:"),
                ),
                SizedBox(
                  height: kVerticalPadding,
                ),
                Consumer<MediationApplicationAddModel>(
                  builder: (BuildContext context,
                      MediationApplicationAddModel model, Widget child) {
                    return Container(
                      height: ScreenUtil().setHeight(116),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[500]),
                        borderRadius: BorderRadius.all(
                          Radius.circular(6),
                        ),
                        color:
                            model.currentMediator != null ? filledColor : null,
                      ),
                      child: editable
                          ? DropdownButton<UserInfo>(
                              iconEnabledColor: Colors.blue,
                              isExpanded: true,
                              iconSize: 36,
                              items: model.mediatorList
                                  .map((user) => DropdownMenuItem(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
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
                            )
                          : Row(
                              children: <Widget>[
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      model.currentMediator?.userName ?? "",
                                      style: Theme.of(context)
                                          .textTheme
                                          .body1
                                          .copyWith(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    );
                  },
                ),
                SizedBox(
                  height: kVerticalPadding,
                ),
                Divider(),
                SizedBox(
                  height: kVerticalPadding,
                ),
                Text(editable ? "点击加号添加图片描述:" : "图片描述"),
                SizedBox(
                  height: kVerticalPadding,
                ),
                Consumer<MediationApplicationAddModel>(
                  builder: (BuildContext context,
                      MediationApplicationAddModel model, Widget child) {
                    List<Widget> list = model.images.map(
                      (url) {
                        return Container(
                          height: MediaQuery.of(context).size.width / 4,
                          width: MediaQuery.of(context).size.width / 4,
                          decoration: BoxDecoration(
                            border:
                                Border.all(width: 0.5, color: Colors.blue[200]),
                          ),
                          margin: EdgeInsets.all(kVerticalPadding),
                          child: Stack(
                            children: <Widget>[
                              Positioned.fill(
                                child: Image.network(
                                  url,
                                  fit: BoxFit.cover,
                                  loadingBuilder: imagePlaceHolder,
                                ),
                              ),
                              editable
                                  ? Align(
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
                                  : Container(),
                            ],
                          ),
                        );
                      },
                    ).toList();
                    if (editable)
                      list.add(
                        Container(
                          height: MediaQuery.of(context).size.width / 4,
                          width: MediaQuery.of(context).size.width / 4,
                          margin: EdgeInsets.all(kVerticalPadding),
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
    );
  }

  Widget _buildStepTwo(BuildContext context, Color filledColor) {
    List<Widget> list = [];
    int count = 0;
    list.addAll(MediationApplicationAddModel.of(context).appendContent.map(
      (content) {
        count++;
        return Text(
          "追加描述$count :  ${content.appendContent}",
          maxLines: 1000,
          style: Theme.of(context).textTheme.body1,
          overflow: TextOverflow.ellipsis,
        );
      },
    ).toList());
    list.addAll([
      SizedBox(
        height: kVerticalPadding,
      ),
      Container(
        constraints: BoxConstraints(minWidth: 122),
        child: Text(
          "新增追加描述:",
        ),
      ),
      SizedBox(
        height: kVerticalPadding,
      ),
      SizedBox(
        height: ScreenUtil().setHeight(480),
        child: TextFormField(
          maxLines: 50,
          style: Theme.of(context).textTheme.body1,
          key: ValueKey("append_content"),
          validator: (s) => (s.length >= 10) ? null : "追加描述长度必须大于等于10字符",
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            fillColor: filledColor,
            filled: (!editable) ||
                (_formKeyAppend.currentState?.validate() ?? false),
          ),
          controller: _appendContentController,
          maxLength: 140,
          textInputAction: TextInputAction.done,
        ),
      ),
    ]);
    return Form(
      key: _formKeyAppend,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: list,
      ),
    );
  }

  Widget _buildBottomAction() {
    if (!editable) {
      return Consumer<MediationApplicationAddModel>(
        builder: (BuildContext context, MediationApplicationAddModel value,
            Widget child) {
          return currentStep == 0 || !widget.canAppend
              ? Container(
                  height: 1,
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: GradientButton(
                        Text(
                          "追加描述",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        gradient: LinearGradient(colors: [
                          Colors.redAccent,
                          Colors.deepOrange,
                          Colors.redAccent
                        ]),
                        unconstrained: false,
                        borderRadius: 0,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        onPressed: () async {
                          if (_formKeyAppend.currentState.validate()) {
                            if (value.validate()) {
                              var kfBaseResp = await ApiKf.mediationAppend(
                                widget.id.toString(),
                                ChatGroupConfig.APP_ID,
                                _appendContentController.text,
                              );
                              if (kfBaseResp.success) {
                                value.reset();
                                Navigator.of(context).pop(true);
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
                  Colors.redAccent,
                  Colors.deepOrange,
                  Colors.redAccent
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
                        Navigator.of(context).pop(true);
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
  final Widget stepOne;
  final Widget stepTwo;
  final currentStep;
  final int userCurrentStep;

  ApplyStepperWidget({
    Key key,
    this.stepOne,
    this.stepTwo,
    this.currentStep = 0,
    this.userCurrentStep,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('$userCurrentStep');
    var model = MediationApplicationAddModel.of(context);
    var list = [
      Step(
        title: Text(userCurrentStep <= 0 ? "提交调解申请" : "已经提交调解申请"),
        subtitle: Text(userCurrentStep <= 0
            ? "请务必填写详细的信息,\n请不要提交虚假的申请信息,\n提交后不可修改"
            : "已提交的调解信息,\n当前状态不可修改"),
        content: stepOne ?? Container(),
        state: currentStep == 0 ? StepState.editing : StepState.complete,
        isActive: true,
      ),
      Step(
        title: Text(
          userCurrentStep <= 1 ? "提交管理员审核" : "管理员审核",
        ),
        subtitle: Text(userCurrentStep <= 1
            ? "提交调解申请后,\n工作人员会在后台审核相关信息,\n期间您可以继续追加具体描述信息"
            : "管理员审核相关信息"),
        content: Icon(Icons.check),
        state: currentStep == 2 ? StepState.complete : StepState.indexed,
        isActive: true,
      ),
      Step(
        title: Text("追加描述"),
        subtitle: Text(
          userCurrentStep <= 2 ? "您可以在该阶段继续追加具体描述信息" : "已追加的关于调解的具体描述信息",
        ),
        content: stepTwo ?? Container(),
        state: currentStep == 2 ? StepState.editing : StepState.indexed,
        isActive: true,
      ),
      Step(
        title: Text(userCurrentStep <= 2?"申请通过,开始调解":"调解纠纷"),
        subtitle: Text("申请通过后,\n调解各方将在调解聊天室开始调解"),
        content: Icon(Icons.check),
        state: StepState.indexed,
        isActive: true,
      ),
    ];
    if (userCurrentStep > 2) {
      list.add(
        Step(
          title: Text("调解详情"),
          subtitle: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.5
                ),
                child: Text(
                  "调解人员:   ${model.chatUser}",
                  maxLines: 100,
                ),
              ),
              Text("调解开始时间:   ${model.startTime}"),
              Text("调解结束时间:   ${model.endTime}"),
            ],
          ),
          content: Icon(Icons.check),
          state: StepState.indexed,
          isActive: true,
        ),
      );
    }
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.caption,
      child: Stepper(
        physics: BouncingScrollPhysics(),
        currentStep: currentStep,
        type: StepperType.vertical,
        steps: list,
        controlsBuilder: (BuildContext context,
            {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
          return Container();
        },
      ),
    );
  }
}
