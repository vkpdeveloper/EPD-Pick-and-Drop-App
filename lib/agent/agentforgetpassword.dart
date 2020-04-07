import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:epd_pick/agent/agentlogin.dart';
import 'package:flutter/material.dart';
import 'package:epd_pick/theme/theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';

var myTheme = MyTheme();

class AgentForgetPassword extends StatefulWidget {
  @override
  _AgentForgetPasswordState createState() => _AgentForgetPasswordState();
}

class _AgentForgetPasswordState extends State<AgentForgetPassword> {
  TextEditingController _agentMobile = TextEditingController();

  TextEditingController _agentID = TextEditingController();

  String myAgentID;

  showPasswordDialog(BuildContext context, String password) {
    TextEditingController _myPasswordBoxController =
        TextEditingController(text: password);
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            contentPadding: const EdgeInsets.all(20.0),
            content: Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                enabled: true,
                readOnly: true,
                textAlign: TextAlign.center,
                controller: _myPasswordBoxController,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: Icon(
                      Feather.copy,
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: password));
                      Fluttertoast.showToast(
                        msg: "Password copied successfully",
                        backgroundColor: Colors.black54,
                        textColor: Colors.white,
                        gravity: ToastGravity.BOTTOM,
                      );
                    },
                  ),
                ),
              ),
            ),
            elevation: 8.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Close"),
                splashColor: Colors.transparent,
                textColor: myTheme.primaryColor,
              )
            ],
          );
        });
  }

  forgetAgent(BuildContext context) async {
    if (_agentID.text != "") {
      Firestore.instance.document('agent/$myAgentID').get().then((data) {
        if (data.exists) {
          if (_agentMobile.text != "" && _agentMobile.text.length == 10) {
            if (_agentMobile.text == data.data['mobile'].toString()) {
              showPasswordDialog(context, data.data['password']);
            } else {
              Fluttertoast.showToast(
                msg: "Mobile Number not registered",
                backgroundColor: Colors.red,
                textColor: Colors.white,
                gravity: ToastGravity.BOTTOM,
              );
            }
          } else {
            Fluttertoast.showToast(
              msg: "Wrong Mobile Number !",
              backgroundColor: Colors.red,
              textColor: Colors.white,
              gravity: ToastGravity.BOTTOM,
            );
          }
        } else {
          Fluttertoast.showToast(
            msg: "Wrong Agent ID !",
            backgroundColor: Colors.red,
            textColor: Colors.white,
            gravity: ToastGravity.BOTTOM,
          );
        }
      }).catchError((e) {
        Fluttertoast.showToast(
          msg: "Some Error occured !",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          gravity: ToastGravity.BOTTOM,
        );
      });
    } else {
      Fluttertoast.showToast(
        msg: "Blank Agent ID !",
        backgroundColor: Colors.red,
        textColor: Colors.white,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  image: AssetImage('asset/images/forgetpassword.png'),
                  alignment: Alignment.topCenter,
                  height: 250.0,
                ),
              ),
              SizedBox(
                height: 3.0,
              ),
              Text(
                "Forget Password ?",
                style: TextStyle(
                    color: Colors.black54,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 15.0,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                child: Column(
                  children: <Widget>[
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          myAgentID = value;
                        });
                      },
                      keyboardType: TextInputType.text,
                      obscureText: false,
                      autocorrect: false,
                      enabled: true,
                      controller: _agentID,
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
                    TextField(
                      keyboardType: TextInputType.number,
                      obscureText: false,
                      autocorrect: false,
                      enabled: true,
                      controller: _agentMobile,
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(
                        icon: Icon(Feather.phone),
                        hintText: "Enter Mobile",
                        hintStyle: TextStyle(
                            fontFamily: 'Raleway', color: Colors.black),
                        labelText: "Mobile Number",
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
                      minWidth: 220,
                      height: 40.0,
                      color: myTheme.primaryColor,
                      textColor: Colors.white,
                      onPressed: () {
                        forgetAgent(context);
                      },
                      child: Text("Get Password",
                          style: TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold)),
                    ),
                    FlatButton(
                      splashColor: Colors.transparent,
                      child: Text(
                        "Login With Agent ID",
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => Navigator.pop(context),
                      textColor: Colors.red,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
