import 'package:ease_life/bloc/bloc_provider.dart';
import 'package:ease_life/model/base_response.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var applicationBloc = BlocProviders.of<ApplicationBloc>(context);
    return Scaffold(
      appBar: AppBar(),
      body: Center(),
    );
  }
}
