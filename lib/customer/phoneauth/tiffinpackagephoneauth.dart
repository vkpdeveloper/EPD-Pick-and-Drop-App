import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:epd_pick/customer/tiffinpackagecustomer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';

class CustomerPhoneAuthTiffin extends StatefulWidget {
  @override
  _CustomerPhoneAuthTiffinState createState() =>
      _CustomerPhoneAuthTiffinState();
}

class _CustomerPhoneAuthTiffinState extends State<CustomerPhoneAuthTiffin> {
  TextEditingController _mobileForAuth = TextEditingController();
  TextEditingController _otpController = TextEditingController();
  String _phoneNumber = "";
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool isCodeSent;
  var verID;
  var _firestore = Firestore.instance.collection('users');
  var _otpCode = "";
  AuthCredential _authCredential;

  @override
  void initState() {
    isCodeSent = false;
    super.initState();
  }

  void _signInWithPhoneNumber(String smsCode) async {
    _authCredential = await PhoneAuthProvider.getCredential(
        verificationId: verID, smsCode: smsCode);
    _firebaseAuth.signInWithCredential(_authCredential).catchError((error) {
      Fluttertoast.showToast(
        msg: "Verification Failed !",
        backgroundColor: Colors.red,
        textColor: Colors.white,
        gravity: ToastGravity.BOTTOM,
      );
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => CustomerTiffinPackage()));
    }).then((data) async {
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      _firestore
          .document(_prefs.getString('userid'))
          .updateData(<String, dynamic>{"mobile": _phoneNumber});
      Fluttertoast.showToast(
        msg: "Phone Number Verified Successfully !",
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        gravity: ToastGravity.BOTTOM,
      );
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => CustomerTiffinPackage()));
    });
  }

  verifyPhoneNumber() async {
    PhoneVerificationCompleted _verificationDone = (AuthCredential credential) {
      _firebaseAuth.signInWithCredential(credential).then(((user) async {
        SharedPreferences _prefs = await SharedPreferences.getInstance();
        _firestore
            .document(_prefs.getString("userid"))
            .updateData(<String, dynamic>{"mobile": _phoneNumber});
        Fluttertoast.showToast(
          msg: "Phone Number Verified Successfully !",
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          gravity: ToastGravity.BOTTOM,
        );
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => CustomerTiffinPackage()));
      })).catchError((e) {
        Fluttertoast.showToast(
          msg: "Error Occured !",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          gravity: ToastGravity.BOTTOM,
        );
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => CustomerTiffinPackage()));
      });
    };

    PhoneVerificationFailed _verficationFailed = (AuthException exception) {
      Fluttertoast.showToast(
        msg: "Error Occured !",
        backgroundColor: Colors.red,
        textColor: Colors.white,
        gravity: ToastGravity.BOTTOM,
      );
    };

    PhoneCodeAutoRetrievalTimeout _codeTimeout = (verificationId) {
      setState(() {
        verID = verificationId;
      });
    };

    PhoneCodeSent _codeSend =
        (String verificationId, [int forceResendingToken]) {
      Fluttertoast.showToast(
        msg: "OTP sent successfully",
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        gravity: ToastGravity.BOTTOM,
      );
      setState(() {
        verID = verificationId;
        isCodeSent = true;
      });
    };

    _firebaseAuth.verifyPhoneNumber(
        phoneNumber: "+91$_phoneNumber",
        timeout: Duration(seconds: 60),
        verificationCompleted: _verificationDone,
        verificationFailed: _verficationFailed,
        codeSent: _codeSend,
        codeAutoRetrievalTimeout: _codeTimeout);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Fluttertoast.showToast(
          msg: "Can't go back !",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          gravity: ToastGravity.BOTTOM,
        );
        Fluttertoast.showToast(
          msg: "Verify your phone first !",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          gravity: ToastGravity.BOTTOM,
        );
      },
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
              color: myTheme.primaryColor,
            ),
          ),
          body: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Column(children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image(
                        image: AssetImage('asset/images/auth.png'),
                        alignment: Alignment.topCenter,
                        height: 220.0,
                      ),
                    ),
                    SizedBox(
                      height: 3.0,
                    ),
                    Text(
                      "Add your Phone Number",
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
                            onChanged: (value) {
                              setState(() {
                                _phoneNumber = value;
                              });
                            },
                            controller: _mobileForAuth,
                            textAlign: TextAlign.left,
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                onPressed: _phoneNumber.length == 10
                                    ? () {
                                        verifyPhoneNumber();
                                      }
                                    : null,
                                icon: Icon(Feather.check_circle),
                              ),
                              icon: Icon(Feather.phone),
                              hintText: "Enter Phone Number",
                              hintStyle: TextStyle(
                                  fontFamily: 'Raleway', color: Colors.black),
                              labelText: "Phone Number",
                              labelStyle: TextStyle(
                                  fontFamily: 'Raleway', color: Colors.black),
                            ),
                          ),
                          isCodeSent
                              ? verifyMyOTP(context)
                              : SizedBox(
                                  height: 10.0,
                                ),
                        ],
                      ),
                    ),
                  ])))),
    );
  }

  Widget verifyMyOTP(BuildContext context) {
    return Builder(builder: (context) {
      return Column(
        children: <Widget>[
          SizedBox(
            height: 20.0,
          ),
          TextField(
            autocorrect: false,
            enabled: true,
            onChanged: (value) {
              setState(() {
                _otpCode = value;
              });
            },
            controller: _otpController,
            textAlign: TextAlign.left,
            obscureText: true,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                onPressed: _otpCode.length == 6
                    ? () {
                        _signInWithPhoneNumber(_otpCode);
                      }
                    : null,
                icon: Icon(Feather.check_circle),
              ),
              icon: Icon(Feather.lock),
              hintText: "Enter OTP",
              hintStyle: TextStyle(fontFamily: 'Raleway', color: Colors.black),
              labelText: "One Time Password",
              labelStyle: TextStyle(fontFamily: 'Raleway', color: Colors.black),
            ),
          ),
        ],
      );
    });
  }
}
