import 'dart:io';
import 'package:ankleromapp/pages/adapter_state.dart';
import 'package:flutter/material.dart';
import 'package:ankleromapp/pages/progress.dart';
import 'package:ankleromapp/pages/home_page.dart';
import 'package:ankleromapp/util/my_button.dart';
import 'package:ankleromapp/pages/flutterBlueAppState.dart';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothOffScreen extends StatefulWidget {

  final BluetoothAdapterState? adapterState;
  const BluetoothOffScreen({
    super.key,
    required this.adapterState
  });


  @override
  State<BluetoothOffScreen> createState() => _BluetoothOffScreenState();
}

class _BluetoothOffScreenState extends State<BluetoothOffScreen> {

  //Wrong email message popup
  void showErrorMessage(String message){
    showDialog(context: context, builder: (context) {
      return AlertDialog(
          backgroundColor: Colors.black,
          title: Center(
            child: Text(message,
              style: const TextStyle(color: Colors.white),
            ),
          )
      );
    },
    );
  }

  void TurnOnAdapter() async{
    //Function to turn on BT adapter.
    //show loading circle
   // showDialog(context: context, builder: (context) {
   //   return const Center(
   //     child: CircularProgressIndicator(),
   //   );
   // },);

    try {
      if (Platform.isAndroid){
        await FlutterBluePlus.turnOn();
        //Pop the circle
     //   Navigator.pop(context);
      }

    }
    catch (e){
      //Pop the circle
    //  Navigator.pop(context);
      showErrorMessage("Error Turning On:" + e.toString());
    }
  }

  //Handle navigation based on selected index

  void onNavItemTapped(int index) {
    switch (index) {
      case 0:
      //Do nothing, Already here
        break;
      case 1:
      //Navigate to Bluetooth Page
        Navigator.push(context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        break;

      case 2:
        Navigator.push(
          context, MaterialPageRoute(builder: (context) => Progress()),
        );
        break;
    }
  }

  Widget buildTitle(BuildContext context) {
    String? state = widget.adapterState
        ?.toString()
        .split(".")
        .last;
    return Text('Bluetooth Adapter is ${state != null ? state : 'not available'}',
      style: TextStyle(color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen.shade700,
      bottomNavigationBar: BottomNavigationBar(items: [
        // BottomNavigationBarItem(icon: Icon(Icons.history), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.bluetooth), label: 'Device'),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Progress'),
      ],
        selectedItemColor: Colors.lightGreen[700],
        currentIndex: 0,
        onTap: onNavItemTapped,
      ),
      body: SafeArea(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: const Icon(
                Icons.bluetooth_disabled,
                size: 200.0,
                color: Colors.white),
          ),
          const SizedBox(height: 20,
          ),

      buildTitle(context),

          const SizedBox(height: 25,),

          //Turn on Bluetooth Button
          MyButton(onTap:  TurnOnAdapter, text: 'Turn On',),
        ],
      ),
      ),

    );
  }

}
