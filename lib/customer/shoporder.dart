import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:epd_pick/customer/config.dart';
import 'package:epd_pick/customer/ordersuccessful.dart';
import 'package:epd_pick/models/shopordermodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class ShopOrder extends StatefulWidget {
  final ShopOrderModel shopOrderModel;

  const ShopOrder({Key key, this.shopOrderModel}) : super(key: key);
  @override
  _ShopOrderState createState() => _ShopOrderState();
}

class _ShopOrderState extends State<ShopOrder> {
  getPickLocation() {
    var pos = location.getLocation();
    pos.then((onValue) {
      setState(() {
        pickLat = onValue.latitude;
        pickLon = onValue.longitude;
      });
    }).catchError((e) {
      Fluttertoast.showToast(
        msg: "Error Occured !",
        backgroundColor: Colors.red,
        textColor: Colors.white,
        gravity: ToastGravity.BOTTOM,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    isOrderSuccessful = true;
    getPickLocation();
  }

  Location location = Location();

  var phonePicker;
  var namePicker;
  bool isOrderSuccessful;
  double pickLat, pickLon, dropLat, dropLon;
  var selectedPaymentMethod = 1;
  var _firestore = Firestore.instance.collection('agent');

  void placeOrder() async {
    if (namePicker != "" &&
        phonePicker != "" &&
        _dropLocationController.text != "") {
      setState(() {
        isOrderSuccessful = false;
      });
      final QuerySnapshot _queryAgent = await _firestore.getDocuments();
      final List<DocumentSnapshot> _myAgentFree = _queryAgent.documents;
      var checkAgent = 1;
      for (var agent in _myAgentFree) {
        if (agent.data['free'] == 'yes') {
          setState(() {
            checkAgent = 2;
          });
          SharedPreferences _prefs = await SharedPreferences.getInstance();
          var userId = _prefs.getString("userid");
          var name = _prefs.getString("name");
          var tokenID = _prefs.getString("token");
          var orderId = "${DateTime.now().millisecondsSinceEpoch}";
          Map<String, dynamic> _orderData = <String, dynamic>{
            "orderId": orderId,
            "customerName": name,
            "dropAt": [dropLat, dropLon],
            "isLive": true,
            "userId": userId,
            "pickerMobile": phonePicker,
            "pickerName": namePicker,
            "agentId": agent.documentID,
            "paymentType": "Cash on Delivery",
            "serviceType": "Shop",
            "userToken": tokenID,
            "price": widget.shopOrderModel.itemData['price'],
          };
          var _firestoreAllOrders =
              Firestore.instance.collection('allOrders').document(orderId);
          _firestoreAllOrders.setData(_orderData).then((value) {
            _firestore.document(agent.documentID).get().then((data) async {
              int totalMoney = data.data['totalEarned'];
              Fluttertoast.showToast(msg: "$totalMoney");
              Map<String, dynamic> allUpdates = <String, dynamic>{
                "free": "no",
                "totalEarned":
                    totalMoney + widget.shopOrderModel.itemData['price'],
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
              var query2 =
                  "?token=${widget.shopOrderModel.shopToken}&title=New Order Placed&message=Dear shopkeeper, you got a new order by Mr. $name";
              Future<Response> res2 = get("${Config.url}/$query2");
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
          break;
        }
      }
      if (checkAgent == 1) {
        Fluttertoast.showToast(
            msg: "Sorry! any agent is not free now wait for some time");
      }
    }
  }

  TextEditingController _dropLocationController;

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
                  "Pay ₹${widget.shopOrderModel.itemData['price']}",
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
                          await showLocationPicker(context, Config.apiKey,
                                  initialCenter: LatLng(
                                    pickLat,
                                    pickLon,
                                  ),
                                  appBarColor: myTheme.primaryColor,
                                  automaticallyAnimateToCurrentLocation: true,
                                  hintText: "Enter Drop Address",
                                  myLocationButtonEnabled: true,
                                  layersButtonEnabled: true)
                              .then((result) {
                            LatLng data = result.latLng;
                            setState(() {
                              dropLat = data.latitude;
                              dropLon = data.longitude;
                              _dropLocationController.text = result.address;
                            });
                          }).catchError((e) {
                            Fluttertoast.showToast(
                                msg: "Error in getting drop location");
                          });
                        },
                        icon: Icon(Octicons.location),
                      ),
                      hintText: "Enter Drop Location",
                      hintStyle:
                          TextStyle(fontFamily: 'Raleway', color: Colors.black),
                      labelText: "Drop Location",
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
