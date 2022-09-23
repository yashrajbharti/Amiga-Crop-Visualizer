import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async' show Future;
import 'dart:developer';

import 'package:percent_indicator/percent_indicator.dart';
import 'package:ssh2/ssh2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:AmigaCrop/codingapp/kml/LookAt.dart';
import 'package:AmigaCrop/codingapp/kml/orbit.dart';
import 'package:AmigaCrop/codingapp/theme-storage.dart';
import 'package:AmigaCrop/codingapp/kml/kml.dart';
import 'package:AmigaCrop/codingapp/menuOptions/lg_tasks.dart';
import 'package:AmigaCrop/codingapp/Tabs/Info.dart';

class SendtoLG extends StatefulWidget {
  SendtoLG({Key? key}) : super(key: key);

  @override
  State<SendtoLG> createState() => _SendtoLGState();
}

List<String> kmltext = ['', '', '', '', '', '', '', ''];
String localpath = "";
bool isOpen = false;
bool loading = false;
double latvalue = 39.29793673357732;
double longvalue = -3.144586280853279;
List<String> projectname = [
  "Crop_Field",
  "Insect",
  "Fields",
];
var _duration = 3000;
// List<String> localimages = [
//   "vent.png",
//   "red_sq.png",
//   "yellow_sq.png",
//   "black_sq.png"
// ];
bool stopdemo = false;
bool isdemoactive = false;
bool blackandwhite = false;
String finalname = "";
String finaltext = "";
KML kml = KML("", "");
Future<String> _read(int i) async {
  try {
    final Directory directory = await getApplicationDocumentsDirectory();
    localpath = '${directory.path}/${projectname[i]}.txt';
    finalname = projectname[i];
    kmltext[i] =
        await rootBundle.loadString('assets/kml_files/${projectname[i]}.txt');
    finaltext = kmltext[i];
    log(finalname);
  } catch (e) {
    print("Couldn't read file");
    print(e);
  }
  kml = KML(finalname, finaltext);
  return kmltext[i];
}

class _SendtoLGState extends State<SendtoLG> {
  showAlertDialog(String title, String msg, bool blackandwhite) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 4, sigmaY: 3),
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
                                  primary:
                                      ui.Color.fromARGB(255, 220, 220, 220),
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

  playOrbit() async {
    await LGConnection()
        .buildOrbit(Orbit.buildOrbit(Orbit.generateOrbitTag(LookAt(
            double.parse((await longvalue).toStringAsFixed(2)),
            double.parse((await latvalue).toStringAsFixed(2)),
            "30492.665945696469",
            "0",
            "0"))))
        .then((value) async {
      await LGConnection().startOrbit();
    });
  }

  stopOrbit() async {
    await LGConnection().stopOrbit();
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
            ? ui.Color.fromARGB(255, 22, 22, 22)
            : ui.Color.fromARGB(250, 43, 43, 43),
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

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
        builder: (context, ThemeModel themeNotifier, child) => Container(
              margin: const EdgeInsets.fromLTRB(90, 30, 90, 0),
              child: Column(
                children: [
                  Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: 600,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 2,
                              shadowColor: themeNotifier.isDark
                                  ? Colors.black
                                  : Colors.grey.withOpacity(0.3),
                              primary: themeNotifier.isDark
                                  ? ui.Color.fromARGB(255, 43, 43, 43)
                                  : ui.Color.fromARGB(255, 220, 220, 220),
                              padding: EdgeInsets.all(15),
                            ),
                            onPressed: () async {
                              savekml_Task(projectname[0]);
                              await _read(0);
                              await LGConnection().openBalloon(
                                  projectname[0],
                                  translate('Track.hist').trim(),
                                  translate("info.hist.date"),
                                  240,
                                  translate("info.description") +
                                      " " +
                                      translate("info.hist.description"),
                                  "COPERNICUS, ResearchGate, Global Volcanism Program",
                                  translate('title.name'),
                                  "historic_infographic.png");
                              setState(() {
                                _duration = 5290;
                              });
                              jumpToPage(0);
                              _showToast(translate('Track.ready'),
                                  themeNotifier.isDark);
                            },
                            child: Wrap(
                              children: <Widget>[
                                SizedBox(
                                  width: 10,
                                ),
                                Text(translate('Track.hist'),
                                    style: TextStyle(fontSize: 40)),
                                Transform.scale(
                                    scale: 1.5,
                                    child: Builder(
                                      builder: (context) => IconButton(
                                        icon: Image.asset(
                                            'assets/icons/wheat.png'),
                                        onPressed: null,
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 46),
                        SizedBox(
                          width: 600,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 2,
                              shadowColor: themeNotifier.isDark
                                  ? Colors.black
                                  : Colors.grey.withOpacity(0.3),
                              primary: themeNotifier.isDark
                                  ? ui.Color.fromARGB(255, 43, 43, 43)
                                  : ui.Color.fromARGB(255, 220, 220, 220),
                              padding: EdgeInsets.all(15),
                            ),
                            onPressed: () async {
                              savekml_Task(projectname[1]);
                              await _read(1);
                              await LGConnection().openBalloon(
                                  projectname[1],
                                  translate('Track.lava').trim(),
                                  translate("info.lava.date"),
                                  240,
                                  translate("info.description") +
                                      " " +
                                      translate("info.lava.description"),
                                  "COPERNICUS, Wikipedia | Cumbre Vieja",
                                  translate('title.name'),
                                  "lavaflow_infographic.jpg");
                              setState(() {
                                _duration = 3000;
                              });
                              jumpToPage(1);
                              _showToast(translate('Track.ready'),
                                  themeNotifier.isDark);
                            },
                            child: Wrap(
                              children: <Widget>[
                                SizedBox(
                                  width: 10,
                                ),
                                Text(translate('Track.lava'),
                                    style: TextStyle(fontSize: 40)),
                                Transform.scale(
                                    scale: 1.5,
                                    child: Builder(
                                      builder: (context) => IconButton(
                                        icon: Image.asset(
                                            'assets/icons/ladybug.png'),
                                        onPressed: null,
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        )
                      ]),
                  SizedBox(height: 46),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 600,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              elevation: 2,
                              shadowColor: themeNotifier.isDark
                                  ? Colors.black
                                  : Colors.grey.withOpacity(0.3),
                              primary: themeNotifier.isDark
                                  ? ui.Color.fromARGB(255, 43, 43, 43)
                                  : ui.Color.fromARGB(255, 220, 220, 220),
                              padding: EdgeInsets.all(15)),
                          onPressed: () async {
                            savekml_Task(projectname[2]);
                            await _read(2);
                            await LGConnection().openBalloon(
                                projectname[2],
                                translate('Track.prehistoric').trim(),
                                translate("info.prehistoric.date"),
                                270,
                                translate("info.description") +
                                    " " +
                                    translate("info.prehistoric.description"),
                                "ResearchGate, Global Volcanism Program",
                                translate('title.name'),
                                "prehistoric_infographic.png");
                            setState(() {
                              _duration = 2080;
                            });
                            jumpToPage(2);
                            _showToast(
                                translate('Track.ready'), themeNotifier.isDark);
                          },
                          child: Wrap(
                            children: <Widget>[
                              SizedBox(
                                width: 10,
                              ),
                              Text(translate('Track.prehistoric'),
                                  style: TextStyle(fontSize: 40)),
                              Transform.scale(
                                  scale: 1.5,
                                  child: Builder(
                                    builder: (context) => IconButton(
                                      icon: Image.asset(
                                          'assets/icons/meadow.png'),
                                      onPressed: null,
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 46),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 360,
                        child: loading
                            ? LinearPercentIndicator(
                                animation: true,
                                width: 360,
                                lineHeight: 76.0,
                                backgroundColor: themeNotifier.isDark
                                    ? ui.Color.fromARGB(205, 42, 47, 48)
                                    : ui.Color.fromARGB(205, 180, 199, 206),
                                percent: 1.0,
                                padding: EdgeInsets.all(0),
                                animationDuration: _duration,
                                center: Wrap(
                                  children: <Widget>[
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(translate('Track.visual'),
                                        style: TextStyle(
                                            fontSize: 35,
                                            fontWeight: ui.FontWeight.w500)),
                                    Icon(
                                      Icons.location_on_sharp,
                                      color: ui.Color.fromARGB(255, 228, 6, 9),
                                      size: 45.0,
                                    ),
                                  ],
                                ),
                                barRadius: ui.Radius.circular(50),
                                progressColor: Colors.greenAccent,
                              )
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 2,
                                  shadowColor: themeNotifier.isDark
                                      ? Colors.black
                                      : Colors.grey.withOpacity(0.3),
                                  primary: themeNotifier.isDark
                                      ? ui.Color.fromARGB(255, 30, 30, 30)
                                      : Colors.white,
                                  padding: EdgeInsets.all(15),
                                  shape: StadiumBorder(),
                                ),
                                child: Wrap(
                                  children: <Widget>[
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(translate('Track.visual'),
                                        style: TextStyle(fontSize: 35)),
                                    Icon(
                                      Icons.location_on_sharp,
                                      color:
                                          ui.Color.fromARGB(255, 86, 177, 71),
                                      size: 45.0,
                                    ),
                                  ],
                                ),
                                onPressed: () {
                                  // send to LG
                                  setState(() {
                                    loading = true;
                                  });

                                  LGConnection()
                                      .sendToLG(kml.mount(), finalname)
                                      .then((value) {
                                    _showToast(translate('Track.Visualize'),
                                        themeNotifier.isDark);

                                    setState(() {
                                      isOpen = true;
                                      loading = false;
                                    });
                                    retryButton(
                                        kml.mount(), finalname, _duration / 2);
                                    DefaultTabController.of(context)
                                        ?.animateTo(2);
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
                                }),
                      ),
                      SizedBox(
                        width: 18,
                      ),
                    ],
                  ),
                ],
              ),
            ));
  }
}

class LGConnection {
  Future openBalloon(
      String name,
      String track,
      String time,
      int height,
      String description,
      String sources,
      String appname,
      String imagename) async {
    dynamic credencials = await _getCredentials();

    SSHClient client = SSHClient(
      host: '${credencials['ip']}',
      port: int.parse('${credencials['port']}'),
      username: '${credencials['username']}',
      passwordOrKey: '${credencials['pass']}',
    );
    int rigs = 3;
    rigs = (int.parse(credencials['numberofrigs']) / 2).floor() + 1;
    String openBalloonKML = '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
<Document>
	<name>$name.kml</name>
	<Style id="purple_paddle">
		<IconStyle>
			<Icon>
				<href>https://raw.githubusercontent.com/yashrajbharti/kml-images/main/leaf.png</href>
			</Icon>
		</IconStyle>
		<BalloonStyle>
			<text>\$[description]</text>
      <bgColor>ff1e1e1e</bgColor>
		</BalloonStyle>
	</Style>
	<Placemark id="0A7ACC68BF23CB81B354">
		<name>$track</name>
		<Snippet maxLines="0"></Snippet>
		<description><![CDATA[<!-- BalloonStyle background color:
ffffffff
 -->
<!-- Icon URL:
http://maps.google.com/mapfiles/kml/paddle/purple-blank.png
 -->
<table width="400" border="0" cellspacing="0" cellpadding="5">
  <tr>
    <td colspan="2" align="center">
      <img src="https://raw.githubusercontent.com/yashrajbharti/kml-images/main/leaf.png" alt="picture" width="150" height="150" />
    </td>
  </tr>
  <tr>
    <td colspan="2" align="center">
      <h2><font color='#00CC99'>$track</font></h2>
      <h3><font color='#00CC99'>$time</font></h3>
    </td>
  </tr>
  <tr>
    <td colspan="2" align="center">
      <img src="https://raw.githubusercontent.com/yashrajbharti/kml-images/main/$imagename" alt="picture" width="400" height="$height" />    </td>
  </tr>  
  <tr>
    <td colspan="2">
      <p><font color="#3399CC">$description</font></p>
    </td>
  </tr>
  <tr>
    <td align="center">
      <a href="#">$sources</a>
    </td>
  </tr>
  <tr>
    <td colspan="2" align="center">
      <font color="#999999">@$appname 2022</font>
    </td>
  </tr>
</table>]]></description>
		<LookAt>
			<longitude>-3.144586280853279</longitude>
			<latitude>39.29793673357732</latitude>
			<altitude>0</altitude>
			<heading>0</heading>
			<tilt>0</tilt>
			<range>24000</range>
		</LookAt>
		<styleUrl>#purple_paddle</styleUrl>
		<gx:balloonVisibility>1</gx:balloonVisibility>
		<Point>
			<coordinates>-3.144586280853279,39.29793673357732,0</coordinates>
		</Point>
	</Placemark>
</Document>
</kml>
''';
    try {
      await client.connect();
      return await client.execute(
          "echo '$openBalloonKML' > /var/www/html/kml/slave_$rigs.kml");
    } catch (e) {
      return Future.error(e);
    }
  }

  Future sendToLG(String kml, String projectname) async {
    if (kml.isNotEmpty) {
      return _createLocalFile(kml, projectname);
    }
    return Future.error('nogeodata');
  }

  Future cleanVisualization() async {
    dynamic credencials = await _getCredentials();

    SSHClient client = SSHClient(
      host: '${credencials['ip']}',
      port: int.parse('${credencials['port']}'),
      username: '${credencials['username']}',
      passwordOrKey: '${credencials['pass']}',
    );

    try {
      await client.connect();
      stopOrbit();
      return await client.execute('> /var/www/html/kmls.txt');
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

  _createLocalFile(String kml, String projectname) async {
    String localPath = await _localPath;
    File localFile = File('$localPath/$projectname.kml');
    localFile.writeAsString(kml);
    File localFile2 = File('$localPath/kmls.txt');
    localFile2.writeAsString(kml);
    return _uploadToLG('$localPath/$projectname.kml', projectname);
  }

  // _createLocalImage(String imgName, String assetsUrl) async {
  //   Directory directory = await getApplicationDocumentsDirectory();
  //   String imgPath = '${directory.path}/$imgName';
  //   ByteData data = await rootBundle.load(assetsUrl);
  //   List<int> bytes =
  //       data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  //   await File(imgPath).writeAsBytes(bytes);
  //   return imgPath;
  // }

  _uploadToLG(String localPath, String projectname) async {
    dynamic credencials = await _getCredentials();

    SSHClient client = SSHClient(
      host: '${credencials['ip']}',
      port: int.parse('${credencials['port']}'),
      username: '${credencials['username']}',
      passwordOrKey: '${credencials['pass']}',
    );

    LookAt flyto = LookAt(
      projectname == "Crop_Field"
          ? -3.144586280853279
          : projectname == "Fields"
              ? -3.144586280853279
              : projectname == "Insect"
                  ? -3.144586280853279
                  : -3.144586280853279,
      projectname == "Crop_Field"
          ? 39.29793673357732
          : projectname == "Fields"
              ? 39.29793673357732
              : projectname == "Insect"
                  ? 39.29793673357732
                  : 39.29793673357732,
      projectname == "Insect"
          ? '${1208.9978371 / int.parse(credencials['numberofrigs'])}'
          : projectname == "Crop_Field"
              ? '${1708.997837 / int.parse(credencials['numberofrigs'])}'
              : projectname == "Fields"
                  ? '${1708.997837 / int.parse(credencials['numberofrigs'])}'
                  : '${1708.9978371 / int.parse(credencials['numberofrigs'])}',
      projectname == "Crop_Field"
          ? '41.82725143432617'
          : projectname == "Fields"
              ? '41.82725143432617'
              : '45',
      projectname == "Crop_Field"
          ? ' 61.403038024902344'
          : projectname == "Fields"
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
}
