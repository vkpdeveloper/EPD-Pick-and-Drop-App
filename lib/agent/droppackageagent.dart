import 'dart:async';
import 'package:epd_pick/customer/config.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:epd_pick/agent/agenthome.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:epd_pick/agent/agentmap.dart';

import '../main.dart';

class DropServiceAgent extends StatefulWidget {
  @override
  _DropServiceAgentState createState() => _DropServiceAgentState();
}

class _DropServiceAgentState extends State<DropServiceAgent> {
  StreamSubscription<LocationData> locationSubs;
  var agentId;

  @override
  void initState() {
    super.initState();
    agentId = "";
    isOrderStarted = false;
    getTiffinService();
    location.onLocationChanged().listen((data) async {
      _firestore.document(orderData['orderId']).setData({
        "liveAt": [data.latitude, data.longitude]
      }, merge: true);
    });
  }

  showNoOrder(BuildContext ctx) {
    showDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            title: Text("No Order !"),
            titlePadding: const EdgeInsets.all(10.0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0)),
            contentPadding: const EdgeInsets.all(10.0),
            content: Text("Dear Agent, there are no orders live for you !"),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  "Go Back !",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () => Navigator.pushReplacement(
                    ctx, MaterialPageRoute(builder: (context) => AgentHome())),
              )
            ],
          );
        });
  }

  var _firestore = Firestore.instance.collection('allOrders');
  Map<String, dynamic> orderData;
  getTiffinService() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    setState(() {
      agentId = _prefs.getString('agentid');
    });
    _firestore.getDocuments().then((order) {
      var checkOrder = 1;
      for (var tiffin in order.documents) {
        if (tiffin.data['agentId'] == agentId &&
            tiffin.data['isLive'] == true &&
            tiffin.data['serviceType'] == "Drop Package") {
          setState(() {
            checkOrder = 2;
            orderData = tiffin.data;
          });
          break;
        }
      }
      if (checkOrder == 1) {
        showNoOrder(context);
        setState(() {
          orderData == null;
        });
      }
    });
  }

  bool isOrderStarted = false;
  Location location;
  double liveLat, liveLon;

  startTheOrder() async {
    setState(() {
      isOrderStarted = true;
    });
    await location.getLocation().then((latlng) {
      setState(() {
        liveLat = latlng.latitude;
        liveLon = latlng.longitude;
      });
      Map<String, dynamic> data = <String, dynamic>{
        "liveAt": [liveLat, liveLon]
      };
      _firestore.document(orderData['orderId']).setData(data, merge: true);
    });
    var token = orderData['userToken'];
    var query =
        "?token=$token&title=Order Placement Started&message=Dear Customer, your order placement started by agent.";
    Future<Response> res = http.get("${Config.url}/$query");
    res.then((data) {
      if (data.statusCode == 200) {
        Fluttertoast.showToast(msg: "Notification sent to user");
      }
    });
  }

  var barcode;

  scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() => this.barcode = barcode);
      if (orderData['orderId'] == barcode) {
        Fluttertoast.showToast(msg: "Verification Successful");
      } else {
        Fluttertoast.showToast(msg: "Scanning wrong QR Code");
      }
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        Fluttertoast.showToast(msg: "Camera permission not granted !");
      } else {
        Fluttertoast.showToast(msg: "Something went wrong !");
      }
    } on FormatException {
      setState(() => this.barcode =
          'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      Fluttertoast.showToast(msg: "Some error occured !");
    }
  }

  completeOrder() {
    if (isOrderStarted) {
      if (barcode == orderData['orderId']) {
        Map<String, dynamic> newData = <String, dynamic>{"isLive": false};
        _firestore
            .document(orderData['orderId'])
            .setData(newData, merge: true)
            .then((data) {
          Fluttertoast.showToast(msg: "Order done successfully");
          var token = orderData['userToken'];
          var query =
              "?token=$token&title=Order done successfully&message=Dear Customer, your order had dropped to your picker. Your order's Order ID is ${orderData['orderId']}";
          Future<Response> res = http.get("${Config.url}/$query");
          res.then((data) {
            if (data.statusCode == 200) {
              Fluttertoast.showToast(msg: "Notification sent to user");
            }
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => AgentHome()));
          });
        }).catchError(
                (e) => Fluttertoast.showToast(msg: "Something went wrong !"));
      } else {
        Fluttertoast.showToast(msg: "Order not verified yet !");
      }
    } else {
      Fluttertoast.showToast(msg: "Order not started yet !");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Drop Package"),
      ),
      body: orderData != null
          ? Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Customer Name : ${orderData['customerName']}",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18.0),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      "Picker Name : ${orderData['pickerName']}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      "Order ID : ${orderData['orderId']}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      "Payment Type : ${orderData['paymentType']}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      "Picker Mobile : ${orderData['pickerMobile']}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      "Order Price : ${orderData['price']}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      "Total Distance : ${orderData['distance']}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25.0),
                        child: Image.network(
                          orderData['packageImage'],
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        FlatButton(
                          color: Colors.red,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                          textColor: Colors.white,
                          onPressed: startTheOrder,
                          child: Text(
                            "Start",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16.0),
                          ),
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        FlatButton(
                          color: Colors.purple,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                          textColor: Colors.white,
                          onPressed: () {
                            if (isOrderStarted) {
                              scan();
                            } else {
                              Fluttertoast.showToast(
                                  msg: "Start the order first");
                            }
                          },
                          child: Text(
                            "Verify",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16.0),
                          ),
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        FlatButton(
                          color: Colors.orange,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                          textColor: Colors.white,
                          onPressed: completeOrder,
                          child: Text(
                            "Done",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16.0),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    FlatButton(
                      color: Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                      textColor: Colors.white,
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AgentMap(orderId: orderData['orderId'])));
                      },
                      child: Text(
                        "Show on Map",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16.0),
                      ),
                    )
                  ],
                )),
              ),
            )
          : Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(myTheme.primaryColor),
              ),
            ),
    );
  }
}
