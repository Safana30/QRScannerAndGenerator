import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQrCode extends StatefulWidget {
  const ScanQrCode({super.key});

  @override
  State<ScanQrCode> createState() => _ScanQrCodeState();
}

class _ScanQrCodeState extends State<ScanQrCode> {
  String qrResult = "Scanned Data will appear here";

  MobileScannerController cameraController = MobileScannerController();

  @override
  void dispose() {
    cameraController.dispose(); // Clean up the controller
    super.dispose();
  }

  // Function to pick and scan QR code from gallery
  Future<void> scanFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) {
        if (!mounted) return;
        setState(() {
          qrResult = "No image selected";
        });
        return;
      }

      // Show dialog to preview the image
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Image.file(File(image.path), height: 200),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancel scanning
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close preview dialog
                // Scan the image for QR code
                final BarcodeCapture? result = await cameraController.analyzeImage(image.path);
                if (!mounted) return;
                if (result != null && result.barcodes.isNotEmpty) {
                  final String? qrCode = result.barcodes.first.rawValue;
                  if (qrCode != null) {
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
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    setState(() {
                      qrResult = "No QR code found in image";
                    });
                  }
                } else {
                  setState(() {
                    qrResult = "No QR code found in image";
                  });
                }
              },
              child: const Text('Scan'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        qrResult = "Error: $e";
      });
    }
  }
  //Future<void> means the function
  // will complete in the future,
  // but it won’t return any value.
  //async tells Dart this function involves asynchronous work.
  // await pauses execution until the task (like Future.delayed) finishes.
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
              child: MobileScanner(
                controller: cameraController,
                onDetect: (BarcodeCapture capture) async {
                  if (!mounted) return;
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    final String? qrCode = barcode.rawValue;
                    if (qrCode != null) {
                      await cameraController.stop(); // Stop scanning
                      if (!mounted) return;
                      setState(() {
                        qrResult = qrCode; // Update result
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
                                cameraController.start(); // Resume scanning
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                      break; // Stop after first valid QR code
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
                    cameraController.start(); // Restart camera scanning
                  },
                  child: const Text("Scan with Camera"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: scanFromGallery, // New button for gallery scanning
                  child: const Text("Scan from Gallery"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}