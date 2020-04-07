import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:epd_pick/agent/agentforgetpassword.dart';
import 'package:epd_pick/customer/config.dart';
import 'package:epd_pick/customer/ordersuccessful.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MakeOrder extends StatefulWidget {
  final double pickLat;
  final double pickLon;
  final double dropLat;
  final double dropLon;
  final String serviceType;
  final String timeTo;
  final String timefrom;

  const MakeOrder(
      {Key key,
      this.pickLat,
      this.pickLon,
      this.dropLat,
      this.dropLon,
      this.serviceType,
      this.timeTo,
      this.timefrom})
      : super(key: key);
  @override
  _MakeOrderState createState() => _MakeOrderState();
}

class _MakeOrderState extends State<MakeOrder> {
  @override
  void initState() {
    super.initState();
    _tiffinPay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _tiffinPaymentSuccess);
    _tiffinPay.on(Razorpay.EVENT_PAYMENT_ERROR, _tiffinPaymentFailed);
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _afterPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _afterPaymentError);
    if (widget.serviceType == "Tiffin Service") {
      isTiffinService = true;
    } else {
      isTiffinService = false;
    }
    selectedPaymentMethod = 1;
    isOrderSuccessful = true;
    if (widget.serviceType == "Drop Package") {
      getPrice();
    } else {
      price = int.parse(selectedPeriod) * 449;
      getDistance();
    }
  }

  var isOrderSuccessful;
  var selectedPaymentMethod;
  int price;
  var _firestore = Firestore.instance.collection('agent');
  var _firestoreOrder = Firestore.instance.collection('allOrders');
  Razorpay _razorpay = Razorpay();
  var isTiffinService;
  var paymentDropAgent;
  var paymentTiffinAgent;

  _afterPaymentSuccess() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    var userId = _prefs.getString("userid");
    var name = _prefs.getString("name");
    var tokenID = _prefs.getString("token");
    var orderId = "${DateTime.now().millisecondsSinceEpoch}";
    Map<String, dynamic> _orderData = <String, dynamic>{
      "orderId": orderId,
      "customerName": name,
      "pickFrom": [widget.pickLat, widget.pickLon],
      "dropAt": [widget.dropLat, widget.dropLon],
      "isLive": true,
      "userId": userId,
      "pickerMobile": phonePicker,
      "pickerName": namePicker,
      "agentId": paymentDropAgent.documentID,
      "paymentType": "Paid Order",
      "serviceType": "Drop Package",
      "userToken": tokenID,
      "price": price,
      "distance": "${realDistance}Km",
    };
    var _firestoreAllOrders =
        Firestore.instance.collection('allOrders').document(orderId);
    _firestoreAllOrders.setData(_orderData).then((value) {
      _firestore.document(paymentDropAgent.documentID).get().then((data) async {
        var totalMoney = data.data['totalEarned'];
        Map<String, dynamic> agentUpdateData = {
          "free": "no",
          "totalEarned": totalMoney + price
        };
        Firestore.instance
            .collection('agent')
            .document(paymentDropAgent.documentID)
            .setData(agentUpdateData, merge: true);
        var token = data.data['token'];
        var query =
            "?token=$token&title=New Order Placed&message=Dear agent, you got a new order by Mr. $name";
        Future<Response> res = get("${Config.url}/$query");
      });
      Fluttertoast.showToast(
        msg: "Order Placed Successful",
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        gravity: ToastGravity.BOTTOM,
      );
      setState(() {
        isOrderSuccessful = true;
      });
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => OrderConfirmation(
                    orderId: orderId,
                    agentId: paymentDropAgent.documentID,
                    name: namePicker,
                    mobile: phonePicker,
                  )));
    }).catchError((e) {
      Fluttertoast.showToast(
        msg: "Order not placed successfully !",
        backgroundColor: Colors.red,
        textColor: Colors.white,
        gravity: ToastGravity.BOTTOM,
      );
      setState(() {
        isOrderSuccessful = true;
      });
    });
  }

  _afterPaymentError() {
    setState(() => isOrderSuccessful = true);
    Fluttertoast.showToast(msg: "Payment Failed");
  }

  _tiffinPaymentSuccess() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    var userId = _prefs.getString("userid");
    var name = _prefs.getString("name");
    var tokenID = _prefs.getString("token");
    var orderId = "${DateTime.now().millisecondsSinceEpoch}";
    Map<String, dynamic> _orderData = <String, dynamic>{
      "orderId": orderId,
      "customerName": name,
      "pickFrom": [widget.pickLat, widget.pickLon],
      "dropAt": [widget.dropLat, widget.dropLon],
      "isLive": true,
      "userId": userId,
      "pickerMobile": phonePicker,
      "pickerName": namePicker,
      "agentId": paymentTiffinAgent.documentID,
      "paymentType": "Paid Order",
      "serviceType": "Tiffin Service",
      "userToken": tokenID,
      "price": (selectedPeriod * 449),
      "distance": "${realDistance}Km",
    };
    var _firestoreAllOrders =
        Firestore.instance.collection('allOrders').document(orderId);
    _firestoreAllOrders.setData(_orderData).then((value) {
      _firestore
          .document(paymentTiffinAgent.documentID)
          .get()
          .then((data) async {
        var totalMoney = data.data['totalEarned'];
        Map<String, dynamic> agentDataUpdate = <String, dynamic>{
          "free": "no",
        };
        Firestore.instance
            .collection('agent')
            .document(paymentTiffinAgent.documentID)
            .setData(agentDataUpdate, merge: true);
        var token = data.data['token'];
        var query =
            "?token=$token&title=New Order Placed&message=Dear agent, you got a new order by Mr. $name";
        Future<Response> res = get("${Config.url}/$query");
      });
      Fluttertoast.showToast(
        msg: "Order Placed Successful",
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        gravity: ToastGravity.BOTTOM,
      );
      setState(() {
        isOrderSuccessful = true;
      });
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => OrderConfirmation(
                    orderId: orderId,
                    agentId: paymentTiffinAgent.documentID,
                    name: namePicker,
                    mobile: phonePicker,
                  )));
    }).catchError((e) {
      Fluttertoast.showToast(
        msg: "Order not placed successfully !",
        backgroundColor: Colors.red,
        textColor: Colors.white,
        gravity: ToastGravity.BOTTOM,
      );
      setState(() {
        isOrderSuccessful = true;
      });
    });
  }

  _tiffinPaymentFailed() {
    setState(() => isOrderSuccessful = true);
    Fluttertoast.showToast(msg: "Payment Failed");
  }

  Razorpay _tiffinPay = Razorpay();

  tiffinStartPayment() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    var name = _prefs.getString("name");
    var mobile = _prefs.getString("mobile");
    var email = _prefs.getString("email");
    var options = {
      'key': Config.rozorpayApiKey,
      'amount': price * 100,
      'name': name,
      'description': 'Tiffin Service',
      'prefill': {'contact': mobile, 'email': email}
    };
    _tiffinPay.open(options);
  }

  dropStartPayment() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    var name = _prefs.getString("name");
    var mobile = _prefs.getString("mobile");
    var email = _prefs.getString("email");
    var options = {
      'key': Config.rozorpayApiKey,
      'amount': price * 100,
      'name': name,
      'description': 'Drop Package',
      'prefill': {'contact': mobile, 'email': email}
    };
    _razorpay.open(options);
  }

  List allPeriods = ["1", "2", "3", "4", "5", "6", "7", "8", "9"];
  var selectedPeriod = "1";
  var phonePicker;
  var namePicker;

  placeOrder() async {
    setState(() {
      isOrderSuccessful = false;
    });
    final QuerySnapshot _queryAgent = await _firestore.getDocuments();
    final List<DocumentSnapshot> _myAgentFree = _queryAgent.documents;
    var checkAgent = 1;
    for (var agent in _myAgentFree) {
      if (agent.data['free'] == "yes") {
        checkAgent = 2;
        if (selectedPaymentMethod == 1) {
          if (widget.serviceType == "Drop Package") {
            SharedPreferences _prefs = await SharedPreferences.getInstance();
            var userId = _prefs.getString("userid");
            var name = _prefs.getString("name");
            var tokenID = _prefs.getString("token");
            var orderId = "${DateTime.now().millisecondsSinceEpoch}";
            Map<String, dynamic> _orderData = <String, dynamic>{
              "orderId": orderId,
              "customerName": name,
              "pickFrom": [widget.pickLat, widget.pickLon],
              "dropAt": [widget.dropLat, widget.dropLon],
              "isLive": true,
              "userId": userId,
              "pickerMobile": phonePicker,
              "pickerName": namePicker,
              "agentId": agent.documentID,
              "paymentType": "Cash on Delivery",
              "serviceType": "Drop Package",
              "userToken": tokenID,
              "price": price,
              "distance": "${realDistance}Km",
              "timing": [widget.timefrom, widget.timeTo]
            };
            var _firestoreAllOrders =
                Firestore.instance.collection('allOrders').document(orderId);
            _firestoreAllOrders.setData(_orderData).then((value) {
              _firestore.document(agent.documentID).get().then((data) async {
                int totalMoney = data.data['totalEarned'];
                Map<String, dynamic> allUpdates = <String, dynamic>{
                  "free": "no",
                  "totalEarned": totalMoney + price,
                };
                Firestore.instance
                    .collection('agent')
                    .document(agent.documentID)
                    .setData(allUpdates, merge: true)
                    .then((value) {
                  print("Done Bro");
                });
                var token = data.data['token'];
                var query =
                    "?token=$token&title=New Order Placed&message=Dear agent, you got a new order by Mr. $name";
                Future<Response> res = get("${Config.url}/$query");
              });
              Fluttertoast.showToast(
                msg: "Order Placed Successful",
                backgroundColor: Colors.black54,
                textColor: Colors.white,
                gravity: ToastGravity.BOTTOM,
              );
              setState(() {
                isOrderSuccessful = true;
              });
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => OrderConfirmation(
                            orderId: orderId,
                            agentId: agent.documentID,
                            name: namePicker,
                            mobile: phonePicker,
                          )));
            }).catchError((e) {
              Fluttertoast.showToast(
                msg: "Order not placed successfully !",
                backgroundColor: Colors.red,
                textColor: Colors.white,
                gravity: ToastGravity.BOTTOM,
              );
              setState(() {
                isOrderSuccessful = true;
              });
            });
          } else if (widget.serviceType == "Tiffin Service") {
            SharedPreferences _prefs = await SharedPreferences.getInstance();
            var userId = _prefs.getString("userid");
            var name = _prefs.getString("name");
            var tokenID = _prefs.getString("token");
            var orderId = "${DateTime.now().millisecondsSinceEpoch}";
            Map<String, dynamic> _orderData = <String, dynamic>{
              "orderId": orderId,
              "customerName": name,
              "pickFrom": [widget.pickLat, widget.pickLon],
              "dropAt": [widget.dropLat, widget.dropLon],
              "isLive": true,
              "userId": userId,
              "pickerMobile": phonePicker,
              "pickerName": namePicker,
              "agentId": agent.documentID,
              "paymentType": "Cash on Delivery",
              "serviceType": "Tiffin Service",
              "userToken": tokenID,
              "price": (int.parse(selectedPeriod) * 449),
              "distance": "${realDistance}Km",
              "timing": [widget.timefrom, widget.timeTo]
            };
            var _firestoreAllOrders =
                Firestore.instance.collection('allOrders').document(orderId);
            _firestoreAllOrders.setData(_orderData).then((value) {
              _firestore.document(agent.documentID).get().then((data) async {
                int totalMoney = data.data['totalEarned'];
                Map<String, dynamic> allUpdates = <String, dynamic>{
                  "free": "no",
                  "totalEarned": totalMoney + (int.parse(selectedPeriod) * 449)
                };
                Firestore.instance
                    .collection('agent')
                    .document(agent.documentID)
                    .setData(allUpdates, merge: true)
                    .then((value) {
                  print("done");
                });
                var token = data.data['token'];
                var query =
                    "?token=$token&title=New Order Placed&message=Dear agent, you got a new order by Mr. $name";
                Future<Response> res = get("${Config.url}/$query");
              });
              Fluttertoast.showToast(
                msg: "Order Placed Successful",
                backgroundColor: Colors.black54,
                textColor: Colors.white,
                gravity: ToastGravity.BOTTOM,
              );
              setState(() {
                isOrderSuccessful = true;
              });
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => OrderConfirmation(
                            orderId: orderId,
                            agentId: agent.documentID,
                            name: namePicker,
                            mobile: phonePicker,
                          )));
            }).catchError((e) {
              Fluttertoast.showToast(
                msg: "Order not placed successfully !",
                backgroundColor: Colors.red,
                textColor: Colors.white,
                gravity: ToastGravity.BOTTOM,
              );
              setState(() {
                isOrderSuccessful = true;
              });
            });
          }
        } else if (selectedPaymentMethod == 2) {
          if (widget.serviceType == "Drop Package") {
            setState(() {
              paymentDropAgent = agent;
              dropStartPayment();
            });
          } else if (widget.serviceType == "Tiffin Service") {
            tiffinStartPayment();
          }
        }
        break;
      }
    }
    if (checkAgent == 1) {
      if (selectedPaymentMethod == 1) {
        if (widget.serviceType == "Drop Package") {
          SharedPreferences _prefs = await SharedPreferences.getInstance();
          var userId = _prefs.getString("userid");
          var name = _prefs.getString("name");
          var tokenID = _prefs.getString("token");
          var orderId = "${DateTime.now().millisecondsSinceEpoch}";
          Map<String, dynamic> _orderData = <String, dynamic>{
            "orderId": orderId,
            "customerName": name,
            "pickFrom": [widget.pickLat, widget.pickLon],
            "dropAt": [widget.dropLat, widget.dropLon],
            "isLive": "pending",
            "userId": userId,
            "pickerMobile": phonePicker,
            "pickerName": namePicker,
            "paymentType": "Cash on Delivery",
            "serviceType": "Drop Package",
            "userToken": tokenID,
            "price": price,
            "distance": "${realDistance}Km",
            "timing": [widget.timefrom, widget.timeTo]
          };
          var _firestoreAllOrders =
              Firestore.instance.collection('allOrders').document(orderId);
          _firestoreAllOrders.setData(_orderData).then((value) {
            _firestore.document("admin").get().then((data) async {
              var token = data.data['token'];
              var query =
                  "?token=$token&title=New Unassigned Placed&message=Dear Admin, new unassigned order placed by Mr. $name";
              Future<Response> res = get("${Config.url}/$query");
            });
            Fluttertoast.showToast(
              msg: "Order Placed Successful",
              backgroundColor: Colors.black54,
              textColor: Colors.white,
              gravity: ToastGravity.BOTTOM,
            );
            setState(() {
              isOrderSuccessful = true;
            });
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => OrderConfirmation(
                          orderId: orderId,
                          agentId: "Pending",
                          name: namePicker,
                          mobile: phonePicker,
                        )));
          }).catchError((e) {
            Fluttertoast.showToast(
              msg: "Order not placed successfully !",
              backgroundColor: Colors.red,
              textColor: Colors.white,
              gravity: ToastGravity.BOTTOM,
            );
            setState(() {
              isOrderSuccessful = true;
            });
          });
        } else if (widget.serviceType == "Tiffin Service") {
          SharedPreferences _prefs = await SharedPreferences.getInstance();
          var userId = _prefs.getString("userid");
          var name = _prefs.getString("name");
          var tokenID = _prefs.getString("token");
          var orderId = "${DateTime.now().millisecondsSinceEpoch}";
          Map<String, dynamic> _orderData = <String, dynamic>{
            "orderId": orderId,
            "customerName": name,
            "pickFrom": [widget.pickLat, widget.pickLon],
            "dropAt": [widget.dropLat, widget.dropLon],
            "isLive": "pending",
            "userId": userId,
            "pickerMobile": phonePicker,
            "pickerName": namePicker,
            "paymentType": "Cash on Delivery",
            "serviceType": "Tiffin Service",
            "userToken": tokenID,
            "price": (int.parse(selectedPeriod) * 449),
            "distance": "${realDistance}Km",
            "timing": [widget.timefrom, widget.timefrom]
          };
          var _firestoreAllOrders =
              Firestore.instance.collection('allOrders').document(orderId);
          _firestoreAllOrders.setData(_orderData).then((value) {
            Firestore.instance
                .collection("admin")
                .document('admin')
                .get()
                .then((data) async {
              var token = data.data['token'];
              var query =
                  "?token=$token&title=New Unassigned Order Placed&message=Dear Admin, new unassigned order placed by Mr. $name";
              Future<Response> res = get("${Config.url}/$query");
            });
            Fluttertoast.showToast(
              msg: "Order Placed Successful",
              backgroundColor: Colors.black54,
              textColor: Colors.white,
              gravity: ToastGravity.BOTTOM,
            );
            setState(() {
              isOrderSuccessful = true;
            });
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => OrderConfirmation(
                          orderId: orderId,
                          agentId: "Pending",
                          name: namePicker,
                          mobile: phonePicker,
                        )));
          }).catchError((e) {
            Fluttertoast.showToast(
              msg: "Order not placed successfully !",
              backgroundColor: Colors.red,
              textColor: Colors.white,
              gravity: ToastGravity.BOTTOM,
            );
            setState(() {
              isOrderSuccessful = true;
            });
          });
        }
      } else if (selectedPaymentMethod == 2) {
        if (widget.serviceType == "Drop Package") {
        } else if (widget.serviceType == "Tiffin Service") {}
      }
    }
  }

  var realDistance;

  getDistance() async {
    double distance = await Geolocator()
        .distanceBetween(
            widget.pickLat, widget.pickLon, widget.dropLat, widget.dropLon)
        .then((myDistance) {
      realDistance = (myDistance ~/ 1000);
    });
  }

  getPrice() async {
    double distance = await Geolocator()
        .distanceBetween(
            widget.pickLat, widget.pickLon, widget.dropLat, widget.dropLon)
        .then((myDistance) {
      realDistance = (myDistance ~/ 1000);
    });
    if (realDistance <= 5) {
      setState(() {
        price = 40;
      });
    } else if (realDistance > 5 && realDistance <= 10) {
      setState(() {
        price = 40;
      });
    } else if (realDistance > 10) {
      var rest = realDistance - 10;
      setState(() {
        price = ((80 * rest * 9).toInt());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0.0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 0.0),
              child: Center(
                child: Text(
                  "Pay ₹$price",
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
            ),
            isOrderSuccessful
                ? Expanded(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: RaisedButton(
                        elevation: 8.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0)),
                          onPressed: placeOrder,
                          color: myTheme.primaryColor,
                          textColor: Colors.white,
                          child: Text(
                            "Order Now",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16.0),
                          )),
                    ),
                  )
                : CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(myTheme.primaryColor))
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            isTiffinService
                ? Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Select Period : ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18.0),
                          ),
                        ),
                        DropdownButton(
                            onChanged: (value) {
                              setState(() {
                                this.selectedPeriod = value;
                                price = int.parse(selectedPeriod) * 449;
                              });
                            },
                            value: selectedPeriod,
                            hint: Text("Select Period"),
                            items: allPeriods
                                .map<DropdownMenuItem<String>>((item) {
                              return DropdownMenuItem(
                                child: Text("$item Month"),
                                value: item,
                              );
                            }).toList())
                      ],
                    ),
                  )
                : SizedBox(
                    height: 1,
                  ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Select Payment Method : ",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                ),
              ),
            ),
            RadioListTile(
              activeColor: myTheme.primaryColor,
              groupValue: selectedPaymentMethod,
              value: 1,
              onChanged: (value) =>
                  setState(() => selectedPaymentMethod = value),
              title: Text("Cash on Delivery"),
            ),
            RadioListTile(
              activeColor: myTheme.primaryColor,
              groupValue: selectedPaymentMethod,
              value: 2,
              onChanged: (value) =>
                  setState(() => selectedPaymentMethod = value),
              title: Text("Pay Online"),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Picker Details : ",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                ),
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: Column(
                children: <Widget>[
                  TextField(
                    autocorrect: false,
                    enabled: true,
                    readOnly: false,
                    onChanged: (value) => setState(() => namePicker = value),
                    textAlign: TextAlign.left,
                    decoration: InputDecoration(
                      hintText: "Enter Picker Name",
                      hintStyle:
                          TextStyle(fontFamily: 'Raleway', color: Colors.black),
                      labelText: "Picker Name",
                      labelStyle:
                          TextStyle(fontFamily: 'Raleway', color: Colors.black),
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  TextField(
                    autocorrect: false,
                    enabled: true,
                    keyboardType: TextInputType.number,
                    readOnly: false,
                    onChanged: (value) => setState(() => phonePicker = value),
                    textAlign: TextAlign.left,
                    decoration: InputDecoration(
                      hintText: "Enter Picker Phone",
                      hintStyle:
                          TextStyle(fontFamily: 'Raleway', color: Colors.black),
                      labelText: "Picker Phone",
                      labelStyle:
                          TextStyle(fontFamily: 'Raleway', color: Colors.black),
                    ),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
