import 'dart:async';
import 'package:epd_pick/agent/agenthome.dart';
import 'package:epd_pick/customer/customerLogin.dart';
import 'package:epd_pick/customer/customerhome.dart';
import 'package:epd_pick/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

var myTheme = MyTheme();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "EPD Pick & Drop",
      theme: ThemeData(
          primaryColor: myTheme.primaryColor,
          fontFamily: 'Raleway',
          dialogBackgroundColor: Colors.white,
          accentColor: Colors.white),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    openScreen();
  }

  openScreen() async {
    Timer(Duration(seconds: 3), () async {
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      if (_prefs.getString('agentid') != null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => AgentHome()));
      } else if (_prefs.getString('userid') != null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => CustomerHome()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginPage()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(color: myTheme.primaryColor),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image(
              image: AssetImage('asset/images/logo.png'),
              height: 150.0,
              width: 150.0,
            ),
            SizedBox(height: 20.0,),
            Text(
              "EPD Pick & Drop",
              style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 25.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w700),
            ),
            SizedBox(
              height: 120.0,
            ),
            CircularProgressIndicator()
          ],
        ),
      ),
    );
  }
}
