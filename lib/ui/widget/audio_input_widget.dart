import 'package:flutter/material.dart';

class AudioInputWidget extends StatefulWidget {
  @override
  _AudioInputWidgetState createState() => _AudioInputWidgetState();
}

class _AudioInputWidgetState extends State<AudioInputWidget> {
  bool recording = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (tapDownDetail) {
        setState(() {
          recording = true;
        });
      },
      onTapUp: (tapUpDetail) {
        setState(() {
          recording = false;
        });
      },
      onLongPressUp: () {
        setState(() {
          recording = false;
        });
      },
      onLongPressStart: (longPressDetail) {
        setState(() {
          recording = true;
        });
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: recording ? Colors.blue : Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(8)),
            border: Border.all(color: Colors.lightBlue, width: 0.5)),
        alignment: Alignment.center,
        child: Text(recording ? "松开结束" : "按住说话"),
      ),
    );
  }
}
