import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

typedef OnItemSelected = void Function(int);

class TextPickerWidget extends StatelessWidget {
  final String text;
  final Icon trailing;
  final List<String> items;
  final OnItemSelected onItemSelected;

  TextPickerWidget({this.text, this.trailing, this.items, this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showPicker(context);
      },
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.all(Radius.circular(3))),
        child: Row(children: <Widget>[
          Expanded(
            child: Text(text ?? "请选择"),
          ),
          Icon(trailing ?? Icons.keyboard_arrow_down)
        ]),
      ),
    );
  }

  void showPicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return CupertinoPicker.builder(
            childCount: items.length,
            itemExtent: ScreenUtil().setHeight(100),
            onSelectedItemChanged: onItemSelected,
            itemBuilder: (context, index) {
              return Center(child: Text(items[index]));
            },
          );
        });
  }
}
