import 'package:ease_life/index.dart';
import 'package:ease_life/persistance/shared_preferences.dart';
import 'package:flutter/cupertino.dart';

typedef DistrictCallback = void Function(DistrictInfo);

class DistrictInfoButton extends StatefulWidget {
  final DistrictCallback callback;

  const DistrictInfoButton({Key key, this.callback}) : super(key: key);

  @override
  _DistrictInfoButtonState createState() => _DistrictInfoButtonState();
}

class _DistrictInfoButtonState extends State<DistrictInfoButton> {
  @override
  Widget build(BuildContext context) {
    var findAllDistrict = Api.findAllDistrict();
    return StreamBuilder<DistrictInfo>(
      stream: BlocProviders.of<ApplicationBloc>(context).currentDistrict,
      builder: (context, snapShot) {
        var textString =
            isLogin() ? snapShot.data?.districtName ?? "无小区" : "未登录";
        return FlatButton.icon(
            onPressed: () {
              !isLogin()
                  ? toLogin()
                  : showModalBottomSheet<DistrictInfo>(
                      context: context,
                      builder: (context) {
                        return BottomSheet(
                            onClosing: () {},
                            builder: (context) {
                              return FutureBuilder<
                                  BaseResponse<List<DistrictInfo>>>(
                                future: findAllDistrict,
                                builder: (context, districtSnap) {
                                  if (districtSnap.hasData &&
                                      !districtSnap.hasError &&
                                      districtSnap.data.success()) {
                                    return SizedBox(
                                      height: ScreenUtil().setHeight(800),
                                      child: ListView(
                                        shrinkWrap: true,
                                        children:
                                            districtSnap.data.data.map((d) {
                                          return FlatButton(
                                            onPressed: () {
                                              BlocProviders.of<ApplicationBloc>(
                                                      context)
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
                                  } else {
                                    return Wrap(
                                      children: <Widget>[
                                        Container(
                                          alignment:
                                              AlignmentDirectional.center,
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: <Widget>[
                                              CircularProgressIndicator(),
                                              Text(
                                                "获取小区列表..",
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
            },
            icon: Icon(
              Icons.location_on,
              color: Colors.blue,
            ),
            label: Text(textString));
      },
    );
  }

  toLogin() {
    Navigator.of(context).pushNamed("/login");
  }
}
