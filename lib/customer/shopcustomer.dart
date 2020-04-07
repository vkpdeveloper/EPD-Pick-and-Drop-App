import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:epd_pick/agent/agentforgetpassword.dart';
import 'package:epd_pick/customer/shopdetails.dart';
import 'package:epd_pick/models/shopdetailsmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerShop extends StatefulWidget {
  @override
  _CustomerShopState createState() => _CustomerShopState();
}

class _CustomerShopState extends State<CustomerShop> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: myTheme.primaryColor),
        elevation: 0.0,
        backgroundColor: Colors.white,
        title: Text(
          "All Shops",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: myTheme.primaryColor),
        ),
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection('shop').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError)
            return Center(child: new Text('Error: ${snapshot.error}'));
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return new Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(myTheme.primaryColor),
                ),
              );
            default:
              return Padding(
                padding:
                    const EdgeInsets.only(top: 8.0, right: 20.0, left: 20.0),
                child: new ListView(
                  children:
                      snapshot.data.documents.map((DocumentSnapshot document) {
                    return GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ShopDetails(
                                    shopDetailsModel: ShopDetailsModel(
                                      shopName: document.documentID,
                                      shopId: document.data['shopId'],
                                      token: document.data['shopToken']
                                    ),
                                  ))),
                      child: Hero(
                        tag: "shop",
                        child: new Card(
                          elevation: 8.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0)),
                          child: Container(
                            child: Column(
                              children: <Widget>[
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15.0),
                                      topRight: Radius.circular(15.0)),
                                  child: Image.network(
                                    document.data['image'],
                                    height: 250,
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.all(15.0),
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Column(
                                            children: <Widget>[
                                              Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Text(
                                                      document.data['shopName'],
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 20.0))),
                                              SizedBox(
                                                height: 10.0,
                                              ),
                                              Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Text(
                                                      document
                                                          .data['ownerName'],
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 20.0)))
                                            ],
                                          ),
                                          IconButton(
                                            icon: Icon(Feather.phone_call),
                                            color: myTheme.primaryColor,
                                            iconSize: 25,
                                            onPressed: () => launch(
                                                "tel: ${document.data['mobile']}"),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      Align(
                                          alignment: Alignment.bottomRight,
                                          child: Text(
                                            "Category : ${document['category']}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.0),
                                          ))
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
          }
        },
      ),
    );
  }
}
