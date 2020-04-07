import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final String lebel;
  final IconData icon;
  final Function onPressed;
  final double height;
  final double width;
  final BorderRadius borderRadius;
  final Color color;

  SocialLoginButton(
      {@required this.onPressed,
      @required this.lebel,
      @required this.icon,
      this.height,
      this.width,
      this.borderRadius,
      this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Center(
        child: Container(
          alignment: Alignment.center,
            height: height,
            width: width,
            decoration: BoxDecoration(color: color, borderRadius: borderRadius, boxShadow: [
              BoxShadow(blurRadius: 6.0, offset: Offset(10.0, 10.0), spreadRadius: 2.0, color: Colors.black26)
            ]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left:15.0),
                  child: Icon(icon, color: Colors.white,),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Center(
                  child: Text(
                    lebel,
                    style: TextStyle(fontSize: 18.0, fontFamily: 'Raleway', color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
