import 'package:flutter/material.dart';
import '../main.dart';
import 'package:epd_pick/customer/allOrders.dart';

class OrderConfirmation extends StatelessWidget {
  final String orderId;
  final String agentId;
  final String name;
  final String mobile;

  const OrderConfirmation(
      {Key key, this.orderId, this.agentId, this.name, this.mobile})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => AllOrders())),
          backgroundColor: myTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 8.0,
          hoverElevation: 22.0,
          label: Text(
            "All Orders",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image(
                    image: AssetImage('asset/images/orderconfirmation.png'),
                    alignment: Alignment.topCenter,
                    height: 220.0,
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Text(
                  "Order Placed Successfully",
                  style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold),
                ),
                ListTile(
                  title: Text(
                    "Order ID : ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    orderId,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  title: Text(
                    "Agent ID : ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    agentId,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  title: Text(
                    "Picker Name : ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  title: Text(
                    "Picker Mobile : ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    mobile,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
