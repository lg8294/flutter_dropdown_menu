import 'package:dropdown_menu/dropdown_menu.dart';
import 'package:flutter/material.dart';

import 'configs.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ScrollController scrollController;
  @override
  void initState() {
    scrollController = ScrollController();
    globalKey = GlobalKey();
    super.initState();
  }

  /// 构建下拉选项
  DropdownMenu buildDropdownMenu() {
    return DropdownMenu(maxMenuHeight: kDropdownMenuItemHeight * 10,
        //  activeIndex: activeIndex,
        // blur: 0.5,
        menus: [
          DropdownMenuBuilder(
            builder: (BuildContext context) {
              return DropdownListMenu(
                selectedIndex: TYPE_INDEX,
                data: TYPES,
                itemBuilder: buildCheckItem,
              );
            },
            height: kDropdownMenuItemHeight * TYPES.length,
          ),
          DropdownMenuBuilder(
            builder: (BuildContext context) {
              return DropdownListMenu(
                selectedIndex: ORDER_INDEX,
                data: ORDERS,
                itemBuilder: buildCheckItem,
              );
            },
            height: kDropdownMenuItemHeight * ORDERS.length,
          ),
          DropdownMenuBuilder(
              builder: (BuildContext context) {
                return DropdownTreeMenu(
                  selectedIndex: 0,
                  subSelectedIndex: 0,
                  itemExtent: 45.0,
                  background: Colors.red,
                  subBackground: Colors.blueAccent,
                  itemBuilder:
                      (BuildContext context, dynamic data, bool selected) {
                    if (!selected) {
                      return DecoratedBox(
                        decoration: BoxDecoration(
                            border: Border(
                                right: Divider.createBorderSide(context))),
                        child: Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Row(
                              children: <Widget>[
                                Text(data['title']),
                              ],
                            )),
                      );
                    } else {
                      return DecoratedBox(
                        decoration: BoxDecoration(
                            border: Border(
                                top: Divider.createBorderSide(context),
                                bottom: Divider.createBorderSide(context))),
                        child: Container(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            child: Row(
                              children: <Widget>[
                                Container(
                                    color: Theme.of(context).primaryColor,
                                    width: 3.0,
                                    height: 20.0),
                                Padding(
                                    padding: EdgeInsets.only(left: 12.0),
                                    child: Text(data['title'])),
                              ],
                            )),
                      );
                    }
                  },
                  subItemBuilder:
                      (BuildContext context, dynamic data, bool selected) {
                    Color color = selected
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).textTheme.body1.color;

                    return SizedBox(
                      height: 45.0,
                      child: Row(
                        children: <Widget>[
                          Text(
                            data['title'],
                            style: TextStyle(color: color),
                          ),
                          Expanded(
                              child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(data['count'].toString())))
                        ],
                      ),
                    );
                  },
                  getSubData: (dynamic data) {
                    return data['children'];
                  },
                  data: FOODS,
                );
              },
              height: 450.0)
        ]);
  }

  /// 构建头部
  DropdownHeader buildDropdownHeader({DropdownMenuHeadTapCallback onTap}) {
    return DropdownHeader(
      onTap: onTap,
      titles: [TYPES[TYPE_INDEX], ORDERS[ORDER_INDEX], FOODS[0]['children'][0]],
    );
  }

  /// 头部固定的页面
  Widget buildFixHeaderDropdownMenuPage() {
    return DefaultDropdownMenuController(
        child: Column(
      children: <Widget>[
        buildDropdownHeader(),
        Expanded(
            child: Stack(
          children: <Widget>[
            ListView(
              children: <Widget>[Text("123123")],
            ),
            buildDropdownMenu()
          ],
        ))
      ],
    ));
  }

  /// 头部在列表中的页面
  Widget buildInnerListHeaderDropdownMenuPage() {
    return DefaultDropdownMenuController(
        onSelected: ({int menuIndex, int index, int subIndex, dynamic data}) {
          print(
              "menuIndex:$menuIndex index:$index subIndex:$subIndex data:$data");
        },
        child: Stack(
          children: <Widget>[
            CustomScrollView(controller: scrollController, slivers: <Widget>[
              SliverList(
                  key: globalKey,
                  delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                    return Container(
                      color: Colors.black26,
                      child: Image.asset(
                        "images/header.jpg",
                        fit: BoxFit.fill,
                      ),
                    );
                  }, childCount: 1)),
              SliverPersistentHeader(
                delegate: DropdownSliverChildBuilderDelegate(
                    builder: (BuildContext context) {
                  return Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: buildDropdownHeader(onTap: this._onTapHead));
                }),
                pinned: true,
                floating: true,
              ),
              SliverList(
                  delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                return Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Image.asset(
                    "images/body.jpg",
                    fit: BoxFit.fill,
                  ),
                );
              }, childCount: 10)),
            ]),
            Padding(
                padding: EdgeInsets.only(top: 46.0), child: buildDropdownMenu())
          ],
        ));
  }

  GlobalKey globalKey;
  @override
  void dispose() {
    super.dispose();
  }

  void _onTapHead(int index) {
    RenderObject renderObject = globalKey.currentContext.findRenderObject();
    DropdownMenuController controller =
        DefaultDropdownMenuController.of(globalKey.currentContext);

    /// 在列表中，先滑动到顶部，在显示下拉项
    scrollController
        .animateTo(scrollController.offset + renderObject.semanticBounds.height,
            duration: Duration(milliseconds: 150), curve: Curves.ease)
        .whenComplete(() {
      controller.show(index);
    });
  }

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _currentIndex == 0
          ? buildFixHeaderDropdownMenuPage()
          : buildInnerListHeaderDropdownMenuPage(),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        currentIndex: _currentIndex,
        items: [
          {"name": "Fix", "icon": Icons.hearing},
          {"name": "ScrollView", "icon": Icons.list},
        ]
            .map(
              (dynamic data) => BottomNavigationBarItem(
                label: data["name"],
                icon: Icon(data["icon"]),
              ),
            )
            .toList(),
      ),
    );
  }
}
