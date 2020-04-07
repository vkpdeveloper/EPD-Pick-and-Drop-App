import 'dart:async';
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:epd_pick/customer/allOrders.dart';
import 'package:epd_pick/customer/customerdroppackage.dart';
import 'package:epd_pick/customer/shopcustomer.dart';
import 'package:epd_pick/customer/tiffinpackagecustomer.dart';
import 'package:epd_pick/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:epd_pick/customer/customerprofile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

var myTheme = MyTheme();

class CustomerHome extends StatefulWidget {
  @override
  _CustomerHomeState createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  @override
  void initState() {
    super.initState();
    _profileImage = noImage;
    getMyCurrentLocation();
    getUserData();
    _bottomCurrent = 0;
    locationSubscripation =
        location.onLocationChanged().listen((LocationData results) {
      setState(() {
        lat = results.latitude;
        long = results.longitude;
        getCurrentAddress();
      });
    });
    userId = "";
  }

  Location location = Location();
  String myCurrentLocation = "";
  double lat, long;
  String apiKey = "AIzaSyBEU9qa9svA6IwvHc5SmOqg0zoplSczGzM";

  StreamSubscription<LocationData> locationSubscripation;

  getMyCurrentLocation() {
    var pos = location.getLocation();
    pos.then((onValue) {
      setState(() {
        lat = onValue.latitude;
        long = onValue.longitude;
      });
      getCurrentAddress();
    }).catchError((e) {
      Fluttertoast.showToast(
        msg: "Error : ${e.toString}",
        backgroundColor: Colors.red,
        textColor: Colors.white,
        gravity: ToastGravity.BOTTOM,
      );
    });
  }

  var userId;
  var _firestore = Firestore.instance.collection('users');
  var _profileImage;
  var noImage = "https://cdn.browshot.com/static/images/not-found.png";

  getUserData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    userId = preferences.getString("userid");
    _firestore.document(userId).get().then((data) {
      setState(() {
        _profileImage = data.data['profile'];
      });
    }).catchError((e) {
      setState(() {
        _profileImage = noImage;
      });
    });
  }

  getCurrentAddress() async {
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$long&key=$apiKey";
    Response res = await http.get(url);
    if (res.statusCode == 200) {
      var data = jsonDecode(res.body);
      for (var i in data['results']) {
        setState(() {
          myCurrentLocation = i['formatted_address'].toString();
        });
        break;
      }
    } else {
      setState(() {
        myCurrentLocation = "Error in getting address !";
      });
    }
  }

  List images = ['0.jpg', '1.jpg', '2.jpg'];
  int _current;
  int _bottomCurrent;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => AllOrders())),
          tooltip: "Show all orders",
          elevation: 12.0,
          label: Text(
            "All Orders",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          icon: Icon(Feather.shopping_bag),
          backgroundColor: myTheme.primaryColor,
          foregroundColor: Colors.white,
          hoverElevation: 15.0,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          notchMargin: 300.0,
          color: Colors.white,
          elevation: 8.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                tooltip: "Home",
                onPressed: () {},
                icon: Icon(Feather.home),
                iconSize: 30.0,
                color: myTheme.primaryColor,
              ),
              IconButton(
                tooltip: "Refer User",
                onPressed: () {},
                icon: Icon(SimpleLineIcons.people),
                iconSize: 25.0,
                color: myTheme.primaryColor,
              )
            ],
          ),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(color: Colors.white),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Text(
                              "EDP Pick",
                              style: TextStyle(
                                  color: myTheme.primaryColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 25.0,
                                  fontFamily: 'Raleway'),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CustomerProfile())),
                          child: Hero(
                            tag: "profile",
                            child: CircleAvatar(
                              backgroundImage: NetworkImage('$_profileImage'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15.0, top: 3.0),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Octicons.location,
                          size: 20.0,
                          color: myTheme.primaryColor,
                          semanticLabel: "Current Location",
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                        Flexible(
                          flex: 1,
                          fit: FlexFit.loose,
                          child: Text(
                            myCurrentLocation,
                            style: TextStyle(fontSize: 16.0),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: CarouselSlider(
                    height: 160.0,
                    enlargeCenterPage: true,
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 2),
                    initialPage: 0,
                    onPageChanged: (index) => setState(() => _current = index),
                    items: images.map((image) {
                      return Builder(builder: (BuildContext context) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(35.0),
                          child: Container(
                            decoration: BoxDecoration(
                                color: myTheme.primaryColor,
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 10.0,
                                      spreadRadius: 2.0,
                                      offset: Offset(10.0, 10.0)),
                                ]),
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Image.asset(
                              'asset/images/$image',
                              fit: BoxFit.fill,
                            ),
                          ),
                        );
                      });
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25.0),
                    child: Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width - 20,
                      height: MediaQuery.of(context).size.height - 400,
                      decoration: BoxDecoration(color: myTheme.primaryColor),
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CustomerTiffinPackage()));
                                  },
                                  child: Card(
                                    elevation: 5.0,
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Container(
                                        height: 65,
                                        width: 90,
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              IconButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              CustomerTiffinPackage()));
                                                },
                                                icon: Icon(Entypo.box),
                                                iconSize: 30.0,
                                              ),
                                              Text(
                                                "Tiffin",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: myTheme.primaryColor,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              CustomerDropPackage())),
                                  child: Card(
                                    elevation: 5.0,
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Container(
                                        height: 65,
                                        width: 90,
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              IconButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              CustomerDropPackage()));
                                                },
                                                icon: Icon(Feather.box),
                                                iconSize: 30.0,
                                              ),
                                              Text(
                                                "Other",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: myTheme.primaryColor,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              CustomerShop())),
                                  child: Card(
                                    elevation: 5.0,
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Container(
                                        height: 65,
                                        width: 90,
                                        child: Column(
                                          children: <Widget>[
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                IconButton(
                                                  onPressed: () => Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              CustomerShop())),
                                                  icon: Icon(
                                                      MaterialCommunityIcons
                                                          .shopping),
                                                  iconSize: 30.0,
                                                ),
                                                Text(
                                                  "Shops",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color:
                                                          myTheme.primaryColor,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    print("I am Service Query !");
                                  },
                                  child: Card(
                                    elevation: 5.0,
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Container(
                                        height: 65,
                                        width: 90,
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              IconButton(
                                                onPressed: () => launch(
                                                    "tel: +918318045008"),
                                                icon: Icon(
                                                    AntDesign.customerservice),
                                                iconSize: 30.0,
                                              ),
                                              Text(
                                                "Help !",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: myTheme.primaryColor,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
