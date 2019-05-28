import 'package:ease_life/index.dart';
import 'package:ease_life/persistance/shared_preferences.dart';
import 'package:ease_life/res/strings.dart';
import 'package:flutter/cupertino.dart';

import '../../utils.dart';

typedef DistrictCallback = void Function(DistrictInfo);

class DistrictInfoButton extends StatefulWidget {
  final DistrictCallback callback;

  const DistrictInfoButton({Key key, this.callback}) : super(key: key);

  @override
  _DistrictInfoButtonState createState() => _DistrictInfoButtonState();
}

class _DistrictInfoButtonState extends State<DistrictInfoButton> {
  Future<BaseResponse<List<DistrictInfo>>> districtFuture;

  @override
  void initState() {
    super.initState();
    districtFuture = Api.findAllDistrict();
  }

  @override
  Widget build(BuildContext context) {
    var findAllDistrict = districtFuture;
    return StreamBuilder<DistrictInfo>(
      stream: BlocProviders.of<ApplicationBloc>(context).currentDistrict,
      builder: (context, snapShot) {
        var textString = isLogin()
            ? isCertificated() ? snapShot.data?.districtName ?? "无小区" : "未认证"
            : "未登录";
        return FlatButton.icon(
            onPressed: () {
              !isLogin()
                  ? toLogin()
                  : isCertificated()
                      ? showSelectDistrict(context, findAllDistrict)
                      : showCertificationDialog(context);
            },
            icon: Icon(
              Icons.location_on,
              color: Colors.blue,
            ),
            label: Text(textString));
      },
    );
  }

  Future<dynamic> showSelectDistrict(BuildContext context,
      Future<BaseResponse<List<DistrictInfo>>> findAllDistrict) {
    return showModalBottomSheet<DistrictInfo>(
        context: context,
        builder: (context) {
          return BottomSheet(
              onClosing: () {},
              builder: (context) {
                return FutureBuilder<BaseResponse<List<DistrictInfo>>>(
                  future: findAllDistrict,
                  builder: (context, districtSnap) {
                    if (districtSnap.hasData &&
                        !districtSnap.hasError &&
                        districtSnap.data.success()) {
                      return SizedBox(
                        height: ScreenUtil().setHeight(800),
                        child: ListView(
                          shrinkWrap: true,
                          children: districtSnap.data.data.map((d) {
                            return FlatButton(
                              onPressed: () {
                                BlocProviders.of<ApplicationBloc>(context)
                                    .setCurrentDistrict(d);
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                d.districtName,
                                textAlign: TextAlign.center,
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    } else if (districtSnap.hasData &&
                        !districtSnap.data.success()) {
                      return Wrap(
                        children: <Widget>[
                          Container(
                            alignment: AlignmentDirectional.center,
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: <Widget>[
                                Icon(Icons.refresh),
                                Text(
                                  "获取${Strings.districtClass}列表失败",
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  "点击重新获取",
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Wrap(
                        children: <Widget>[
                          Container(
                            alignment: AlignmentDirectional.center,
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: <Widget>[
                                CircularProgressIndicator(),
                                Text(
                                  "获取${Strings.districtClass}列表..",
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                  },
                );
              });
        }).then((district) {
      if (widget.callback != null) {
        widget.callback(district);
      }
    });
  }

  toLogin() {
    Navigator.of(context).pushNamed("/login");
  }
}
