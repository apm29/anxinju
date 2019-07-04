import 'package:flutter/material.dart';
import 'gradient_button.dart';

class RefreshHintWidget extends StatefulWidget {
  final PressCallback onPress;

  const RefreshHintWidget({Key key, @required this.onPress}) : super(key: key);

  @override
  _RefreshHintWidgetState createState() => _RefreshHintWidgetState();
}

class _RefreshHintWidgetState extends State<RefreshHintWidget>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      lowerBound: 0.0,
      upperBound: 10.0,
      duration: const Duration(seconds: 5),
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton.icon(
        onPressed: () async{
          _controller.forward();
          await widget?.onPress?.call();
        },
        icon: RotationTransition(
          turns: _controller,
          child: Icon(Icons.refresh),
        ),
        label: Text("点击刷新"));
  }
}
