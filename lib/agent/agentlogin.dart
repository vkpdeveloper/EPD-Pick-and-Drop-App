import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:epd_pick/agent/agentforgetpassword.dart';
import 'package:epd_pick/agent/agenthome.dart';
import 'package:epd_pick/theme/theme.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

var myTheme = MyTheme();

class AgentLogin extends StatefulWidget {
  @override
  _AgentLoginState createState() => _AgentLoginState();
}

class _AgentLoginState extends State<AgentLogin> {
  TextEditingController _agentIdController = TextEditingController();

  TextEditingController _agentPasswordController = TextEditingController();

  var _firebase = Firestore.instance.collection('agent');

  @override
  void initState() {
    myToken = "";
    getTokenId();
    super.initState();
  }

  var myToken;

  getTokenId() {
    var _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.getToken().then((token) {
      myToken = token;
    });
  }

  loginAgent() async {
    try {
      var agentId = _agentIdController.text;
      var agentPassword = _agentPasswordController.text;
      if (agentId != "" && agentPassword != "") {
        _firebase.document(agentId).get().then((snapshot) async {
          if (snapshot.exists) {
            if (snapshot.data['password'] == agentPassword) {
              Fluttertoast.showToast(
                msg: "Login Successful",
                backgroundColor: Colors.black54,
                textColor: Colors.white,
                gravity: ToastGravity.BOTTOM,
              );
              SharedPreferences _prefs = await SharedPreferences.getInstance();
              _prefs.setString("agentid", agentId);
              _firebase
                  .document(agentId)
                  .setData({"token": myToken}, merge: true);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => AgentHome()));
            }
          } else {
            Fluttertoast.showToast(
              msg: "Agent not exist !",
              backgroundColor: Colors.red,
              textColor: Colors.white,
              gravity: ToastGravity.BOTTOM,
            );
          }
        });
      } else {
        Fluttertoast.showToast(
          msg: "Blank Field !",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error occured !",
        backgroundColor: Colors.red,
        textColor: Colors.white,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
            color: myTheme.primaryColor,
          ),
        ),
        body: Container(
          decoration: BoxDecoration(color: Colors.white),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
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
                  height: 3.0,
                ),
                Text(
                  "Welcome Agent !",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 0.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    children: <Widget>[
                      TextField(
                        autocorrect: false,
                        enabled: true,
                        controller: _agentIdController,
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          icon: Icon(Feather.user),
                          hintText: "Enter Agent ID",
                          hintStyle: TextStyle(
                              fontFamily: 'Raleway', color: Colors.black),
                          labelText: "Agent ID",
                          labelStyle: TextStyle(
                              fontFamily: 'Raleway', color: Colors.black),
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      TextField(
                        obscureText: true,
                        autocorrect: false,
                        enabled: true,
                        controller: _agentPasswordController,
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          icon: Icon(Feather.lock),
                          hintText: "Enter Password",
                          hintStyle: TextStyle(
                              fontFamily: 'Raleway', color: Colors.black),
                          labelText: "Password",
                          labelStyle: TextStyle(
                              fontFamily: 'Raleway', color: Colors.black),
                        ),
                      ),
                      SizedBox(
                        height: 30.0,
                      ),
                      MaterialButton(
                        elevation: 8.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0)),
                        minWidth: 220.0,
                        height: 40.0,
                        color: myTheme.primaryColor,
                        textColor: Colors.white,
                        onPressed: () {
                        loginAgent();
                        },
                        child: Text("Login",
                            style: TextStyle(
                                fontFamily: 'Raleway',
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold)),
                      ),
                      FlatButton(
                        splashColor: Colors.transparent,
                        child: Text(
                          "Forget Password ?",
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AgentForgetPassword())),
                        textColor: Colors.red,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
