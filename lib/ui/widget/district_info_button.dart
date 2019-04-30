import 'package:ease_life/index.dart';
import 'package:ease_life/persistance/shared_preferences.dart';
import 'package:flutter/cupertino.dart';

typedef DistrictCallback = void Function(DistrictInfo);

class DistrictInfoButton extends StatelessWidget {
  final DistrictCallback callback;
  const DistrictInfoButton({
    Key key,this.callback
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DistrictInfo>(
      stream: BlocProviders.of<ApplicationBloc>(context).currentDistrict,
      builder: (context, snapShot) {
        var textString =
            isLogin() ? snapShot.data?.districtName ?? "无小区" : "未登录";
        return FlatButton.icon(
            onPressed: () {
              showModalBottomSheet<DistrictInfo>(
                  context: context,
                  builder: (context) {
                    return BottomSheet(
                        onClosing: () {},
                        builder: (context) {
                          return FutureBuilder<
                              BaseResponse<List<DistrictInfo>>>(
                            future: Api.findAllDistrict(),
                            builder: (context, snapShot) {
                              if (snapShot.hasData &&
                                  !snapShot.hasError &&
                                  snapShot.data.success()) {
                                return ListView.builder(
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return FlatButton(
                                      onPressed: () {
                                        BlocProviders.of<ApplicationBloc>(
                                                context)
                                            .setCurrentDistrict(
                                                snapShot.data.data[index]);
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        snapShot.data.data[index].districtName,
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  },
                                  itemCount: snapShot.data.data.length,
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
                  }).then((district){
                    if(callback!=null){
                      callback(district);
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
}
