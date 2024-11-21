import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AppQR extends StatefulWidget {
  const AppQR({Key? key}) : super(key: key);

  @override
  State<AppQR> createState() => _AppQRState();
}

class _AppQRState extends State<AppQR> {
  final String data = "https://www.example.com"; // The data you want to encode

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Generator'),
      ),
      body: Center(
        child: QrImageView(
          data: data,
          version: QrVersions.auto,
          size: 200.0, // Size of the QR code
          gapless: false,
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AppQR(),
  ));
}
