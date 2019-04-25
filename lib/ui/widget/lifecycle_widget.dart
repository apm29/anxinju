import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

abstract class LifecycleWidgetState<T extends StatefulWidget> extends State<T>
    with WidgetsBindingObserver {
  List<CancelToken> cancelTokens = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cancelTokens.forEach(cancel);
    super.dispose();
  }

  void cancel(CancelToken token){
    token.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {}
}
