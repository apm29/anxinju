import 'package:flutter/material.dart';

class TextIconButton extends StatelessWidget {
  final onTap;
  final imageProvider;
  final text;

  TextIconButton(
      {this.onTap, @required this.imageProvider, @required this.text});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: <Widget>[Image(image: imageProvider), Text(text)],
      ),
    );
  }
}
