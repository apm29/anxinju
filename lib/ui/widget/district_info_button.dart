import 'package:ease_life/index.dart';
import 'package:ease_life/model/district_model.dart';
import 'package:ease_life/model/user_model.dart';
import 'package:ease_life/model/user_role_model.dart';
import 'package:ease_life/model/user_verify_status_model.dart';
import 'package:ease_life/persistance/shared_preferences.dart';
import 'package:ease_life/res/configs.dart';
import 'package:ease_life/ui/widget/refresh_hint_widget.dart';
import 'package:flutter/cupertino.dart';

import '../../utils.dart';

typedef DistrictCallback = void Function(DistrictDetail);

class DistrictInfoButton extends StatefulWidget {
  final VoidCallback onDistrictSelected;

  const DistrictInfoButton({Key key, this.onDistrictSelected})
      : super(key: key);

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
        final bool isLogin = UserModel.of(context).isLogin;
        final UserModel roleModel = UserModel.of(context, listen: true);
        final UserVerifyStatusModel verifyStatusModel =
            UserVerifyStatusModel.of(context);
        final bool isVerified =
            verifyStatusModel.isVerified() || (roleModel.isOnPropertyDuty);
        final String verifyText = verifyStatusModel.getVerifyText();
        final String textString = isLogin
            ? isVerified ? value.getCurrentDistrictName() : verifyText
            : "未登录";
        return FlatButton.icon(
            onPressed: () {
              !isLogin
                  ? toLogin()
                  : isVerified
                      ? showDistrictMenu(context).then((_) {
                          if (widget.onDistrictSelected != null) {
                            widget.onDistrictSelected();
                          }
                        })
                      : showFaceVerifyDialog(context);
              SystemSound.play(SystemSoundType.click);
            },
            icon: Icon(
              Icons.location_on,
              color: Colors.blue,
            ),
            label: Text(textString));
      },
    );
  }

  Future showDistrictMenu(BuildContext parentContext) async {
    return showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      builder: (context) {
        return Consumer<DistrictModel>(
          builder: (BuildContext context, DistrictModel model, Widget child) {
            return BottomSheet(
              onClosing: () {},
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
                        model.selectCurrentDistrict(index, parentContext);
                        SystemSound.play(SystemSoundType.click);
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
