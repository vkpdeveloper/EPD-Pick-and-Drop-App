import 'package:flutter/material.dart';

class GenerateQRCode extends StatelessWidget {
  final String data;
  final double height;
  final double width;
  final String backgroundColor;

  const GenerateQRCode(
      {Key key,
      @required this.data,
      this.height = 150,
      this.width = 150,
      this.backgroundColor})
      : super(key: key);

  getQRCode() {
    String imageUrl;
    if (backgroundColor != null) {
      imageUrl =
          "https://api.qrserver.com/v1/create-qr-code/?size=${height.toString()}x${width.toString()}&data=${data}&bgcolor=${backgroundColor}";
    }else{
      imageUrl =
          "https://api.qrserver.com/v1/create-qr-code/?size=${height}x${width}&data=${data}";
    }
    return imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Image(
      image: NetworkImage(getQRCode()),
    );
  }
}
