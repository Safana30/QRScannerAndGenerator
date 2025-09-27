import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as ms;
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart'
as mlkit;



class ScanQrCode extends StatefulWidget {
  const ScanQrCode({super.key});

  @override
  State<ScanQrCode> createState() => _ScanQrCodeState();
}

class _ScanQrCodeState extends State<ScanQrCode> {
  String qrResult = "Scanned Data will appear here";

  ms.MobileScannerController cameraController = ms.MobileScannerController(
    torchEnabled: false, // Initialize with flashlight off
  );
  bool _isTorchOn = false;


  @override
  void dispose() {
    cameraController.dispose(); // Clean up the controller
    super.dispose();
  }

  // Function to pick and scan QR code from gallery
  Future<void> scanFromGallery() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    final inputImage = mlkit.InputImage.fromFilePath(image.path);
    final barcodeScanner = mlkit.BarcodeScanner();

    final List<mlkit.Barcode> barcodes = await barcodeScanner.processImage(inputImage);

    if (barcodes.isNotEmpty) {
      setState(() {
        qrResult = barcodes.first.rawValue ?? "No data";
      });
    } else {
      setState(() {
        qrResult = "No QR code found in image";
      });
    }

    barcodeScanner.close();
  }
  //Future<void> means the function
  // will complete in the future,
  // but it won’t return any value.
  //async tells Dart this function involves asynchronous work.
  // await pauses execution until the task (like Future.delayed) finishes.

  void switchFlashLight() async {
    try {
      await cameraController.toggleTorch();
      setState(() {
        _isTorchOn = !_isTorchOn;
        qrResult = _isTorchOn ? "Flashlight ON" : "Flashlight OFF";
      });
    } catch (e) {
      setState(() {
        qrResult = "Error toggling flashlight: Flashlight may not be available";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("QR Code Scanner")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            // Camera view for scanning
            SizedBox(
              height: 300, // Adjust height as needed
              child:  ms.MobileScanner(
                controller: cameraController,
                onDetect: (ms.BarcodeCapture capture) async {
                  if (!mounted) return;
                  final List<ms.Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    final String? qrCode = barcode.rawValue;
                    if (qrCode != null) {
                      await cameraController.stop(); // Stop scanning
                      if (!mounted) return;
                      setState(() {
                        qrResult = qrCode;
                      });
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('QR Code'),
                          content: Text(qrCode),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                cameraController.start();
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                      break;
                    }
                  }
                },
              ),
            ),
            const SizedBox(height: 30),
            Text(qrResult, style: const TextStyle(color: Colors.black)),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    cameraController.stop();
                    cameraController.start(); // Restart camera scanning
                  },
                  child: const Text("Scan with Camera"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: scanFromGallery, // New button for gallery scanning
                  child: const Text("Scan from Gallery"),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
