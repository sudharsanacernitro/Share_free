import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import './downloader/download_ui.dart';

class QRCodeScannerPage extends StatefulWidget {
  @override
  _QRCodeScannerPageState createState() => _QRCodeScannerPageState();
}

class _QRCodeScannerPageState extends State<QRCodeScannerPage> {
  String result = "Scan a QR code";
  bool isScanning = true;
  MobileScannerController scannerController = MobileScannerController();

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Share_Free'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: MobileScanner(
              controller: scannerController,
              onDetect: (BarcodeCapture capture) {
                final List<Barcode> barcodes = capture.barcodes;

                // If a QR code is detected and we are still scanning
                if (barcodes.isNotEmpty && isScanning) {
                  final String? code = barcodes.first.rawValue;
                  setState(() {
                    result = code ?? "Failed to scan QR code";
                    isScanning = false; // Stop further scanning
                  });

                  if (code != null) {
                    // Stop the scanner and navigate to the download UI
                    scannerController.stop();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Download_ui(url: result),
                      ),
                    );
                  }
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                result,
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
