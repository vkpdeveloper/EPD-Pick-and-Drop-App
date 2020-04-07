import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:epd_pick/customer/trackorder.dart';
import 'package:epd_pick/widgets/qr_code_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';

class AllOrders extends StatefulWidget {
  @override
  _AllOrdersState createState() => _AllOrdersState();
}

class _AllOrdersState extends State<AllOrders> {
  var _allOrders;

  @override
  void initState() {
    super.initState();
    getAllOrders();
  }

  getAllOrders() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = _prefs.getString("userid");
    });
  }

  showVerifyDialog(String data) {
    return showModalBottomSheet(
      elevation: 8.0,
      backgroundColor: Colors.white,
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25.0),
                topRight: Radius.circular(25.0))),
        builder: (context) {
          return Center(
            child: Container(
              height: 200.0,
              alignment: Alignment.center,
              child: Column(
                children: <Widget>[
                  Text(
                    "Scan the QR Code :",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Center(
                    child: Container(
                      height: 150,
                      width: 150,
                      child: GenerateQRCode(
                        data: data,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  var userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () => launch("mailto: shivamepd@gmail.com"),
          child: Icon(AntDesign.question),
          backgroundColor: myTheme.primaryColor,
          hoverElevation: 15.0,
          elevation: 10.0,
          foregroundColor: Colors.white,
        ),
        appBar: AppBar(
          title: Text("All Orders"),
        ),
        body: Padding(
            padding: const EdgeInsets.only(
                left: 8.0, right: 8.0, top: 8.0, bottom: 10.0),
            child: StreamBuilder(
              stream: Firestore.instance
                  .collection('allOrders')
                  .where("userId", isEqualTo: userId)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  print("error in snapshot ${snapshot.error}");
                }
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                myTheme.primaryColor)));
                  default:
                    return ListView(
                      children: snapshot.data.documents
                          .map((DocumentSnapshot document) {
                        return Container(
                          child: Card(
                            elevation: 8.0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0)),
                            child: Container(
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                  children: <Widget>[
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        "Order ID : ${document["orderId"]}",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        "Your Agent : ${document["agentId"]}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black54),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        "Payment Type : ${document["paymentType"]}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black54),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 8.0,
                                    ),
                                    getDropDetails(document)
                                  ],
                                )),
                          ),
                        );
                      }).toList(),
                    );
                }
              },
            )));
  }
  Widget getDropDetails(DocumentSnapshot document) {
    if (document['isLive'] == true) {
      return
        Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
          children: <Widget>[
            MaterialButton(
              textColor: Colors.white,
              color: myTheme.primaryColor,
              onPressed: () =>
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              TrackOrder(
                                orderId: document[
                                'orderId'],
                              ))),
              shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                      25.0)),
              child: Text(
                "Track Order",
                style: TextStyle(
                    fontWeight:
                    FontWeight.bold),
              ),
            ),
            MaterialButton(
              textColor: Colors.white,
              color: myTheme.primaryColor,
              onPressed: () =>
                  showVerifyDialog(
                      document['orderId']),
              shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                      25.0)),
              child: Text("Verify Order",
                  style: TextStyle(
                      fontWeight:
                      FontWeight.bold)),
            ),
          ],
        );
    } else if (document['isLive'] == false) {
      return Column(
        children: <Widget>[
          SizedBox(
            height: 5.0,
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              "Order had Dropped Successfully",
              style: TextStyle(
                  fontWeight:
                  FontWeight.bold,
                  color: Colors.black54),
            ),
          ),
        ],
      );
    } else if(document['isLive'] == "pending"){
      return Column(
        children: <Widget>[
          SizedBox(
            height: 5.0,
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              "Order is on waiting !",
              style: TextStyle(
                  fontWeight:
                  FontWeight.bold,
                  color: Colors.black54),
            ),
          ),
        ],
      );
    }
  }
}
