import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:epd_pick/agent/agentlogin.dart';
import 'package:epd_pick/agent/agentmap.dart';
import 'package:epd_pick/customer/makeorder.dart';
import 'package:epd_pick/customer/customerhome.dart';
import 'package:epd_pick/theme/theme.dart';
import 'package:epd_pick/widgets/socialloginbutton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

var myTheme = MyTheme();

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  var _firestore = Firestore.instance.collection('users');
  FacebookLogin _facebookLogin = FacebookLogin();
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    getTokenKey();
    super.initState();
  }

  var tokenKey = "";

  getTokenKey() {
    FirebaseMessaging _messaging = FirebaseMessaging();
    _messaging.setAutoInitEnabled(true);
    _messaging.getToken().then((token) {
      setState(() {
        tokenKey = token;
      });
    });
  }

  // Login with Social Media

  signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleSignInAccount =
          await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final AuthResult authResult =
          await _auth.signInWithCredential(credential);
      final FirebaseUser user = authResult.user;

      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);
      var referralCode = "EPD${currentUser.uid.substring(0, 6)}";
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      _prefs.setString("userid", currentUser.uid);
      _prefs.setString('name', currentUser.displayName);
      _prefs.setString('email', currentUser.email);
      _prefs.setString('photo', currentUser.photoUrl);
      _prefs.setString('token', tokenKey);
      _prefs.setString('referral', referralCode);
      Map<String, dynamic> _googleSignInData = <String, dynamic>{
        "name": currentUser.displayName,
        "email": currentUser.email,
        "userId": currentUser.uid,
        "profile": currentUser.photoUrl,
        "referral": referralCode,
        "token": tokenKey,
        "referral": referralCode,
      };
      _firestore
          .document(currentUser.uid)
          .setData(_googleSignInData, merge: true)
          .whenComplete(() async {
        Fluttertoast.showToast(
          msg: "Login Successful",
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          gravity: ToastGravity.BOTTOM,
        );
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => CustomerHome()));
      }).catchError((err) {
        Fluttertoast.showToast(
          msg: "Error : $err",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          gravity: ToastGravity.BOTTOM,
        );
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Error : $e");
    }
  }

  loginwithFb() async {
    try {
      var facebookLogin = new FacebookLogin();
      var result = await facebookLogin.logIn(['email']);

      if (result.status == FacebookLoginStatus.loggedIn) {
        final AuthCredential credential = FacebookAuthProvider.getCredential(
          accessToken: result.accessToken.token,
        );
        final FirebaseUser user =
            (await FirebaseAuth.instance.signInWithCredential(credential)).user;
        var referralCode = "EPD${user.uid.substring(0, 6)}";
        Map<String, dynamic> _fbSignInData = <String, dynamic>{
          "name": user.displayName,
          "email": user.email,
          "userId": user.uid,
          "profile": user.photoUrl,
          "token": tokenKey,
          "referral": referralCode,
        };
        _firestore
            .document(user.uid)
            .setData(_fbSignInData, merge: true)
            .whenComplete(() async {
          SharedPreferences _prefs = await SharedPreferences.getInstance();
          _prefs.setString('name', user.displayName);
          _prefs.setString('email', user.email);
          _prefs.setString('photo', user.photoUrl);
          _prefs.setString("userid", user.uid);
          _prefs.setString("token", tokenKey);
          _prefs.setString("referral", referralCode);
          Fluttertoast.showToast(
            msg: "Login Successful",
            backgroundColor: Colors.black54,
            textColor: Colors.white,
            gravity: ToastGravity.BOTTOM,
          );
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => CustomerHome()));
        }).catchError((err) {
          Fluttertoast.showToast(
            msg: "Error : $err",
            backgroundColor: Colors.red,
            textColor: Colors.white,
            gravity: ToastGravity.BOTTOM,
          );
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Flex(
              direction: Axis.vertical,
              verticalDirection: VerticalDirection.down,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(color: Colors.white),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image(
                              image: AssetImage('asset/images/auth.png'),
                              alignment: Alignment.topCenter,
                              height: 250.0,
                            ),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Text(
                            "Welcome back !",
                            style: TextStyle(
                                color: Colors.black54,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 30.0,
                          ),
                          SocialLoginButton(
                            height: 40.0,
                            width: 260.0,
                            onPressed: signInWithGoogle,
                            lebel: "Login with Google",
                            icon: FontAwesome.google,
                            borderRadius: BorderRadius.circular(25.0),
                            color: Colors.red,
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          SocialLoginButton(
                            height: 40.0,
                            width: 260.0,
                            onPressed: loginwithFb,
                            lebel: "Login with Facebook",
                            icon: FontAwesome.facebook,
                            borderRadius: BorderRadius.circular(25.0),
                            color: Colors.blue,
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          SocialLoginButton(
                            height: 40.0,
                            width: 260.0,
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AgentLogin())),
                            lebel: "   Login for Agents",
                            icon: FontAwesome.anchor,
                            borderRadius: BorderRadius.circular(25.0),
                            color: myTheme.primaryColor,
                          ),
                          SizedBox(
                            height: 10.0,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
