import 'package:epd_pick/agent/agentprofile.dart';
import 'package:epd_pick/agent/droppackageagent.dart';
import 'package:epd_pick/agent/tiffinserviceagent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class AgentHome extends StatefulWidget {
  @override
  _AgentHomeState createState() => _AgentHomeState();
}

class _AgentHomeState extends State<AgentHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Feather.user),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => AgentProfile())),
            color: Colors.white,
          )
        ],
        automaticallyImplyLeading: false,
        title: Text(
          "Agent Home",
          style: TextStyle(fontFamily: 'Raleway', color: Colors.white),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 140.0,
                  width: MediaQuery.of(context).size.width - 20,
                  child: Card(
                    elevation: 8.0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Feather.box,
                            size: 50.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FlatButton(
                              hoverColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            TiffinServiceAgent()));
                              },
                              child: Text(
                                "Tiffin Service",
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 22.0),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 140.0,
                  width: MediaQuery.of(context).size.width - 20,
                  child: Card(
                    elevation: 8.0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Feather.box,
                            size: 50.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FlatButton(
                              hoverColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            DropServiceAgent()));
                              },
                              child: Text(
                                "Drop Package",
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 22.0),
                              ),
                            ),
                          )
                        ],
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
