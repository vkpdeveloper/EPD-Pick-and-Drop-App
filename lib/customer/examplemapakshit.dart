import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:epd_pick/customer/trackorder.dart';
import 'package:epd_pick/widgets/qr_code_generator.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class AllOrders extends StatefulWidget {
  @override
  _AllOrdersState createState() => _AllOrdersState();
}

class _AllOrdersState extends State<AllOrders> {
  var _allOrders;

  @override
  void initState() {
    getAllOrders();
    super.initState();
  }

  showVerifyDialog(String data) async {
    return showBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25.0),
                topRight: Radius.circular(25.0))),
        builder: (context) {
          return Container(
            height: 180.0,
            alignment: Alignment.center,
            child: GenerateQRCode(
              data: data,
            ),
          );
        });
  }

  getAllOrders() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    var userId = _prefs.getString("userid");
    var _firestore = Firestore.instance
        .collection('allOrders')
        .where("userId", isEqualTo: "102611915554035821196")
        .getDocuments()
        .then((order) {
      order.documents.map((data) {
        _allOrders.add(data.data);
        print(data.data);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          label: Text(
            "Query",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          icon: Icon(Icons.help),
          backgroundColor: Colors.purple,
          hoverElevation: 15.0,
          elevation: 10.0,
        ),
        appBar: AppBar(
          title: Text("All Orders"),
        ),
        body: Padding(
            padding: const EdgeInsets.only(
                left: 8.0, right: 8.0, top: 8.0, bottom: 10.0),
            child: ListView.builder(
                primary: true,
                scrollDirection: Axis.vertical,
                physics: AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _allOrders.length,
                itemBuilder: (context, index) {
                  return _allOrders != null
                      ? Container(
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
                                        "Order ID : ${_allOrders[index]["orderId"]}",
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
                                        "Your Agent : ${_allOrders[index]["agentId"]}",
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
                                        "Payment Type : ${_allOrders[index]['paymentType']}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black54),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 8.0,
                                    ),
                                    _allOrders[index]['isLive']
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              MaterialButton(
                                                textColor: Colors.white,
                                                color: Colors.purple,
                                                onPressed: () => Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            TrackOrder(
                                                              orderId:
                                                                  _allOrders[
                                                                          index]
                                                                      [
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
                                                color: Colors.red,
                                                onPressed: () =>
                                                    showVerifyDialog(
                                                        _allOrders[index]
                                                            ['orderId']),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25.0)),
                                                child: Text("Verify Order"),
                                              ),
                                            ],
                                          )
                                        : Column(
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
                                          )
                                  ],
                                )),
                          ),
                        )
                      : Center(
                          child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  myTheme.primaryColor)),
                        );
                })));
  }
}
