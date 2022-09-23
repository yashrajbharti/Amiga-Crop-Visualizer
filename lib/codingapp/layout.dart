import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:provider/provider.dart';
import 'package:AmigaCrop/codingapp/theme-storage.dart';
import 'package:AmigaCrop/codingapp/Tabs/Info.dart';
import 'package:AmigaCrop/codingapp/Tabs/Track_Tab.dart';
import 'package:AmigaCrop/codingapp/Tabs/Map_Tab.dart';

class Layout extends StatefulWidget {
  Layout({Key? key}) : super(key: key);

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(50.0),
            child: AppBar(
              automaticallyImplyLeading: false,
              elevation: 0,
              actions: const <Widget>[],
              title: Container(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.82,
                  child: Consumer<ThemeModel>(
                    builder: (context, ThemeModel themeNotifier, child) =>
                        Container(
                      color: themeNotifier.isDark
                          ? Color.fromARGB(255, 30, 30, 30)
                          : Color.fromARGB(255, 149, 149, 149),
                      padding: const EdgeInsets.symmetric(vertical: 50.0),
                      child: TabBar(
                        tabs: <Widget>[
                          Tab(
                              child: Text(
                            translate('tabs.track'),
                            style: TextStyle(fontSize: 40),
                          )),
                          Tab(
                            child: Text(
                              translate('tabs.map'),
                              style: TextStyle(fontSize: 40),
                            ),
                          ),
                          Tab(
                            child: Text(
                              translate('tabs.info'),
                              style: TextStyle(fontSize: 40),
                            ),
                          ),
                        ],
                        indicatorColor: Colors.white,
                        indicatorSize: TabBarIndicatorSize.label,
                        indicatorWeight: 5.0,
                        indicatorPadding: EdgeInsets.only(top: 5),
                      ),
                    ),
                  ),
                ),
              ),
            )),
        body: TabBarView(
          children: [
            SendtoLG(),
            MyMap(),
            VerticalCardPagerDemo(),
          ],
        ),
      ),
    );
  }
}
