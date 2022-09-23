import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:provider/provider.dart';
import 'package:AmigaCrop/codingapp/theme-storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:AmigaCrop/codingapp/drawer.dart';

class AboutScreen extends StatefulWidget {
  AboutScreen({Key? key}) : super(key: key);

  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  // ignore: unused_element
  _launchURL(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
        builder: (context, ThemeModel themeNotifier, child) => Scaffold(
              extendBodyBehindAppBar: true,
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: AppBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      size: 50.0,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(
                        MaterialPageRoute(
                          builder: (BuildContext context) => Drawers(),
                        ),
                      );
                    },
                  ),
                ),
              ),
              backgroundColor: themeNotifier.isDark
                  ? Color.fromARGB(255, 16, 16, 16)
                  : Color.fromARGB(255, 204, 204, 204),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 120.0, vertical: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20.0, right: 20.0, bottom: 5, top: 50),
                        child: Text(
                          translate("About.aboutpage"),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 40,
                              color: themeNotifier.isDark
                                  ? Colors.white
                                  : Colors.black),
                        ),
                      ),
                      Builder(
                          builder: (context) => IconButton(
                              icon: Image.asset('assets/leaf.png'),
                              iconSize: 410,
                              onPressed: null)),
                      Transform.scale(
                          scale: 1.6,
                          child: Builder(
                              builder: (context) => IconButton(
                                  icon: Image.asset('assets/amiga.png'),
                                  iconSize: 580,
                                  onPressed: null))),
                      SizedBox(
                        height: 40,
                      ),
                    ],
                  ),
                ),
              ),
            ));
  }

  // ignore: unused_element
  Future<void> _onOpen(LinkableElement link) async {
    if (await canLaunchUrl(Uri.parse(link.url))) {
      await launchUrl(Uri.parse(link.url));
    } else {
      throw 'Could not launch $link';
    }
  }
}
