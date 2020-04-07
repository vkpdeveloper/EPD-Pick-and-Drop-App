import 'package:epd_pick/customer/config.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission/permission.dart';
import '../main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AgentMap extends StatefulWidget {
  final orderId;

  const AgentMap({Key key, this.orderId}) : super(key: key);
  @override
  _AgentMapState createState() => _AgentMapState();
}

class _AgentMapState extends State<AgentMap> {
  List<Marker> _markers;
  GoogleMapController _googleMapController;
  double pickLat, pickLon, dropLat, dropLon;

  @override
  void initState() {
    getOrderDetail();
    super.initState();
  }

  getOrderDetail() async {
    var permission =
        await Permission.getPermissionsStatus([PermissionName.Location]);
    if (permission[0].permissionStatus == PermissionStatus.notAgain) {
      var askPermission =
          await Permission.requestPermissions([PermissionName.Location]);
    } else {
      var _firestore = Firestore.instance.collection('allOrders');
      _firestore.document(widget.orderId).get().then((order) {
        setState(() {
          pickLat = order.data['pickFrom'][0];
          pickLon = order.data['pickFrom'][1];
          dropLat = order.data['dropAt'][0];
          dropLon = order.data['dropAt'][1];
        });
      });
      setState(() {
        _markers.add(Marker(
            markerId: MarkerId('pickMarker'),
            position: LatLng(pickLat, pickLon),
            visible: true,
            infoWindow: InfoWindow(
                title: "Pick up Point",
                snippet: "This is the pick point of that order"),
            draggable: false));
        _markers.add(Marker(
            markerId: MarkerId('dropMarker'),
            position: LatLng(dropLat, dropLon),
            visible: true,
            infoWindow: InfoWindow(
                title: "Pick up Point",
                snippet: "This is the pick point of that order"),
            draggable: false));
      });
    }
  }

  List<LatLng> pickDropCoords;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: myTheme.primaryColor,
        title: Text(
          "Order Map View",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: GoogleMap(
          buildingsEnabled: true, // New Added
          trafficEnabled: true, // New Added
          compassEnabled: true, // New Added
          myLocationEnabled: true, // New Added
          mapToolbarEnabled: true, // New Added
          myLocationButtonEnabled: true, // New Added
          markers: Set.from(_markers),
          onMapCreated: (GoogleMapController _cont) {
            setState(() {
              _googleMapController = _cont;
            });
          },
          initialCameraPosition: CameraPosition(
            target: LatLng(pickLat, pickLon),
            zoom: 16.0,
          ),
          mapType: MapType.normal,
        ),
      ),
    );
  }
}
