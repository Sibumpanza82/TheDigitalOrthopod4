import 'package:flutter/material.dart';
import 'package:ankleromapp/pages/bluetooth_off_screen.dart';
import 'package:ankleromapp/pages/home_page.dart';
import 'flutterBlueAppState.dart';

class Progress extends StatefulWidget {
  const Progress({super.key});



  @override
  State<Progress> createState() => _ProgressState();
}

class _ProgressState extends State<Progress> {
  //Handle navigation based on selected index
  void onNavItemTapped(int index){
    switch(index){
      case 0:
      //Navigate to Bluetooth Page
        Navigator.push(context,
          MaterialPageRoute(builder: (context)=> Flutterblueappstate()),
        );
        break;
      case 1:
      //Navigate to Bluetooth Page
        Navigator.push(context,
          MaterialPageRoute(builder: (context)=> HomePage()),
        );
        break;

      case 2:
        //No nothing
        break;
    }
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
        currentIndex: 2,
        onTap: onNavItemTapped,
      ),
    );
  }
}
