import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:epd_pick/customer/customerLogin.dart';
import 'package:epd_pick/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

var myTheme = MyTheme();

class CustomerProfile extends StatefulWidget {
  @override
  _CustomerProfileState createState() => _CustomerProfileState();
}

class _CustomerProfileState extends State<CustomerProfile> {
  var referralCode = "0000000000";
  var name = "";
  var mobileNumber = "";
  var userId = "";
  var emailId = "";
  var _profileURL = "https://cdn.browshot.com/static/images/not-found.png";
  var _firestore = Firestore.instance.collection('users');

  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    userId = preferences.getString("userid");
    _firestore.document(userId).get().then((data) {
      setState(() {
        if (data.data['mobile'] == null) {
          name = data.data['name'];
          mobileNumber = "Not Found !";
          emailId = data.data['email'];
          _profileURL = data.data['profile'];
          referralCode = data.data['referral'];
        } else {
          name = data.data['name'];
          mobileNumber = data.data['mobile'];
          emailId = data.data['email'];
          _profileURL = data.data['profile'];
          referralCode = data.data['referral'];
        }
      });
    }).catchError((e) {
      setState(() {
        name = "Error Occured !";
        mobileNumber = "Error Occured !";
        emailId = "Error Occured !";
        _profileURL = "https://cdn.browshot.com/static/images/not-found.png";
        referralCode = "Error Occured !";
      });
    });
  }

  logoutnow() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          actions: <Widget>[
            FlatButton(
              splashColor: Colors.transparent,
              onPressed: () => logoutnow(),
              child: Text("Logout",
                  style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: myTheme.primaryColor,
            ),
            child: SafeArea(
              child: Stack(
                children: <Widget>[
                  Center(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: Hero(
                            tag: "profile",
                            child: CircleAvatar(
                              backgroundImage: NetworkImage("$_profileURL"),
                              maxRadius: 60,
                              minRadius: 60,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: Text(
                            "$name",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontFamily: 'Raleway',
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          "User Details",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            height: 250,
                            width: MediaQuery.of(context).size.width - 40,
                            child: Card(
                              elevation: 10.0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  ListTile(
                                    leading: Icon(Icons.verified_user),
                                    title: Flex(
                                      direction: Axis.horizontal,
                                      textDirection: TextDirection.ltr,
                                      children: <Widget>[
                                        Flexible(
                                          flex: 1,
                                          fit: FlexFit.loose,
                                          child: Text(
                                            "$userId",
                                            style: TextStyle(
                                              fontSize: 16.0,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.phone),
                                    title: Flex(
                                      direction: Axis.horizontal,
                                      textDirection: TextDirection.ltr,
                                      children: <Widget>[
                                        Flexible(
                                          flex: 1,
                                          fit: FlexFit.loose,
                                          child: Text(
                                            "$mobileNumber",
                                            style: TextStyle(
                                              fontSize: 16.0,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.people),
                                    title: Flex(
                                      direction: Axis.horizontal,
                                      textDirection: TextDirection.ltr,
                                      children: <Widget>[
                                        Flexible(
                                          flex: 1,
                                          fit: FlexFit.loose,
                                          child: Text(
                                            referralCode,
                                            style: TextStyle(
                                              fontSize: 16.0,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(
                                                text: referralCode))
                                            .then((value) {
                                          Fluttertoast.showToast(
                                            msg: "Referral Copied successfully",
                                            backgroundColor: Colors.black54,
                                            textColor: Colors.white,
                                            gravity: ToastGravity.BOTTOM,
                                          );
                                        });
                                      },
                                      icon: Icon(Feather.copy),
                                    ),
                                  ),
                                  ListTile(
                                    leading: Icon(Feather.mail),
                                    title: Flex(
                                      direction: Axis.horizontal,
                                      textDirection: TextDirection.ltr,
                                      children: <Widget>[
                                        Flexible(
                                          flex: 1,
                                          fit: FlexFit.loose,
                                          child: Text(
                                            "$emailId",
                                            style: TextStyle(
                                              fontSize: 16.0,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
