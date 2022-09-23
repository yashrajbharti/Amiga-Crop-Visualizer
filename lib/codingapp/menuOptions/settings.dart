import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:ssh2/ssh2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;
import 'package:AmigaCrop/codingapp/drawer.dart';
import 'package:provider/provider.dart';
import 'package:AmigaCrop/codingapp/theme-storage.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  Color _iconColor = Color.fromARGB(255, 74, 74, 74);
  bool isLoggedIn = false;
  bool obscurePassword = true;
  bool loaded = false;
  bool isSuccess = false;

  TextEditingController username = TextEditingController();
  TextEditingController ipAddress = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController portNumber = TextEditingController();
  TextEditingController numberofrigs = TextEditingController();

  bool connectionStatus = false;

  connect() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString('master_ip', ipAddress.text);
    await preferences.setString('master_username', username.text);
    await preferences.setString('master_password', password.text);
    await preferences.setString('master_portNumber', portNumber.text);
    await preferences.setString('numberofrigs', numberofrigs.text);

    try {
      SSHClient client = SSHClient(
        host: ipAddress.text,
        port: int.tryParse(portNumber.text)!.toInt(),
        username: username.text,
        passwordOrKey: password.text,
      );
      await client.connect();
      showAlertDialog(translate("Settings.alert"),
          '${ipAddress.text} ' + translate("Settings.alert2"), true);
      setState(() {
        connectionStatus = true;
      });
      // open logos
      await LGConnection().openDemoLogos();
      await client.disconnect();
    } catch (e) {
      showAlertDialog(translate("Settings.alert3"),
          '${ipAddress.text} ' + translate("Settings.alert4"), false);
      setState(() {
        connectionStatus = false;
      });
    }
  }

  checkConnectionStatus() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString('master_ip', ipAddress.text);
    await preferences.setString('master_password', password.text);
    await preferences.setString('master_portNumber', portNumber.text);
    await preferences.setString('numberofrigs', numberofrigs.text);

    try {
      SSHClient client = SSHClient(
        host: ipAddress.text,
        port: int.tryParse(portNumber.text)!.toInt(),
        username: username.text,
        passwordOrKey: password.text,
      );
      await client.connect();
      setState(() {
        connectionStatus = true;
      });
      await client.disconnect();
    } catch (e) {
      showAlertDialog(translate("Settings.alert3"),
          '${ipAddress.text} ' + translate("Settings.alert4"), false);
      setState(() {
        connectionStatus = false;
      });
    }
  }

  showAlertDialog(String title, String msg, bool isSuccess) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<ThemeModel>(
            builder: (context, ThemeModel themeNotifier, child) =>
                BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 4, sigmaY: 3),
                    child: AlertDialog(
                      backgroundColor: themeNotifier.isDark
                          ? Color.fromARGB(255, 16, 16, 16)
                          : Color.fromARGB(255, 33, 33, 33),
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Image.asset(
                                isSuccess
                                    ? "assets/happy.png"
                                    : "assets/sad.png",
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
                                          primary: ui.Color.fromARGB(
                                              255, 220, 220, 220),
                                          padding: EdgeInsets.all(15),
                                          shape: StadiumBorder(),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Wrap(
                                          children: <Widget>[
                                            Text(
                                                isSuccess
                                                    ? translate('continue')
                                                    : translate('dismiss'),
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.black)),
                                          ],
                                        ),
                                      ))),
                            ]),
                      ),
                    )));
      },
    );
  }

  init() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    ipAddress.text = preferences.getString('master_ip') ?? '';
    username.text = preferences.getString('master_username') ?? '';
    password.text = preferences.getString('master_password') ?? '';
    portNumber.text = preferences.getString('master_portNumber') ?? '';
    numberofrigs.text = preferences.getString('numberofrigs') ?? '';
    await checkConnectionStatus();
    loaded = true;
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) init();
    // ignore: unused_local_variable
    var localizationDelegate = LocalizedApp.of(context).delegate;

    return Consumer<ThemeModel>(
        builder: (context, ThemeModel themeNotifier, child) => Scaffold(
            extendBodyBehindAppBar: true,
            backgroundColor: themeNotifier.isDark
                ? Color.fromARGB(255, 16, 16, 16)
                : Color.fromARGB(255, 204, 204, 204),
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(50),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    size: 50.0,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) => Drawers(),
                      ),
                    );
                  },
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 120.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [],
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.0, top: 50),
                      child: Text(
                        translate("Settings.title"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            translate("Settings.Status"),
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            connectionStatus
                                ? translate("Settings.connect")
                                : translate("Settings.disconnect"),
                            style: TextStyle(fontSize: 20),
                          ),
                          connectionStatus
                              ? Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 20,
                                )
                              : Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                  size: 20,
                                ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 0.0),
                      child: TextFormField(
                        controller: username,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          filled: true,
                          hintText: translate("Settings.placeholder"),
                          labelText: translate("Settings.label"),
                          labelStyle: TextStyle(
                              color: themeNotifier.isDark
                                  ? Color.fromARGB(255, 204, 204, 204)
                                  : Color.fromARGB(255, 74, 74, 74)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: TextFormField(
                        controller: ipAddress,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          hintText: translate("Settings.placeholder2"),
                          labelText: translate("Settings.label2"),
                          labelStyle: TextStyle(
                              color: themeNotifier.isDark
                                  ? Color.fromARGB(255, 204, 204, 204)
                                  : Color.fromARGB(255, 74, 74, 74)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 20.0),
                      child: TextFormField(
                        controller: portNumber,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          hintText: translate("Settings.placeholder3"),
                          labelText: translate("Settings.label3"),
                          labelStyle: TextStyle(
                              color: themeNotifier.isDark
                                  ? Color.fromARGB(255, 204, 204, 204)
                                  : Color.fromARGB(255, 74, 74, 74)),
                        ),
                      ),
                    ),
                    TextFormField(
                      controller: password,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        filled: true,
                        hintText: translate("Settings.placeholder4"),
                        labelText: translate("Settings.label4"),
                        labelStyle: TextStyle(
                            color: themeNotifier.isDark
                                ? Color.fromARGB(255, 204, 204, 204)
                                : Color.fromARGB(255, 74, 74, 74)),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.remove_red_eye, color: _iconColor),
                          onPressed: () {
                            setState(
                              () {
                                obscurePassword = !obscurePassword;
                                if (_iconColor ==
                                    Color.fromARGB(255, 74, 74, 74)) {
                                  _iconColor = Color(0xFF3E87F5);
                                } else {
                                  _iconColor = Color.fromARGB(255, 74, 74, 74);
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: TextFormField(
                        controller: numberofrigs,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          hintText: translate("Settings.placeholder5"),
                          labelText: translate("Settings.label5"),
                          labelStyle: TextStyle(
                              color: themeNotifier.isDark
                                  ? Color.fromARGB(255, 204, 204, 204)
                                  : Color.fromARGB(255, 74, 74, 74)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: SizedBox(
                        width: 100,
                        child: ElevatedButton(
                          child: Wrap(
                            children: <Widget>[
                              SizedBox(
                                width: 10,
                              ),
                              Text(translate("Settings.button"),
                                  style: TextStyle(fontSize: 25)),
                            ],
                          ),
                          onPressed: () {
                            connect();
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 2,
                            shadowColor: themeNotifier.isDark
                                ? Colors.black
                                : Colors.grey.withOpacity(0.5),
                            primary: themeNotifier.isDark
                                ? ui.Color.fromARGB(255, 30, 30, 30)
                                : Colors.white,
                            padding: EdgeInsets.all(15),
                            shape: StadiumBorder(),
                          ),
                        ),
                      ),
                    ),
                    Divider(
                      color: themeNotifier.isDark
                          ? Color.fromARGB(255, 204, 204, 204)
                          : Color.fromARGB(255, 74, 74, 74),
                      thickness: 1,
                    ),
                  ],
                ),
              ),
            )));
  }
}

class LGConnection {
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

  Future openDemoLogos() async {
    dynamic credencials = await _getCredentials();

    SSHClient client = SSHClient(
      host: '${credencials['ip']}',
      port: int.parse('${credencials['port']}'),
      username: '${credencials['username']}',
      passwordOrKey: '${credencials['pass']}',
    );
    int rigs = 4;
    rigs = (int.parse(credencials['numberofrigs']) / 2).floor() + 2;
    String openLogoKML = '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
<Document>
	<name>AmigaCrop</name>
	<open>1</open>
	<description>The logo it located in the bottom left hand corner</description>
	<Folder>
		<name>tags</name>
		<Style>
			<ListStyle>
				<listItemType>checkHideChildren</listItemType>
				<bgColor>00ffffff</bgColor>
				<maxSnippetLines>2</maxSnippetLines>
			</ListStyle>
		</Style>
		<ScreenOverlay id="abc">
			<name>AmigaCrop</name>
			<Icon>
				<href>https://raw.githubusercontent.com/yashrajbharti/kml-images/main/allamiga.png</href>
			</Icon>
			<overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>
			<screenXY x="0" y="0.98" xunits="fraction" yunits="fraction"/>
			<rotationXY x="0" y="0" xunits="fraction" yunits="fraction"/>
			<size x="0" y="0" xunits="pixels" yunits="fraction"/>
		</ScreenOverlay>
	</Folder>
</Document>
</kml>
  ''';
    try {
      await client.connect();
      await client
          .execute("echo '$openLogoKML' > /var/www/html/kml/slave_$rigs.kml");
    } catch (e) {
      return Future.error(e);
    }
  }
}
