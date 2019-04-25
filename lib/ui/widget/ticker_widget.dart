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
      this.tickTimes = 29,
      this.textInitial = "发送短信",
      this.onPressed})
      : super(key: key);

  @override
  TickerWidgetState createState() =>
      TickerWidgetState(key, tickTimes, textInitial, onPressed);
}

class TickerWidgetState extends State<TickerWidget> {
  int currentTime = 0;
  final GlobalKey<TickerWidgetState> key;
  final int tickTimes;
  final String textInitial;
  final VoidCallback onPressed;
  bool _loading = false;

  TickerWidgetState(this.key, this.tickTimes, this.textInitial, this.onPressed);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        IgnorePointer(
          ignoring: _loading,
          child: Visibility(
            visible: !_loading,
            child: GestureDetector(
                onTap: currentTime > 0 ? null : onPressed,
                child: currentTime <= 0
                    ? Text(
                        textInitial,
                        style: TextStyle(color: Colors.blue),
                      )
                    : Text(
                        "$currentTime(s)",
                        style: TextStyle(color: Colors.grey),
                      )),
          ),
        ),
        Visibility(
          visible: _loading,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
        )
      ],
    );
  }

  StreamSubscription<int> subscription;

  void startTick() {
    print('tick');
    setState(() {
      currentTime = tickTimes + 1;
    });
    subscription =
        Observable.periodic(Duration(seconds: 1), (i) => tickTimes - i)
            .take(tickTimes + 1)
            .listen((time) {
      setState(() {
        currentTime = time;
      });
    });
  }

  void startLoading() {
    setState(() {
      _loading = true;
    });
  }

  void stopLoading() {
    setState(() {
      _loading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
    subscription?.cancel();
  }
}
