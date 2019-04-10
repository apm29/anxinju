import 'package:flutter/material.dart';

class RefreshListView extends StatefulWidget {
  @override
  _RefreshListViewState createState() => _RefreshListViewState();
  final ListView listView;
  final VoidCallback onRefresh;

  RefreshListView(this.listView, this.onRefresh);
}

class _RefreshListViewState extends State<RefreshListView> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        child: widget.listView, onRefresh: widget.onRefresh);
  }
}
