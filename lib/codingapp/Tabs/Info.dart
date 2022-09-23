import 'dart:io';
import 'dart:ui';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:AmigaCrop/codingapp/kml/LookAt.dart';
import 'package:AmigaCrop/codingapp/theme-storage.dart';
import 'package:AmigaCrop/codingapp/kml/orbit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ssh2/ssh2.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerticalCardPagerDemo extends StatefulWidget {
  @override
  _VerticalCardPagerDemoState createState() => _VerticalCardPagerDemoState();
}

int x = 0;
void jumpToPage(int page) {
  x = page;
}

var _duration = 3000;
bool loading = false;
String retrykml = "";
String retryname = "";
Future retryButton(String KML, String name, dynamic duration) async {
  retrykml = await KML;
  retryname = await name;
  _duration = await duration;
}

class _VerticalCardPagerDemoState extends State<VerticalCardPagerDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationiconcontroller;

  bool isOrbiting = false;
  double latvalue = 28.55665656297236;
  double longvalue = -17.885454520583153;

  // ignore: unused_element
  _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    _rotationiconcontroller = AnimationController(
      duration: const Duration(seconds: 50),
      vsync: this,
    );
    super.initState();
  }

  @override
  void dispose() {
    _rotationiconcontroller.dispose();
    super.dispose();
  }

  playOrbit() async {
    await LGConnection()
        .buildOrbit(Orbit.buildOrbit(Orbit.generateOrbitTag(
            LookAt(longvalue, latvalue, "6341.7995674", "0", "0"))))
        .then((value) async {
      await LGConnection().startOrbit();
    });
    setState(() {
      isOrbiting = true;
    });
  }

  stopOrbit() async {
    await LGConnection().stopOrbit();
    setState(() {
      isOrbiting = false;
    });
  }

  void _showToast(String x, bool blackandwhite) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "$x",
          style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.normal,
              fontFamily: "GoogleSans",
              color: Colors.white),
        ),
        duration: Duration(seconds: 3),
        backgroundColor: blackandwhite
            ? Color.fromARGB(255, 22, 22, 22)
            : Color.fromARGB(250, 43, 43, 43),
        width: 500.0,
        padding: const EdgeInsets.fromLTRB(
          35,
          20,
          15,
          20,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        action: SnackBarAction(
          textColor: Color.fromARGB(255, 125, 164, 243),
          label: translate('Track.close'),
          onPressed: () {},
        ),
      ),
    );
  }

  showAlertDialog(String title, String msg, bool blackandwhite) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 3),
            child: AlertDialog(
              backgroundColor: blackandwhite
                  ? Color.fromARGB(255, 16, 16, 16)
                  : Color.fromARGB(255, 33, 33, 33),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Image.asset(
                        "assets/sad.png",
                        width: 250,
                        height: 250,
                      )),
                  Text(
                    '$title',
                    style: TextStyle(
                      fontSize: 25,
                      color: Color.fromARGB(255, 204, 204, 204),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 320,
                height: 180,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('$msg',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color.fromARGB(
                              255,
                              204,
                              204,
                              204,
                            ),
                          ),
                          textAlign: TextAlign.center),
                      SizedBox(
                          width: 300,
                          child: Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 2,
                                  shadowColor: Colors.black,
                                  primary: Color.fromARGB(255, 220, 220, 220),
                                  padding: EdgeInsets.all(15),
                                  shape: StadiumBorder(),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Wrap(
                                  children: <Widget>[
                                    Text(translate('dismiss'),
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.black)),
                                  ],
                                ),
                              ))),
                    ]),
              ),
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> track_cards = [
      // Historical Track
      Consumer<ThemeModel>(
          builder: (context, ThemeModel themeNotifier, child) => Container(
                margin: EdgeInsets.fromLTRB(90, 0, 90, 0),
                padding: EdgeInsets.only(top: 20),
                child: Column(children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      translate('Track.hist'),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 34.5,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  new Row(
                    children: <Widget>[
                      new Padding(
                        padding: new EdgeInsets.only(
                          left: 70.0,
                          right: 10.0,
                        ),
                        child: ClipRRect(
                          child: Container(
                            color: Color.fromARGB(255, 125, 164, 243),
                            child: Icon(Icons.info_outline_rounded,
                                color: Colors.white, size: 36.0),
                          ),
                        ),
                      ),
                      new Expanded(
                          flex: 2,
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Text(
                                translate("info.description"),
                                style: new TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          )),
                      SizedBox(
                        height: 90,
                      ),
                      new Expanded(
                          flex: 9,
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Text(
                                translate(""),
                                style: new TextStyle(
                                    fontSize: 18.5, color: Colors.white70),
                              ),
                            ],
                          )),
                      new Padding(
                          padding: new EdgeInsets.only(
                        right: 70.0,
                      )),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  new Row(
                    children: <Widget>[
                      new Padding(
                        padding: new EdgeInsets.only(
                          left: 70.0,
                          right: 10.0,
                        ),
                        child: ClipRRect(
                          child: Container(
                            color: Color.fromARGB(255, 125, 164, 243),
                            child: Icon(Icons.calendar_month_rounded,
                                color: Colors.white, size: 36.0),
                          ),
                        ),
                      ),
                      new Expanded(
                          flex: 2,
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Text(
                                translate("info.date"),
                                style: new TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          )),
                      new Expanded(
                          flex: 9,
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Text(
                                translate(""),
                                style: new TextStyle(
                                  fontSize: 18.5,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          )),
                      SizedBox(
                        height: 90,
                      ),
                      new Padding(
                          padding: new EdgeInsets.only(
                        right: 70.0,
                      )),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  new Row(
                    children: <Widget>[
                      new Padding(
                        padding: new EdgeInsets.only(
                          left: 70.0,
                          right: 10.0,
                        ),
                        child: ClipRRect(
                          child: Container(
                            color: Color.fromARGB(255, 125, 164, 243),
                            child: Icon(Icons.map_sharp,
                                color: Colors.white, size: 36.0),
                          ),
                        ),
                      ),
                      new Expanded(
                          flex: 2,
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Text(
                                translate("info.legend"),
                                style: new TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          )),
                      SizedBox(
                        height: 90,
                      ),
                      new Expanded(
                        flex: 9,
                        child: new Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(translate(""),
                                style: TextStyle(
                                    fontSize: 18.5,
                                    color: Colors.white70,
                                    fontFamily: "GoogleSans")),
                            SizedBox(
                              height: 8,
                            ),
                          ],
                        ),
                      ),
                      new Padding(
                          padding: new EdgeInsets.only(
                        right: 70.0,
                      )),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  new Row(
                    children: <Widget>[
                      new Padding(
                        padding: new EdgeInsets.only(
                          left: 70.0,
                          right: 10.0,
                        ),
                        child: ClipRRect(
                          child: Container(
                            color: Color.fromARGB(255, 125, 164, 243),
                            child: Icon(Icons.link,
                                color: Colors.white, size: 36.0),
                          ),
                        ),
                      ),
                      new Expanded(
                          flex: 2,
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Text(
                                translate("info.sources"),
                                style: new TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          )),
                      new Padding(
                          padding: new EdgeInsets.only(
                        right: 70.0,
                      )),
                    ],
                  ),
                ]),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 125, 164, 243),
                  border: Border.all(
                    color: Colors.transparent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: themeNotifier.isDark
                          ? Colors.black
                          : Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
              )),

      // Lava Flow Track
      Consumer<ThemeModel>(
          builder: (context, ThemeModel themeNotifier, child) => Container(
                margin: EdgeInsets.fromLTRB(90, 0, 90, 0),
                padding: EdgeInsets.only(top: 20),
                child: Column(children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      translate('Track.lava'),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 34.5,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  new Row(
                    children: <Widget>[
                      new Padding(
                        padding: new EdgeInsets.only(
                          left: 70.0,
                          right: 10.0,
                        ),
                        child: ClipRRect(
                          child: Container(
                            color: Color.fromARGB(255, 125, 164, 243),
                            child: Icon(Icons.info_outline_rounded,
                                color: Colors.white, size: 36.0),
                          ),
                        ),
                      ),
                      new Expanded(
                          flex: 2,
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Text(
                                translate("info.description"),
                                style: new TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          )),
                      new Expanded(
                          flex: 9,
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Text(
                                translate(""),
                                style: new TextStyle(
                                    fontSize: 18.5, color: Colors.white70),
                              ),
                            ],
                          )),
                      new Padding(
                          padding: new EdgeInsets.only(
                        right: 70.0,
                      )),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  new Row(
                    children: <Widget>[
                      new Padding(
                        padding: new EdgeInsets.only(
                          left: 70.0,
                          right: 10.0,
                        ),
                        child: ClipRRect(
                          child: Container(
                            color: Color.fromARGB(255, 125, 164, 243),
                            child: Icon(Icons.calendar_month_rounded,
                                color: Colors.white, size: 36.0),
                          ),
                        ),
                      ),
                      new Expanded(
                          flex: 2,
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Text(
                                translate("info.date"),
                                style: new TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          )),
                      SizedBox(
                        height: 90,
                      ),
                      new Expanded(
                          flex: 9,
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Text(
                                translate(""),
                                style: new TextStyle(
                                  fontSize: 18.5,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          )),
                      new Padding(
                          padding: new EdgeInsets.only(
                        right: 70.0,
                      )),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  new Row(
                    children: <Widget>[
                      new Padding(
                        padding: new EdgeInsets.only(
                          left: 70.0,
                          right: 10.0,
                        ),
                        child: ClipRRect(
                          child: Container(
                            color: Color.fromARGB(255, 125, 164, 243),
                            child: Icon(Icons.map_sharp,
                                color: Colors.white, size: 36.0),
                          ),
                        ),
                      ),
                      new Expanded(
                          flex: 2,
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Text(
                                translate("info.legend"),
                                style: new TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          )),
                      SizedBox(
                        height: 90,
                      ),
                      new Expanded(
                        flex: 9,
                        child: new Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(translate(""),
                                style: TextStyle(
                                    fontSize: 18.5,
                                    color: Colors.white70,
                                    fontFamily: "GoogleSans")),
                            SizedBox(
                              height: 8,
                            ),
                          ],
                        ),
                      ),
                      new Padding(
                          padding: new EdgeInsets.only(
                        right: 70.0,
                      )),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  new Row(
                    children: <Widget>[
                      new Padding(
                        padding: new EdgeInsets.only(
                          left: 70.0,
                          right: 10.0,
                        ),
                        child: ClipRRect(
                          child: Container(
                            color: Color.fromARGB(255, 125, 164, 243),
                            child: Icon(Icons.link,
                                color: Colors.white, size: 36.0),
                          ),
                        ),
                      ),
                      new Expanded(
                          flex: 2,
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Text(
                                translate("info.sources"),
                                style: new TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          )),
                      new Expanded(
                          flex: 9,
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[],
                          )),
                      new Padding(
                          padding: new EdgeInsets.only(
                        right: 70.0,
                      )),
                    ],
                  ),
                ]),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 125, 164, 243),
                  border: Border.all(
                    color: Colors.transparent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: themeNotifier.isDark
                          ? Colors.black
                          : Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
              )),
      // Pre-historic Track
      Consumer<ThemeModel>(
          builder: (context, ThemeModel themeNotifier, child) => Container(
                margin: EdgeInsets.fromLTRB(90, 0, 90, 0),
                padding: EdgeInsets.only(top: 20),
                child: Column(children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      translate('Track.prehistoric'),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 34.5,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  new Row(
                    children: <Widget>[
                      new Padding(
                        padding: new EdgeInsets.only(
                          left: 70.0,
                          right: 10.0,
                        ),
                        child: ClipRRect(
                          child: Container(
                            color: Color.fromARGB(255, 125, 164, 243),
                            child: Icon(Icons.info_outline_rounded,
                                color: Colors.white, size: 36.0),
                          ),
                        ),
                      ),
                      new Expanded(
                          flex: 2,
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Text(
                                translate("info.description"),
                                style: new TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          )),
                      new Expanded(
                          flex: 9,
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Text(
                                translate(""),
                                style: new TextStyle(
                                    fontSize: 18.5, color: Colors.white70),
                              ),
                            ],
                          )),
                      new Padding(
                          padding: new EdgeInsets.only(
                        right: 70.0,
                      )),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  new Row(
                    children: <Widget>[
                      new Padding(
                        padding: new EdgeInsets.only(
                          left: 70.0,
                          right: 10.0,
                        ),
                        child: ClipRRect(
                          child: Container(
                            color: Color.fromARGB(255, 125, 164, 243),
                            child: Icon(Icons.calendar_month_rounded,
                                color: Colors.white, size: 36.0),
                          ),
                        ),
                      ),
                      new Expanded(
                          flex: 2,
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Text(
                                translate("info.date"),
                                style: new TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          )),
                      SizedBox(
                        height: 90,
                      ),
                      new Expanded(
                          flex: 9,
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Text(
                                translate(""),
                                style: new TextStyle(
                                  fontSize: 18.5,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          )),
                      new Padding(
                          padding: new EdgeInsets.only(
                        right: 70.0,
                      )),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  new Row(
                    children: <Widget>[
                      new Padding(
                        padding: new EdgeInsets.only(
                          left: 70.0,
                          right: 10.0,
                        ),
                        child: ClipRRect(
                          child: Container(
                            color: Color.fromARGB(255, 125, 164, 243),
                            child: Icon(Icons.map_sharp,
                                color: Colors.white, size: 36.0),
                          ),
                        ),
                      ),
                      new Expanded(
                          flex: 2,
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Text(
                                translate("info.legend"),
                                style: new TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          )),
                      SizedBox(
                        height: 90,
                      ),
                      new Expanded(
                        flex: 9,
                        child: new Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(translate(""),
                                style: TextStyle(
                                    fontSize: 18.5,
                                    color: Colors.white70,
                                    fontFamily: "GoogleSans")),
                            SizedBox(
                              height: 8,
                            ),
                          ],
                        ),
                      ),
                      new Padding(
                          padding: new EdgeInsets.only(
                        right: 70.0,
                      )),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  new Row(
                    children: <Widget>[
                      new Padding(
                        padding: new EdgeInsets.only(
                          left: 70.0,
                          right: 10.0,
                        ),
                        child: ClipRRect(
                          child: Container(
                            color: Color.fromARGB(255, 125, 164, 243),
                            child: Icon(Icons.link,
                                color: Colors.white, size: 36.0),
                          ),
                        ),
                      ),
                      new Expanded(
                          flex: 2,
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Text(
                                translate("info.sources"),
                                style: new TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          )),
                      new Expanded(
                          flex: 9,
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[],
                          )),
                      new Padding(
                          padding: new EdgeInsets.only(
                        right: 70.0,
                      )),
                    ],
                  ),
                ]),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 125, 164, 243),
                  border: Border.all(
                    color: Colors.transparent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: themeNotifier.isDark
                          ? Colors.black
                          : Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
              )),
    ];

    return Scaffold(
        body: Stack(children: <Widget>[
      Container(
          child: CarouselSlider(
        options: CarouselOptions(
          enlargeCenterPage: true,
          height: 700,
          initialPage: x,
          scrollDirection: Axis.vertical,
          autoPlayInterval: const Duration(milliseconds: 5000),
          autoPlay: false,
        ),
        items: track_cards,
      )),
      Consumer<ThemeModel>(
        builder: (context, ThemeModel themeNotifier, child) => Positioned(
          top: 200,
          right: 0,
          child: Card(
            elevation: 0,
            child: Container(
              color: themeNotifier.isDark
                  ? Color.fromARGB(255, 30, 30, 30)
                  : Color.fromARGB(255, 68, 68, 68),
              width: 69.5,
              height: 175,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 6),
                  RotationTransition(
                    turns: Tween(begin: 0.0, end: 25.0)
                        .animate(_rotationiconcontroller),
                    child: Builder(
                      builder: (context) => IconButton(
                        icon: Image.asset('assets/icons/orbit.png'),
                        iconSize: 57,
                        onPressed: () => {
                          isOrbiting = !isOrbiting,
                          if (isOrbiting == true)
                            {
                              _rotationiconcontroller.forward(),
                              LGConnection().cleanOrbit().then((value) {
                                playOrbit().then((value) {
                                  _showToast(translate('map.buildorbit'),
                                      themeNotifier.isDark);
                                });
                              }).catchError((onError) {
                                _rotationiconcontroller.stop();
                                print('oh no $onError');
                                if (onError == 'nogeodata') {
                                  showAlertDialog(
                                      translate('Track.alert'),
                                      translate('Track.alert2'),
                                      themeNotifier.isDark);
                                }
                                showAlertDialog(
                                    translate('Track.alert3'),
                                    translate('Track.alert4'),
                                    themeNotifier.isDark);
                              }),
                            }
                          else
                            {
                              _rotationiconcontroller.reset(),
                              stopOrbit().then((value) {
                                _showToast(translate('map.stoporbit'),
                                    themeNotifier.isDark);
                                LGConnection().cleanOrbit();
                              }).catchError((onError) {
                                print('oh no $onError');
                                if (onError == 'nogeodata') {
                                  showAlertDialog(
                                      translate('Track.alert'),
                                      translate('Track.alert2'),
                                      themeNotifier.isDark);
                                }
                                showAlertDialog(
                                    translate('Track.alert3'),
                                    translate('Track.alert4'),
                                    themeNotifier.isDark);
                              }),
                            }
                        },
                      ),
                    ),
                  ),
                  Divider(),
                  loading
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                              SizedBox(
                                height: 10,
                              ),
                              RotatedBox(
                                  quarterTurns: -1,
                                  child: LinearPercentIndicator(
                                    animation: true,
                                    width: 51,
                                    lineHeight: 51,
                                    alignment: MainAxisAlignment.center,
                                    backgroundColor: themeNotifier.isDark
                                        ? Color.fromARGB(205, 42, 47, 48)
                                        : Color.fromARGB(205, 180, 199, 206),
                                    percent: 1.0,
                                    padding: EdgeInsets.all(0),
                                    animationDuration: _duration,
                                    center: Wrap(
                                      children: <Widget>[
                                        SizedBox(
                                          width: 10,
                                        ),
                                        RotatedBox(
                                            quarterTurns: 1,
                                            child: Icon(
                                              Icons.location_on_sharp,
                                              color: Color.fromARGB(
                                                  255, 228, 6, 9),
                                              size: 45.0,
                                            )),
                                      ],
                                    ),
                                    barRadius: Radius.circular(50),
                                    progressColor: Colors.greenAccent,
                                  ))
                            ])
                      : Builder(
                          builder: (context) => IconButton(
                              icon: Image.asset('assets/icons/lg.png'),
                              iconSize: 57,
                              onPressed: () async {
                                setState(() {
                                  loading = true;
                                });
                                LGConnection()
                                    .sendToLG(retrykml, retryname)
                                    .then((value) {
                                  _showToast(translate('Track.Visualize'),
                                      themeNotifier.isDark);
                                  setState(() {
                                    loading = false;
                                  });
                                }).catchError((onError) {
                                  print('oh no $onError');
                                  setState(() {
                                    loading = false;
                                  });
                                  if (onError == 'nogeodata') {
                                    showAlertDialog(
                                        translate('Track.alert'),
                                        translate('Track.alert2'),
                                        themeNotifier.isDark);
                                  }
                                  showAlertDialog(
                                      translate('Track.alert3'),
                                      translate('Track.alert4'),
                                      themeNotifier.isDark);
                                });
                              })),
                ],
              ),
            ),
          ),
        ),
      ),
    ]));
  }
}

class LGConnection {
  Future sendToLG(String kml, String projectname) async {
    if (kml.isNotEmpty) {
      return _createLocalFile(kml, projectname);
    }
    return Future.error('nogeodata');
  }

  _createLocalFile(String kml, String projectname) async {
    String localPath = await _localPath;
    File localFile = File('$localPath/$projectname.kml');
    localFile.writeAsString(kml);
    File localFile2 = File('$localPath/kmls.txt');
    localFile2.writeAsString(kml);
    return _uploadToLG('$localPath/$projectname.kml', projectname);
  }

  _uploadToLG(String localPath, String projectname) async {
    dynamic credencials = await _getCredentials();

    SSHClient client = SSHClient(
      host: '${credencials['ip']}',
      port: int.parse('${credencials['port']}'),
      username: '${credencials['username']}',
      passwordOrKey: '${credencials['pass']}',
    );

    LookAt flyto = LookAt(
      projectname == "Historic_Track"
          ? -17.885454
          : projectname == "Located_Events"
              ? -17.834886
              : projectname == "SO2_Emission"
                  ? -7.561565
                  : projectname == "Prehistoric_Track"
                      ? -17.885454
                      : projectname == "Lava_Flow"
                          ? -17.892286
                          : -17.895486,
      projectname == "Historic_Track"
          ? 28.556656
          : projectname == "Located_Events"
              ? 28.564986
              : projectname == "SO2_Emission"
                  ? 33.561245
                  : projectname == "Prehistoric_Track"
                      ? 28.556656
                      : projectname == "Lava_Flow"
                          ? 28.616354
                          : projectname == "Affected_Areas"
                              ? 28.616354
                              : projectname == "Situation"
                                  ? 28.597354
                                  : projectname == "Landscape"
                                      ? 28.616354
                                      : 28.610478,
      projectname == "Located_Events"
          ? '${61708.9978371 / int.parse(credencials['numberofrigs'])}'
          : projectname == "Lava_Flow"
              ? '${18208.9978371 / int.parse(credencials['numberofrigs'])}'
              : projectname == "Landscape"
                  ? '${65208.997837 / int.parse(credencials['numberofrigs'])}'
                  : projectname == "Affected_Areas"
                      ? '${18208.9978371 / int.parse(credencials['numberofrigs'])}'
                      : projectname == "Situation"
                          ? '${75208.9978371 / int.parse(credencials['numberofrigs'])}'
                          : projectname == "Historic_Track"
                              ? '${151708.997837 / int.parse(credencials['numberofrigs'])}'
                              : projectname == "SO2_Emission"
                                  ? '${10500001.9978 / int.parse(credencials['numberofrigs'])}'
                                  : projectname == "Prehistoric_Track"
                                      ? '${151708.997837 / int.parse(credencials['numberofrigs'])}'
                                      : '${91708.9978371 / int.parse(credencials['numberofrigs'])}',
      projectname == "Historic_Track"
          ? '41.82725143432617'
          : projectname == "SO2_Emission"
              ? '25'
              : projectname == "Prehistoric_Track"
                  ? '41.82725143432617'
                  : '45',
      projectname == "Historic_Track"
          ? ' 61.403038024902344'
          : projectname == "Prehistoric_Track"
              ? ' 61.403038024902344'
              : '0',
    );
    try {
      await client.connect();
      await client.execute('> /var/www/html/kmls.txt');

      // upload kml
      await client.connectSFTP();
      await client.sftpUpload(
        path: localPath,
        toPath: '/var/www/html',
        callback: (progress) {
          print('Sent $progress');
        },
      );

      // for (int k = 0; k < localimages.length; k++) {
      //   String imgPath = await _createLocalImage(
      //       localimages[k], "assets/icons/${localimages[k]}");
      //   await client.sftpUpload(path: imgPath, toPath: '/var/www/html');
      // }
      await client.execute(
          'echo "http://lg1:81/$projectname.kml" > /var/www/html/kmls.txt');

      return await client.execute(
          'echo "flytoview=${flyto.generateLinearString()}" > /tmp/query.txt');
    } catch (e) {
      print('Could not connect to host LG');
      return Future.error(e);
    }
  }

  _getCredentials() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String ipAddress = preferences.getString('master_ip') ?? '';
    String password = preferences.getString('master_password') ?? '';
    String portNumber = preferences.getString('master_portNumber') ?? '';
    String username = preferences.getString('master_username') ?? '';
    String numberofrigs = preferences.getString('numberofrigs') ?? '';

    return {
      "ip": ipAddress,
      "pass": password,
      "port": portNumber,
      "username": username,
      "numberofrigs": numberofrigs
    };
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  buildOrbit(String content) async {
    dynamic credencials = await _getCredentials();

    String localPath = await _localPath;
    File localFile = File('$localPath/Orbit.kml');
    localFile.writeAsString(content);

    String filePath = '$localPath/Orbit.kml';

    SSHClient client = SSHClient(
      host: '${credencials['ip']}',
      port: int.parse('${credencials['port']}'),
      username: '${credencials['username']}',
      passwordOrKey: '${credencials['pass']}',
    );

    try {
      await client.connect();
      await client.connectSFTP();
      await client.sftpUpload(
        path: filePath,
        toPath: '/var/www/html',
        callback: (progress) {
          print('Sent $progress');
        },
      );
      return await client.execute(
          "echo '\nhttp://lg1:81/Orbit.kml' >> /var/www/html/kmls.txt");
    } catch (e) {
      print('Could not connect to host LG');
      return Future.error(e);
    }
  }

  startOrbit() async {
    dynamic credencials = await _getCredentials();

    SSHClient client = SSHClient(
      host: '${credencials['ip']}',
      port: int.parse('${credencials['port']}'),
      username: '${credencials['username']}',
      passwordOrKey: '${credencials['pass']}',
    );

    try {
      await client.connect();
      return await client.execute('echo "playtour=Orbit" > /tmp/query.txt');
    } catch (e) {
      print('Could not connect to host LG');
      return Future.error(e);
    }
  }

  stopOrbit() async {
    dynamic credencials = await _getCredentials();

    SSHClient client = SSHClient(
      host: '${credencials['ip']}',
      port: int.parse('${credencials['port']}'),
      username: '${credencials['username']}',
      passwordOrKey: '${credencials['pass']}',
    );

    try {
      await client.connect();
      return await client.execute('echo "exittour=true" > /tmp/query.txt');
    } catch (e) {
      print('Could not connect to host LG');
      return Future.error(e);
    }
  }

  cleanOrbit() async {
    dynamic credencials = await _getCredentials();

    SSHClient client = SSHClient(
      host: '${credencials['ip']}',
      port: int.parse('${credencials['port']}'),
      username: '${credencials['username']}',
      passwordOrKey: '${credencials['pass']}',
    );

    try {
      await client.connect();
      return await client.execute('echo "" > /tmp/query.txt');
    } catch (e) {
      print('Could not connect to host LG');
      return Future.error(e);
    }
  }
}
