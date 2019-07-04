import 'package:ease_life/model/district_model.dart';
import 'package:ease_life/ui/widget/refresh_hint_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LocationSwitchWidget extends StatefulWidget {
  @override
  _LocationSwitchWidgetState createState() => _LocationSwitchWidgetState();
}

const _kAnimationDuration = const Duration(milliseconds: 800);

class _LocationSwitchWidgetState extends State<LocationSwitchWidget>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this,
        duration: _kAnimationDuration,
        reverseDuration: _kAnimationDuration);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );
    _controller.value = 1;
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        _controller.reverse();
        showDistrictMenu(context);
      },
      child: AnimatedIcon(
        size: 36,
        icon: AnimatedIcons.close_menu,
        color: Colors.white,
        progress: _animation,
      ),
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
                    var isSelected =
                        model.currentDistrict == model.allDistricts[index];
                    return ListTile(
                      title: Text(model.getDistrictName(index)),
                      subtitle: Text(model.getDistrictAddress(index)),
                      onTap: () {
                        model.currentDistrict = model.allDistricts[index];
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
                  itemCount: model.allDistricts.length,
                );
              },
            );
          },
        );
      },
    ).then((_) {
      _controller.forward();
    });
  }
}
