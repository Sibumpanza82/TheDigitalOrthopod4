import 'dart:async';

import 'package:ankleromapp/pages/device_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:ankleromapp/pages/progress.dart';
import 'package:ankleromapp/pages/home_page.dart';

import 'package:ankleromapp/util/scan_results_tile.dart';
import 'package:ankleromapp/util/extra.dart';
import 'package:ankleromapp/util/system_device_tile.dart';


class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});



  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
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

  //scan screen stuff
  List<BluetoothDevice> _systemDevices = [];
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;

  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  //Handle navigation based on selected index
  void onNavItemTapped(int index){
    switch(index){
      case 0:
        //Do nothing, Already here
        break;
      case 1:
      //Navigate to Bluetooth Page
        Navigator.push(context,
          MaterialPageRoute(builder: (context)=> HomePage()),
        );
        break;

      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (context)=> Progress()),
        );
        break;
    }
  }

  @override
  void initState(){
    super.initState();
    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results){
      _scanResults = results;
      if (mounted){
        setState(() {});
      }
    }, onError: (e){
      showErrorMessage("Scan Error: "+ e.toString());
    });

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state){
      _isScanning = state;
      if (mounted){
        setState(() {});
      }
    });
  }

  @override
  void dispose(){
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    super.dispose();
  }

  Future onScanPressed() async {
    try {
      // `withServices` is required on iOS for privacy purposes, ignored on android.
      var withServices = [Guid("180f")]; // Battery Level Service
      _systemDevices = await FlutterBluePlus.systemDevices(withServices);
    } catch (e) {
      showErrorMessage("System Devices Error: "+e.toString());
    }
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    } catch (e) {
      showErrorMessage("Start Scan Error: "+e.toString());
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future onStopPressed() async {
    try {
      FlutterBluePlus.stopScan();
    } catch (e) {
      showErrorMessage("Stop Scan Error: "+e.toString());
    }
  }

  void onConnectPressed(BluetoothDevice device){
    device.connectAndUpdateStream().catchError((e){
      showErrorMessage("Connect Error: "+e.toString());
    });
    MaterialPageRoute route = MaterialPageRoute(builder:(context) => DeviceScreen(device: device),
    settings: RouteSettings(name:'/DeviceScreen'));
    Navigator.of(context).push(route);
  }

  Future onRefresh(){
    if (_isScanning == false){
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    }
    if (mounted){
      setState(() {});
    }
    return Future.delayed(Duration(milliseconds: 500));
  }

  Widget buildScanButton(BuildContext context) {
    if (FlutterBluePlus.isScanningNow) {
      return FloatingActionButton(
        child: const Icon(Icons.stop, color: Colors.white,),
        onPressed: onStopPressed,
        backgroundColor: Colors.lightGreen,
      );
    } else {
      return FloatingActionButton(child:  const Text("Scan",
      style: TextStyle(color: Colors.white),), onPressed: onScanPressed,
        backgroundColor: Colors.lightGreen,);
    }
  }

  List<Widget> _buildSystemDeviceTiles(BuildContext context) {
    return _systemDevices
        .map(
          (d) => SystemDeviceTile(
        device: d,
        onOpen: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DeviceScreen(device: d),
            settings: RouteSettings(name: '/DeviceScreen'),
          ),
        ),
        onConnect: () => onConnectPressed(d),
      ),
    )
        .toList();
  }

  List<Widget> _buildScanResultTiles(BuildContext context) {
    return _scanResults
        .map(
          (r) => ScanResultTile(
        result: r,
        onTap: () => onConnectPressed(r.device),
      ),
    )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
     // key: Snackbar.snackBarKeyB,
      child: Scaffold(
        appBar: AppBar(
          title:  Text('Find Nearby Devices',
            style: TextStyle(color: Colors.lightGreen[50],
            fontSize: 24,),
          ),
          backgroundColor: Colors.lightGreen.shade700,
        ),
        bottomNavigationBar: BottomNavigationBar(items: [
          BottomNavigationBarItem(icon: Icon(Icons.bluetooth), label: 'Device'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Progress'),
        ],
        selectedItemColor: Colors.lightGreen[700],
          currentIndex: 0,
          onTap: onNavItemTapped,
        ),
        body: RefreshIndicator(
          backgroundColor: Colors.grey[200],
          onRefresh: onRefresh,
          child: ListView(
            children: <Widget>[
              ..._buildSystemDeviceTiles(context),
              ..._buildScanResultTiles(context),
            ],
          ),
        ),
        floatingActionButton: buildScanButton(context),
      ),
    );
  }
}
