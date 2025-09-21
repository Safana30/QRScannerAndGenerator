import 'package:first_flutter_app/generate_qr_code.dart';
import 'package:first_flutter_app/scan_qr_code.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Code Scanner ',
      debugShowCheckedModeBanner: false,
      //it will disable the debug banner from top right corner
      home: HomePage(),
    );
  }
}

//A Stateful Widget has two parts:
// the widget (HomePage) and its state (_HomePageState).
//Use it when the UI needs to change,
// like when handling user input or dynamic data.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("QR Code Scanner"),
        backgroundColor: Colors.lightBlue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (context) => ScanQrCode()));
                //  MaterialPageRoute -> includes a smooth animation
                }); // its same like mutableStateOf in jetpack compose
              },
              child: Text("Scan"),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => GenerateQrCode()),
                  );
                });
              },
              child: Text("Generate QR Code"),
            ),
          ],
        ),
      ),
    );
  }
}
