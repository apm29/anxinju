import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class TickerWidget extends StatefulWidget {
  final GlobalKey<TickerWidgetState> key;
  final int tickTimes;
  final String textInitial;
  final VoidCallback onPressed;

  TickerWidget(
      {@required this.key,
      this.tickTimes = 30,
      this.textInitial = "发送短信",
      this.onPressed}):super(key:key);

  @override
  TickerWidgetState createState() =>
      TickerWidgetState(key, tickTimes, textInitial, onPressed);
}

class TickerWidgetState extends State<TickerWidget> {
  int currentTime = -1;
  final GlobalKey<TickerWidgetState> key;
  final int tickTimes;
  final String textInitial;
  final VoidCallback onPressed;

  TickerWidgetState(this.key, this.tickTimes, this.textInitial, this.onPressed);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
        onPressed: currentTime > 0 ? null : onPressed,
        child: currentTime <= 0 ? Text(textInitial) : Text("$currentTime(s)"));
  }

  StreamSubscription<int> subscription;

  void startTick() {
    print('tick');
    subscription = Observable.periodic(Duration(seconds: tickTimes), (i) => i)
        .listen((time) {
      print('$time');
      setState(() {
        currentTime = tickTimes - time;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    subscription?.cancel();
  }
}
