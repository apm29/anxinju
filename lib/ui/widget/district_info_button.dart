import 'package:ease_life/index.dart';
import 'package:ease_life/model/district_model.dart';
import 'package:ease_life/model/user_model.dart';
import 'package:ease_life/model/user_verify_status_model.dart';
import 'package:ease_life/persistance/shared_preferences.dart';
import 'package:ease_life/res/configs.dart';
import 'package:ease_life/ui/widget/refresh_hint_widget.dart';
import 'package:flutter/cupertino.dart';

import '../../utils.dart';

typedef DistrictCallback = void Function(DistrictDetail);

class DistrictInfoButton extends StatefulWidget {

  const DistrictInfoButton({Key key}) : super(key: key);

  @override
  _DistrictInfoButtonState createState() => _DistrictInfoButtonState();
}

class _DistrictInfoButtonState extends State<DistrictInfoButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DistrictModel>(
      builder: (BuildContext context, DistrictModel value, Widget child) {
        bool isLogin = UserModel.of(context).isLogin;
        bool isVerified = UserVerifyStatusModel.of(context).isVerified();
        String verifyText = UserVerifyStatusModel.of(context).getVerifyText();
        var textString = isLogin
            ? isVerified
                ? value.getCurrentDistrictName()
                : verifyText
            : "未登录";
        return FlatButton.icon(
            onPressed: () {
              !isLogin
                  ? toLogin()
                  : isVerified
                      ? showDistrictMenu(context)
                      : showFaceVerifyDialog(context);
            },
            icon: Icon(
              Icons.location_on,
              color: Colors.blue,
            ),
            label: Text(textString));
      },
    );
  }

  void showDistrictMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Consumer<DistrictModel>(
          builder: (BuildContext context, DistrictModel model, Widget child) {
            return BottomSheet(
              onClosing: () {
                print('onClose');
              },
              builder: (context) {
                if (!model.hasData) {
                  return RefreshHintWidget(
                    onPress: () async {
                      model.tryFetchCurrentDistricts();
                    },
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    var isSelected = model.isSelected(index);
                    return ListTile(
                      title: Text(model.getDistrictName(index)),
                      subtitle: Text(model.getDistrictAddress(index)),
                      onTap: () {
                        model.selectCurrentDistrict(index,context);
                        Navigator.of(context).pop();
                      },
                      selected: isSelected,
                      leading: Visibility(
                        visible: isSelected,
                        child: Icon(
                          Icons.location_on,
                        ),
                      ),
                    );
                  },
                  itemCount: model.countOfDistricts(),
                );
              },
            );
          },
        );
      },
    );
  }



  toLogin() {
    Navigator.of(context).pushNamed("/login");
  }
}
