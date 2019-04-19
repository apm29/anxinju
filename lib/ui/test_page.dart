import 'dart:async';

import 'package:ease_life/bloc/bloc_provider.dart';
import 'package:ease_life/model/base_response.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  Completer<String> completer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder(
        builder: (context, snap) {
          return Container();
        },
        future: completer.future,
      ),
    );
  }
}
