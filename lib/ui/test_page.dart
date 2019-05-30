import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../index.dart';
import '../main.dart';
import '../utils.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MaterialApp(
    home: ProviderTestPage(),
  ));
}

class ProviderTestPage extends StatefulWidget {
  @override
  _ProviderTestPageState createState() => _ProviderTestPageState();
}

class CartModel extends ChangeNotifier {
  double price = 0.0;

  void add(double newValue) {
    price += newValue;
    notifyListeners();
  }

  List<Item> items = [];

  void addItem(Item item) {
    var contain = items.firstWhere((v) => item.id == v.id, orElse: () => null);
    if (contain == null) {
      items.add(item);
    } else {
      contain.count += item.count;
    }
  }
}

class Item {
  double price;
  int id;
  double count;

  Item(this.price, this.id, this.count);
}

class _ProviderTestPageState extends State<ProviderTestPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CartModel>(
      builder: (context) {
        return CartModel();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Consumer<CartModel>(
            builder: (context, value, widget) {
              return Text(value.price.toStringAsFixed(2));
            },
          ),
          actions: <Widget>[
            Consumer<CartModel>(
              builder: (context, value, widget) {
                return FlatButton.icon(
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return CartPage(value.items);
                      }));
                    },
                    icon: Icon(
                      Icons.attach_money,
                      color: Colors.white,
                    ),
                    label: Text(
                      "Buy",
                      style: TextStyle(color: Colors.white),
                    ));
              },
            )
          ],
        ),
        body: ListView.builder(
          itemBuilder: (context, index) {
            Item item = Item(Random(12).nextDouble() * 100, index, 1.0);
            return FlatButton(
              onPressed: () {
                Provider.of<CartModel>(context).addItem(item);
                Provider.of<CartModel>(context).add(item.price * item.count);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    "${index.toString()} ---- \$${item.price.toStringAsFixed(2)}"),
              ),
            );
          },
          itemCount: 21,
        ),
      ),
    );
  }
}

class CartPage extends StatefulWidget {
  final List<Item> lists;

  CartPage(this.lists);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView.builder(
        itemBuilder: (context, index) {
          var item = widget.lists[index];
          return ListTile(
            leading: Text(item.id.toString()),
            title: Text(item.price.toStringAsFixed(2)),
            subtitle: Text("x ${item.count.toStringAsFixed(2)}"),
          );
        },
        itemCount: widget.lists.length,
      ),
    );
  }
}

class TestPage extends StatefulWidget {
  static String routeName = "/test";

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: <Widget>[
          Container(
            child: FutureBuilder<String>(
              builder: (context, snapshot) {
                return InkWell(
                  onLongPress: () {
                    Clipboard.setData(ClipboardData(text: snapshot.data));
                    getExternalStorageDirectory().then((d) {
                      File f = File("${d.absolute.path}/base64.txt");
                      print('${f.path}');
                      f.createSync();
                      f.writeAsString(snapshot.data, flush: true);
                    });
                  },
                  child: Text(
                    snapshot.data,
                  ),
                );
              },
              future:
                  ImagePicker.pickImage(source: ImageSource.gallery).then((f) {
                return getImageBase64(f);
              }),
            ),
          ),
        ],
      ),
    );
  }

  Future<int> someFuture() async {
    await Future.delayed(Duration(seconds: 2));
    return 1;
  }

  RefreshIndicator buildSliver() {
    return RefreshIndicator(
      onRefresh: () async {
        return Future.delayed(Duration(seconds: 2));
      },
      child: CustomScrollView(
        controller: scrollController,
        slivers: <Widget>[
          SliverAppBar(
            centerTitle: true,
            floating: true,
            expandedHeight: 178,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "test".toUpperCase(),
                style: TextStyle(color: Colors.white70),
              ),
              background: Image.asset(
                "images/banner_home.webp",
                fit: BoxFit.cover,
              ),
            ),
            snap: true,
          ),
          SliverPersistentHeader(
            delegate: _HeaderDelegate(
              60.0,
              60.0,
              Container(
                color: Colors.lightBlue,
                child: Center(child: Text("GRID")),
              ),
            ),
            pinned: false,
          ),
          SliverGrid.count(
            crossAxisCount: 2,
            children: <Widget>[
              Container(
                height: 200,
                color: randomColor(),
              ),
              Container(
                height: 200,
                color: randomColor(),
              )
            ],
          ),
          SliverGrid(
            delegate: SliverChildBuilderDelegate((context, index) {
              return Container(
                color: randomColor(),
              );
            }, childCount: 11),
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
          ),
          SliverPersistentHeader(
            delegate: _HeaderDelegate(
              60.0,
              60.0,
              GestureDetector(
                onTap: () {},
                child: Container(
                  color: Colors.lightBlue,
                  child: Center(child: Text("LIST")),
                ),
              ),
            ),
            pinned: false,
          ),
          SliverList(delegate: SliverChildBuilderDelegate((context, index) {
            return Container(
              height: 200,
              color: randomColor(),
            );
          }))
        ],
      ),
    );
  }

  Color randomColor() => Color(Random().nextInt(0xffffffff) | 0xff808080);
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  final double minHeight;
  final double maxHeight;
  final Widget child;

  _HeaderDelegate(this.minHeight, this.maxHeight, this.child);

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(_HeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
