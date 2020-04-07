import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:epd_pick/agent/agentforgetpassword.dart';
import 'package:epd_pick/customer/makeorder.dart';
import 'package:epd_pick/customer/phoneauth/droppackagephoneauth.dart';
import 'package:epd_pick/customer/phoneauth/tiffinpackagephoneauth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerTiffinPackage extends StatefulWidget {
  @override
  _CustomerTiffinPackageState createState() => _CustomerTiffinPackageState();
}

class _CustomerTiffinPackageState extends State<CustomerTiffinPackage> {
  TextEditingController _pickLocationController = TextEditingController();
  TextEditingController _dropLocationController = TextEditingController();
  var _firestoreAgent = Firestore.instance.collection('agent');

  void dispose() {
    super.dispose();
    locationSubscripation.cancel();
    _pickLocationController.clear();
    _dropLocationController.clear();
  }

  var selectedPaymentMethod = 1;
  var isOrderSuccessful;
  TimeOfDay _time = TimeOfDay.now();
  var toTime = "To";
  var fromTime = "From";

  Future<Null> showToTimePicker(BuildContext context) async {
    _time = await showTimePicker(context: context, initialTime: _time);
    setState(() {
      toTime = "${_time.hour}:${_time.minute}";
    });
  }

  Future<Null> showFromTimePicker(BuildContext context) async {
    _time = await showTimePicker(context: context, initialTime: _time);
    setState(() {
      fromTime = "${_time.hour}:${_time.minute}";
    });
  }

  @override
  void initState() {
    super.initState();
    isOrderSuccessful = true;
    addMobileNumber();
    pickLat = 0.0;
    pickLong = 0.0;
    myCurrentLocation = "";
  }

  LocationData locationData;
  var _firestoreUser = Firestore.instance.collection('users');

  var pickLat = 0.0;
  var pickLong = 0.0;
  var apiKey = "AIzaSyBEU9qa9svA6IwvHc5SmOqg0zoplSczGzM";
  StreamSubscription<LocationData> locationSubscripation;
  var myCurrentLocation;

  double dropLat;
  double dropLong;

  Location location = Location();

  _showAddPhoneDialog() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "Warning !",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text("Add your phone number to proceed ahead !"),
            contentPadding: EdgeInsets.all(15.0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0)),
            actions: <Widget>[
              FlatButton(
                splashColor: Colors.transparent,
                textColor: myTheme.primaryColor,
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CustomerPhoneAuthTiffin()));
                },
                child: Text(
                  "Add Phone",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            ],
          );
        });
  }

  addMobileNumber() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    var userId = _prefs.getString("userid");
    var _firestore = Firestore.instance.document('users/$userId');
    _firestore.get().then((userData) {
      if (userData.data['mobile'] == null) {
        _showAddPhoneDialog();
      }
    }).catchError((e) => print("Error Occured !"));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(color: Colors.white),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image(
                      image: AssetImage('asset/images/tiffinbox.png'),
                      alignment: Alignment.topCenter,
                      height: 220.0,
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Feather.box,
                          size: 40.0,
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          "Tiffin Service",
                          style: TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.bold),
                        )
                      ]),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    "Fill correct details to drop your Tiffin",
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: <Widget>[
                        TextField(
                          autocorrect: false,
                          enabled: true,
                          readOnly: true,
                          controller: _pickLocationController,
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              onPressed: () async {
                                await showLocationPicker(context, apiKey,
                                        initialCenter: LatLng(
                                          pickLat,
                                          pickLong,
                                        ),
                                        appBarColor: myTheme.primaryColor,
                                        automaticallyAnimateToCurrentLocation:
                                            true,
                                        hintText: "Enter Pick Address",
                                        myLocationButtonEnabled: true,
                                        layersButtonEnabled: true)
                                    .then((result) {
                                  LatLng data = result.latLng;
                                  setState(() {
                                    pickLat = data.latitude;
                                    pickLong = data.longitude;
                                    _pickLocationController.text =
                                        result.address;
                                  });
                                }).catchError((e) {
                                  Fluttertoast.showToast(
                                      msg: "Error in getting Pick location");
                                });
                              },
                              icon: Icon(Octicons.location),
                            ),
                            hintText: "Enter Pick Location",
                            hintStyle: TextStyle(
                                fontFamily: 'Raleway', color: Colors.black),
                            labelText: "Pick Location",
                            labelStyle: TextStyle(
                                fontFamily: 'Raleway', color: Colors.black),
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        TextField(
                          autocorrect: false,
                          enabled: true,
                          readOnly: true,
                          controller: _dropLocationController,
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              onPressed: () async {
                                await showLocationPicker(context, apiKey,
                                        initialCenter: LatLng(
                                          pickLat,
                                          pickLong,
                                        ),
                                        appBarColor: myTheme.primaryColor,
                                        automaticallyAnimateToCurrentLocation:
                                            true,
                                        hintText: "Enter Drop Address",
                                        myLocationButtonEnabled: true,
                                        layersButtonEnabled: true)
                                    .then((result) {
                                  LatLng data = result.latLng;
                                  setState(() {
                                    dropLat = data.latitude;
                                    dropLong = data.longitude;
                                    _dropLocationController.text =
                                        result.address;
                                  });
                                }).catchError((e) {
                                  Fluttertoast.showToast(
                                      msg: "Error in getting drop location");
                                });
                              },
                              icon: Icon(Octicons.location),
                            ),
                            hintText: "Enter Drop Location",
                            hintStyle: TextStyle(
                                fontFamily: 'Raleway', color: Colors.black),
                            labelText: "Drop Location",
                            labelStyle: TextStyle(
                                fontFamily: 'Raleway', color: Colors.black),
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text("Select timing",
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.black)),
                        SizedBox(
                          height: 5.0,
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 30.0, right: 30.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              FlatButton(
                                onPressed: () => showFromTimePicker(context),
                                child: Text(fromTime,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0)),
                              ),
                              FlatButton(
                                onPressed: () => showToTimePicker(context),
                                child: Text(toTime,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0)),
                              )
                            ],
                          ),
                        ),
                        MaterialButton(
                          minWidth: 280,
                          height: 40.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0)),
                          onPressed: () {
                            if (_dropLocationController.text != "" &&
                                _pickLocationController.text != "") {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MakeOrder(
                                            pickLat: pickLat,
                                            pickLon: pickLong,
                                            dropLat: dropLat,
                                            dropLon: dropLong,
                                            serviceType: "Tiffin Service",
                                            timefrom: fromTime,
                                            timeTo: toTime,
                                          )));
                            }
                          },
                          child: Text(
                            "Place Order",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16.0),
                          ),
                          elevation: 8.0,
                          color: myTheme.primaryColor,
                          textColor: Colors.white,
                        ),
                        SizedBox(
                          height: 15.0,
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
