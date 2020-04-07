import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:epd_pick/agent/agentforgetpassword.dart';
import 'package:epd_pick/customer/allOrders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackOrder extends StatefulWidget {
  final orderId;

  const TrackOrder({Key key, @required this.orderId}) : super(key: key);
  @override
  _TrackOrderState createState() => _TrackOrderState();
}

class _TrackOrderState extends State<TrackOrder> {
  void initState() {
    getOrderDetails();
    BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5),
            'assets/images/scooter.png')
        .then((onValue) {
      liveLocation = onValue;
    });
    super.initState();
  }

  showNoOrderDialog() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            actions: <Widget>[
              FlatButton(
                splashColor: Colors.transparent,
                onPressed: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => AllOrders())),
                color: Colors.transparent,
                textColor: myTheme.primaryColor,
                child: Text(
                  "Ok",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                ),
              )
            ],
            title: Text(
              "Note",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0)),
            titlePadding: const EdgeInsets.all(15.0),
            contentPadding: const EdgeInsets.all(8.0),
            content: Text(
              "Order placed is not started by agent so wait for notification.",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        });
  }

  var orderId;
  var agentId;
  double dropLat, dropLon, liveLat, liveLon;
  double lastLat, lastLon;
  BitmapDescriptor liveLocation;

  showLiveLocation(LatLng latLng) {
    _markers.add(
      Marker(
        markerId: MarkerId(latLng.toString()),
        position: latLng,
        draggable: false,
        infoWindow: InfoWindow(
            title: "Live Order Location",
            snippet: "Dear customer your order is live at this place."),
        icon: liveLocation,
        visible: true,
      ),
    );
  }

  getOrderDetails() {
    var _firestore = Firestore.instance
        .collection("allOrders")
        .document(widget.orderId)
        .get();
    _firestore.then((data) {
      setState(() {
        orderId = data.data['orderId'];
        agentId = data.data['agentId'];
        dropLat = data.data['dropAt'][0];
        dropLon = data.data['dropAt'][1];
        if (data.data['liveAt'] != null) {
          liveLat = data.data['liveAt'][0];
          liveLon = data.data['liveAt'][1];
          showLiveLocation(LatLng(liveLat, liveLon));
        } else {
          showNoOrderDialog();
        }
      });
    });
  }

  showNewLiveLocation(LatLng latLng) {}

  List<Marker> _markers = [];

  GoogleMapController _googleMapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: myTheme.primaryColor,
        title: Text(
          "Track you Order",
          style: TextStyle(color: Colors.white),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => showNewLiveLocation(LatLng(lastLat, lastLon)),
          elevation: 8.0,
          child: Icon(MaterialCommunityIcons.refresh),
          backgroundColor: myTheme.primaryColor,
          foregroundColor: Colors.white),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: GoogleMap(
          buildingsEnabled: true,
          trafficEnabled: true,
          compassEnabled: true,
          myLocationEnabled: true,
          mapToolbarEnabled: true,
          myLocationButtonEnabled: true,
          markers: Set.from(_markers),
          onMapCreated: (GoogleMapController _cont) {
            _googleMapController = _cont;
          },
          initialCameraPosition: CameraPosition(
            target: LatLng(dropLat, dropLon),
            zoom: 16.0,
          ),
          mapType: MapType.normal,
        ),
      ),
    );
  }
}
