import 'package:ease_life/index.dart';
import 'package:rxdart/rxdart.dart';

// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AnimatedListSample extends StatefulWidget {
  @override
  _AnimatedListSampleState createState() => new _AnimatedListSampleState();
}

class _AnimatedListSampleState extends State<AnimatedListSample> {
  final GlobalKey<AnimatedListState> _listKey = new GlobalKey<AnimatedListState>();
  ListModel<int> _list;
  int _selectedItem;
  int _nextItem; // The next item inserted when the user presses the '+' button.

  @override
  void initState() {
    super.initState();
    _list = new ListModel<int>(
      listKey: _listKey,
      initialItems: <int>[0, 1, 2],
      removedItemBuilder: _buildRemovedItem,
    );
    _nextItem = 3;
  }

  // Used to build list items that haven't been removed.
  Widget _buildItem(BuildContext context, int index, Animation<double> animation) {
    return new CardItem(
      animation: animation,
      item: _list[index],
      selected: _selectedItem == _list[index],
      onTap: () {
        setState(() {
          _selectedItem = _selectedItem == _list[index] ? null : _list[index];
        });
      },
    );
  }

  // Used to build an item after it has been removed from the list. This method is
  // needed because a removed item remains  visible until its animation has
  // completed (even though it's gone as far this ListModel is concerned).
  // The widget will be used by the [AnimatedListState.removeItem] method's
  // [AnimatedListRemovedItemBuilder] parameter.
  Widget _buildRemovedItem(int item, BuildContext context, Animation<double> animation) {
    return new CardItem(
      animation: animation,
      item: item,
      selected: false,
      // No gesture detector here: we don't want removed items to be interactive.
    );
  }

  // Insert the "next item" into the list model.
  void _insert() {
    final int index = _selectedItem == null ? _list.length : _list.indexOf(_selectedItem);
    _list.insert(index, _nextItem++);
  }

  // Remove the selected item from the list model.
  void _remove() {
    if (_selectedItem != null) {
      _list.removeAt(_list.indexOf(_selectedItem));
      setState(() {
        _selectedItem = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('AnimatedList'),
          actions: <Widget>[
            new IconButton(
              icon: const Icon(Icons.add_circle),
              onPressed: _insert,
              tooltip: 'insert a new item',
            ),
            new IconButton(
              icon: const Icon(Icons.remove_circle),
              onPressed: _remove,
              tooltip: 'remove the selected item',
            ),
          ],
        ),
        body: new Padding(
          padding: const EdgeInsets.all(16.0),
          child: new AnimatedList(
            key: _listKey,
            initialItemCount: _list.length,
            itemBuilder: _buildItem,
          ),
        ),
      ),
    );
  }
}

/// Keeps a Dart List in sync with an AnimatedList.
///
/// The [insert] and [removeAt] methods apply to both the internal list and the
/// animated list that belongs to [listKey].
///
/// This class only exposes as much of the Dart List API as is needed by the
/// sample app. More list methods are easily added, however methods that mutate the
/// list must make the same changes to the animated list in terms of
/// [AnimatedListState.insertItem] and [AnimatedList.removeItem].
class ListModel<E> {
  ListModel({
    @required this.listKey,
    @required this.removedItemBuilder,
    Iterable<E> initialItems,
  }) : assert(listKey != null),
        assert(removedItemBuilder != null),
        _items = new List<E>.from(initialItems ?? <E>[]);

  final GlobalKey<AnimatedListState> listKey;
  final dynamic removedItemBuilder;
  final List<E> _items;

  AnimatedListState get _animatedList => listKey.currentState;

  void insert(int index, E item) {
    _items.insert(index, item);
    _animatedList.insertItem(index);
  }

  E removeAt(int index) {
    final E removedItem = _items.removeAt(index);
    if (removedItem != null) {
      _animatedList.removeItem(index, (BuildContext context, Animation<double> animation) {
        return removedItemBuilder(removedItem, context, animation);
      });
    }
    return removedItem;
  }

  int get length => _items.length;
  E operator [](int index) => _items[index];
  int indexOf(E item) => _items.indexOf(item);
}

/// Displays its integer item as 'item N' on a Card whose color is based on
/// the item's value. The text is displayed in bright green if selected is true.
/// This widget's height is based on the animation parameter, it varies
/// from 0 to 128 as the animation varies from 0.0 to 1.0.
class CardItem extends StatelessWidget {
  const CardItem({
    Key key,
    @required this.animation,
    this.onTap,
    @required this.item,
    this.selected: false
  }) : assert(animation != null),
        assert(item != null && item >= 0),
        assert(selected != null),
        super(key: key);

  final Animation<double> animation;
  final VoidCallback onTap;
  final int item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.display1;
    if (selected)
      textStyle = textStyle.copyWith(color: Colors.lightGreenAccent[400]);
    return new Padding(
      padding: const EdgeInsets.all(2.0),
      child: new SizeTransition(
        axis: Axis.vertical,
        sizeFactor: animation,
        child: new GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: new SizedBox(
            height: 128.0,
            child: new Card(
              color: Colors.primaries[item % Colors.primaries.length],
              child: new Center(
                child: new Text('Item $item', style: textStyle),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(new AnimatedListSample());
}
class ProviderTestPage extends StatefulWidget {
  @override
  _ProviderTestPageState createState() => _ProviderTestPageState();
}

class CartModel extends ChangeNotifier {
  double price = 0.0;

  List<CartItem> items = [];

  void addItem(CartItem item) {
    price+=item.price * item.count;
    var contain = items.firstWhere((v) => item.id == v.id, orElse: () => null);
    if (contain == null) {
      items.add(item);
    } else {
      contain.count += item.count;
    }
    notifyListeners();
  }
}

class CartItem {
  double price;
  int id;
  double count;

  CartItem(this.price, this.id, this.count);
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
            CartItem item = CartItem(Random(12).nextDouble() * 100, index, 1.0);
            return FlatButton(
              onPressed: () {
                Provider.of<CartModel>(context).addItem(item);
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
  final List<CartItem> lists;

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
