import 'dart:io';
import 'package:flutter/material.dart';
import './send/sender.dart';
import './receive/qr_scanner.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Share_Free',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: _Base(),
    );
  }
}

class _Base extends StatefulWidget {
  const _Base({super.key});

  @override
  State<_Base> createState() => __BaseState();
}

class __BaseState extends State<_Base> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: Text("Share_Free",style: TextStyle(color: Colors.white),),
      backgroundColor: (const Color.fromARGB(255, 77, 74, 74)),
      centerTitle: true,),
      body:SingleChildScrollView(
        child: Center(
          child:  Column(children:[
              SizedBox(height: 20,),

              InkWell(
                onTap: () => {
                  print("send"),
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FileHostingPage()),
                  )
                },
                child: Container(
                  width:.9*screenWidth,
                  height: .4*screenHeight,
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                  boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5), // Shadow color with opacity
                        spreadRadius: 5,                     // How far the shadow spreads
                        blurRadius: 7,                       // The blur intensity
                        offset: Offset(0, 3),                // Offset of the shadow (x, y)
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                  children: [Image.asset('assets/upload.png',width: 200),
                  SizedBox(height: 10,)
                  ,Text("send",style: TextStyle(fontSize:26,fontWeight: FontWeight.bold),)],
                ) 
                ),
              ),
        
              SizedBox(height: 15,),

              InkWell(
                onTap: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => QRCodeScannerPage()),
                  ),
                  print("Received")
                },
                child: Container(
                  width:.9*screenWidth,
                  height: .4*screenHeight,
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5), // Shadow color with opacity
                      spreadRadius: 5,                     // How far the shadow spreads
                      blurRadius: 7,                       // The blur intensity
                      offset: Offset(0, 3),                // Offset of the shadow (x, y)
                      ),
                    ],
                  ),
                  child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                  children: [Image.asset('assets/download.png',width: 200,),SizedBox(height: 10,),Text("Receive",style: TextStyle(fontSize:26,fontWeight: FontWeight.bold),)],
                ) 
                ),
              ),
              
            ]),
          ),
        ),
    );
  }
}