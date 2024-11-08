import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ankleromapp/pages/bluetooth_off_screen.dart';
import 'package:ankleromapp/pages/bluetooth_screen.dart';
import 'package:ankleromapp/pages/adapter_state.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

//This widget shows BluetoothOffScreen or ScanScreen depending on the adapter State
class Flutterblueappstate extends StatefulWidget {
  const Flutterblueappstate({super.key});

  @override
  State<Flutterblueappstate> createState() => _FlutterblueappstateState();
}

class _FlutterblueappstateState extends State<Flutterblueappstate> {
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;

  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;

  @override
  void initState(){
    super.initState();
    _adapterStateStateSubscription = FlutterBluePlus.adapterState.listen((state){
      _adapterState = state;
      if (mounted){
        setState(() {

        });
      }
    });
  }

  @override
  void dispose() {
    _adapterStateStateSubscription.cancel();
    super.dispose();
  }

  Widget build(BuildContext context) {
    Widget screen = _adapterState == BluetoothAdapterState.on
        ? const BluetoothScreen()
        : BluetoothOffScreen(adapterState: _adapterState,);

    return MaterialApp(
      home: screen,
      color: Colors.lightGreen,
      navigatorObservers: [BluetoothAdapterStateObserver()],
    );
  }
}

//This observer listens for Bluetooth Off and dismisses the Current screen
class BluetoothAdapterStateObserver extends NavigatorObserver {
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;

  @override
  void didPush(Route route, Route? previousRoute){
    super.didPush(route, previousRoute);
    if (route.settings.name == '/DeviceScreen'){
      //start listening to bluetooth state changes when a new route is pushed
      _adapterStateSubscription ??= FlutterBluePlus.adapterState.listen((state){
        if (state != BluetoothAdapterState.on){
          navigator?.pop();
        }
      });
    }
  }

  @override
  void didPop(Route route, Route? previousRoute){
    super.didPop(route, previousRoute);
    //Cancel the subscription when the route is popped
    _adapterStateSubscription?.cancel();
    _adapterStateSubscription = null;
  }

}
