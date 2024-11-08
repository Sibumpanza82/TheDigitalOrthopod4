import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class AdapterState extends StatelessWidget {

  final BluetoothAdapterState? adapterState;

  const AdapterState({
    super.key,
     required this.adapterState,
  });

  @override
  Widget build(BuildContext context) {
    String? state = adapterState?.toString().split(".").last;
    return Text('Bluetooth Adapter is  ${state != null ? state : 'not available'}',
      style: TextStyle(color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
