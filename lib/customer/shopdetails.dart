import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:epd_pick/agent/agentforgetpassword.dart';
import 'package:epd_pick/customer/shoporder.dart';
import 'package:epd_pick/models/shopdetailsmodel.dart';
import 'package:epd_pick/models/shopordermodel.dart';
import 'package:flutter/material.dart';

class ShopDetails extends StatefulWidget {
  final ShopDetailsModel shopDetailsModel;

  const ShopDetails({Key key, this.shopDetailsModel}) : super(key: key);
  @override
  _ShopDetailsState createState() => _ShopDetailsState();
}

class _ShopDetailsState extends State<ShopDetails> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.shopDetailsModel.shopName,
          style: TextStyle(
              color: myTheme.primaryColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
        iconTheme: IconThemeData(color: myTheme.primaryColor),
      ),
      body: Padding(
          padding: const EdgeInsets.only(right: 20.0, left: 20.0),
          child: StreamBuilder(
            stream: Firestore.instance
                .collection('shop')
                .document(widget.shopDetailsModel.shopName)
                .collection('items')
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Error Catched !",
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                );
              }
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Center(child: CircularProgressIndicator());
                default:
                  return ListView(
                    children:
                        snapshot.data.documents.map((DocumentSnapshot doc) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                        child: Card(
                          elevation: 8.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0)),
                          child: Container(
                            margin: const EdgeInsets.all(10.0),
                            child: Column(children: <Widget>[
                              ClipRRect(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15.0),
                                    topRight: Radius.circular(15.0)),
                                child: Image.network(
                                  doc.data['image'],
                                  height: 250,
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Container(
                                margin: const EdgeInsets.all(10.0),
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            doc.documentID,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18.0),
                                          ),
                                        ),
                                        doc.data['pcs'] > 0
                                            ? Text(
                                                "PCS : ${doc.data['pcs'].round()}",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            : Text(
                                                "OUT OF STOCK",
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          "₹ ${doc.data['price']}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18.0),
                                        ),
                                        MaterialButton(
                                          color: myTheme.primaryColor,
                                          textColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(25.0)),
                                          onPressed: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ShopOrder(
                                                        shopOrderModel: ShopOrderModel(
                                                            shopId: widget
                                                                .shopDetailsModel
                                                                .shopId,
                                                            itemData: doc.data,
                                                            shopName: widget
                                                                .shopDetailsModel
                                                                .shopName,
                                                            shopToken: widget
                                                                .shopDetailsModel
                                                                .token),
                                                      ))),
                                          child: Text(
                                            "Order Now",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.0),
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ]),
                          ),
                        ),
                      );
                    }).toList(),
                  );
              }
            },
          )),
    );
  }
}
