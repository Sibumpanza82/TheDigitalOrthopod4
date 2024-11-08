import 'dart:async';
import 'package:ankleromapp/util/angles_ui.dart';
import 'package:ankleromapp/util/charts.dart';
import 'package:ankleromapp/util/dorsiflexion.dart';
import 'package:ankleromapp/util/extra.dart';
import 'package:ankleromapp/util/plantarflexion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:ankleromapp/pages/deviceStatus.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../util/characteristics_tile.dart';
import '../util/descriptor_tile.dart';
import '../util/pf_angles_ui.dart';
import '../util/service_tile.dart';
import 'dart:convert' show utf8;

class DeviceScreen extends StatefulWidget {
  final BluetoothDevice device;

  const DeviceScreen({
    super.key,
    required this.device,
  });

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  final String SERVICE_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String CHARACTERISTIC_UUID_TX = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  final String CHARACTERISTIC_UUID_RX = "beb5483e-36e1-4688-b7f5-ea07361b26a9";
  final String CHARACTERISTIC_UUID_STATUS = "beb5483e-36e1-4688-b7f5-ea07361b26a7";   //BLE UUID for the device status
  bool isReady = false;
  int _currentIndex = 0;
  BluetoothCharacteristic? statusCharacteristic;
  String status = "NOT CONNECTED";

  //Wrong email message popup
  void showErrorMessage(String message) {
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

  BluetoothConnectionState _connectionState = BluetoothConnectionState
      .disconnected;
  List<BluetoothService> _services = [];
  bool _isConnecting = false;
  bool _isDisconnecting = false;
  BluetoothCharacteristic? targetCharacteristic;

  late StreamSubscription<
      BluetoothConnectionState> _connectionStateSubscription;
  late StreamSubscription<bool> _isConnectingSubscription;
  late StreamSubscription<bool> _isDisconnectingSubscription;

  late Stream<List<int>> stream;
  late Stream<List<int>> status_stream;
  double _Plantarflexion = 0;
  double _Dorsiflexion = 0;

  String? lastStatus;   //Variable to store the last recieved status


  @override
  void initState() {
    super.initState();

    _connectionStateSubscription =
        widget.device.connectionState.listen((state) async {
          _connectionState = state;
          if (state == BluetoothConnectionState.connected) {
            _services = []; // must rediscover services
          }

          if (mounted) {
            setState(() {});
          }
        });

    _isConnectingSubscription = widget.device.isConnecting.listen((value) {
      _isConnecting = value;
      if (mounted) {
        setState(() {});
      }
    });

    _isDisconnectingSubscription =
        widget.device.isDisconnecting.listen((value) {
          _isDisconnecting = value;
          if (mounted) {
            setState(() {});
          }
        });
  }

  @override
  void dispose() {
    _connectionStateSubscription.cancel();
    _isConnectingSubscription.cancel();
    _isConnectingSubscription.cancel();
    _isDisconnectingSubscription.cancel();
    super.dispose();
  }

  bool get isConnected {
    return _connectionState == BluetoothConnectionState.connected;
  }

  _pop() {
    Navigator.of(context).pop(true);
  }

  disconnectFromDevice() {
    if (widget.device == null) {
      _pop();
      return;
    }
    showErrorMessage("Error: Disconnecting from device");
    widget.device.disconnect();
  }


  Future onConnectPressed() async {
    try {
      await widget.device.connectAndUpdateStream();
      showErrorMessage("Connection Sucessful!");

      new Timer(const Duration(seconds: 15), () {
        if (!isReady) {
          disconnectFromDevice();
          _pop();
        }
      });
    } catch (e) {
      if (e is FlutterBluePlusException &&
          e.code == FbpErrorCode.connectionCanceled.index) {
        // ignore connections canceled by the user
      } else {
        showErrorMessage("Connection Error: " + e.toString());
      }
    }
  }


  Future onCancelPressed() async {
    try {
      await widget.device.disconnectAndUpdateStream(queue: false);
      showErrorMessage("Cancel Successful");
    } catch (e) {
      showErrorMessage("Cancel Error: " + e.toString());
    }
  }

  Future onDisconnectPressed() async {
    try {
      await widget.device.disconnectAndUpdateStream();
      showErrorMessage("Disconnect Successful");
    } catch (e) {
      showErrorMessage("Disconnect Error Successful: " + e.toString());
    }
  }

  Future onDiscoverServicesPressed() async {
    if (widget.device == null) {
      //pop();
      return;
    }
    _services = await widget.device.discoverServices();
    _services.forEach((_services) {
      if (_services.uuid.toString() == SERVICE_UUID) {
        _services.characteristics.forEach((characteristic) {
          if (characteristic.uuid.toString() == CHARACTERISTIC_UUID_TX) {
            characteristic.setNotifyValue(!characteristic.isNotifying);
            targetCharacteristic = characteristic;
            stream = characteristic.value;

            setState(() {
              isReady = true;
            });
          }
        });
      }
    });

    if (!isReady) {
      _pop();
    }
  }

  Future<void> onStopNotificationsPressed() async {
    // Ensure targetCharacteristic is not null before accessing its properties
    if (targetCharacteristic == null) {
      // If there's no target characteristic, exit the method
      return;
    }

    // Check if the characteristic is currently notifying
    if (!targetCharacteristic!.isNotifying) {
      // If notifications are already stopped, exit the method
      return;
    }

    try {
      // Stop notifying for the characteristic
      await targetCharacteristic!.setNotifyValue(
          false); // Use ! to assert non-nullability
      // Optionally, clear the stream to stop listening to characteristic updates
      stream?.listen(
          null); // Stops listening to the characteristic's value stream

      setState(() {
        isReady =
        false; // Update the state to reflect that notifications are stopped
        targetCharacteristic =
        null; // Optionally reset the target characteristic
      });
    } catch (e) {
      // Handle any exceptions that might occur
      print("Error stopping notifications: $e");
    }
  }

  Widget buildSpinner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: CircularProgressIndicator(
          backgroundColor: Colors.black12,
          color: Colors.black26,
        ),
      ),
    );
  }

  Widget buildConnectButton(BuildContext context) {
    return Row(children: [
      if (_isConnecting || _isDisconnecting) buildSpinner(context),
      TextButton(
          onPressed: _isConnecting ? onCancelPressed : (isConnected
              ? onDisconnectPressed
              : onConnectPressed),
          child: Text(
            _isConnecting ? "Cancel" : (isConnected ? "Disconnect" : "Connect"),
            style: Theme
                .of(context)
                .primaryTextTheme
                .labelLarge
                ?.copyWith(color: Colors.white),
          ))
    ]);
  }

  String _dataParser(List<int> dataFromDevice) {
    return utf8.decode(dataFromDevice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(
      backgroundColor: Colors.lightGreen[700],
      title: Text(widget.device.platformName,
        style: TextStyle(color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,),),
      actions: [buildConnectButton(context)],
    ),
      backgroundColor: Colors.grey[200],
      bottomNavigationBar: BottomNavigationBar(items: [
        BottomNavigationBarItem(
            icon: Icon(Icons.directions_walk), label: 'Walking Gait'),
        BottomNavigationBarItem(icon: Icon(Icons.airline_seat_legroom_extra_sharp), label: 'Dorsiflexion'),
        BottomNavigationBarItem(icon: Icon(Icons.emergency), label: 'Plantarflexion'),
      ],
        selectedItemColor: Colors.lightGreen[700],
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: _getBodyContent(),),
      ),
    );
  }

  Widget _getBodyContent() {
    switch (_currentIndex) {
      case 0: // Walking Gait
                setUpStatusNotifications();
        return _buildWalkingGaitContent();
      case 1: //Dorsiflexion
        return _buildDorsiflexionContent();
      case 2: //Plantarflexion
        return _buildPlantarflexionContent();
      default:
        return Container(); // Fallback in case of an unexpected index
    }
  }

  Widget _buildPlantarflexionContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        children: [
          // Centered Title
          Center(
            child: Column(
              children: [
                SizedBox(height: 25),
                Text(
                  'Plantarflexion Measurement',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          Devicestatus(status: status),
          SizedBox(height: 15,),
          // Icons and GestureDetectors spaced evenly
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //Start Button
              Column(
                children: [
                  GestureDetector(
                    onTap: onDiscoverServicesPressed,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.lightGreen[700],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.all(12),
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 8,),
                  Text('Start',
                    style: TextStyle(color: Colors.black,
                        fontSize: 14),),
                ],
              ),
              //Re-Calibrate Button
              Column(
                children: [
                  GestureDetector(
                    onTap: calibrateSensor,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.all(12),
                      child: Icon(
                        Icons.compass_calibration,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 8,),
                  Text('Calibrate',
                    style: TextStyle(color: Colors.black,
                        fontSize: 14),),

                ],

              ),

              Column(
                children: [
                  GestureDetector(
                    onTap: saveMeasurement(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.lightGreen[700],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.all(12),
                      child: Icon(
                        Icons.save_alt,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 8,),
                  Text('Save',
                    style: TextStyle(color: Colors.black,
                        fontSize: 14),),

                ],

              ),

              Column(
                children: [
                  GestureDetector(
                    onTap: onStopNotificationsPressed,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.all(12),
                      child: Icon(
                        Icons.stop,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 8,),
                  Text('Stop',
                    style: TextStyle(color: Colors.black,
                        fontSize: 14),),

                ],

              ),

            ],
          ),

          // Additional content spacing
          SizedBox(height: 25),
          // Additional content specific to Stationary
          //     Text('Available Clinical Assessments for Stationary'),
          //     SizedBox(height: 25),

          //  Container(child: TextButton(onPressed: onDiscoverServicesPressed, child: const Text("Start Measuring"),)),

          Container(child: !isReady ? Container(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PfAnglesUi()
            ],
          ) ,)
              : Container(
            child: StreamBuilder<List<int>>(
              stream: stream,
              builder: (BuildContext context,
                  AsyncSnapshot<List<int>> snapshot) {
                if (snapshot.hasError) return Text('Error: ${snapshot.error}');

                if (snapshot.connectionState == ConnectionState.active) {
                  // Get Data From Bluetooth
                  String currentValue = _dataParser(snapshot.requireData);

                  // Check if _pitchRollData has at least two elements
                    if (currentValue.isNotEmpty &&
                        double.tryParse(currentValue) != null) {
                      _Plantarflexion = double.parse(currentValue);
                      if (_Plantarflexion >0){
                       _Plantarflexion = 0;
                      }
                    } else {
                    // Handle the case where the data is insufficient
                    return PfAnglesUi();
                  }

                  return SingleChildScrollView(
                    child: Plantarflexion(angle: _Plantarflexion.abs()),
                  );
                } else {
                  return PfAnglesUi();
                }
              },
            ),
          ),)
        ],
      ),
    );
  }

  Widget _buildWalkingGaitContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  SizedBox(height: 25),
                  Text(
                    'Walking Gait Ankle Motion',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 25),
            // Additional content specific to Walking Gait
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber, color: Colors.amber,),
                SizedBox(width: 3,),
                Text('Instructions', style: TextStyle(fontSize: 18,
                    fontWeight: FontWeight.bold),)
              ],
            ),
            SizedBox(height: 10,),
            Row(
              children: [
                Flexible(
                  child: Text(
                      '1. Place the device ontop of the foot.\n'
                          '2. Press the CALIBRATE button & wait for the device status to be READY.\n'
                          '3. Press the START button when you are ready to walk.\n'
                  '4. A Message will be displayed when results are available on the web page!'),
                ),
              ],
            ),
            SizedBox(height: 25,),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Column(
                      children: [
                        GestureDetector(
                          onTap: calibrateSensor,
                          child: Container(
                              decoration: BoxDecoration(color: Colors
                                  .amber[700],
                                  borderRadius: BorderRadius.circular(12)),
                              padding: EdgeInsets.all(12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceEvenly,
                                children: [
                                  Icon(Icons.compass_calibration, color: Colors.black,),
                                  SizedBox(width: 3,),
                                  Text('Calibrate Device',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20
                                    ),
                                  )
                                ],)
                          ),
                        ),
                        SizedBox(height: 25,),

                        GestureDetector(
                          onTap: sendStartCommand,
                          child: Container(
                              decoration: BoxDecoration(color: Colors.lightGreen[700],
                                  borderRadius: BorderRadius.circular(12)),
                              padding: EdgeInsets.all(12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceEvenly,
                                children: [
                                  Icon(Icons.play_arrow, color: Colors.white,),
                                  SizedBox(width: 3,),
                                  Text('START Recording',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20
                                    ),
                                  )
                                ],)
                          ),
                        ),
                        SizedBox(height: 25,),
                      ],
                    ),
                    //Are Streaming, Stop Button Container
                  ],
                ),

              ],
            ),
            //Continue Here
            Devicestatus(status: status),
          ],
        ),
      ),
    );
  }

  Widget _buildDorsiflexionContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        children: [
          // Centered Title
          Center(
            child: Column(
              children: [
                SizedBox(height: 25),
                Text(
                  'Dorsiflexion Measurement',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),

              ],
            ),
          ),
          Devicestatus(status: status),

          SizedBox(height: 15,),
          // Icons and GestureDetectors spaced evenly
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //Start Button
              Column(
                children: [
                  GestureDetector(
                    onTap: onDiscoverServicesPressed,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.lightGreen[700],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.all(12),
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 8,),
                  Text('Start',
                    style: TextStyle(color: Colors.black,
                        fontSize: 14),),
                ],
              ),
              //Re-Calibrate Button
              Column(
                children: [
                  GestureDetector(
                    onTap: calibrateSensor,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.all(12),
                      child: Icon(
                        Icons.compass_calibration,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 8,),
                  Text('Calibrate',
                    style: TextStyle(color: Colors.black,
                        fontSize: 14),),

                ],

              ),

              Column(
                children: [
                  GestureDetector(
                    onTap: saveMeasurement(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.lightGreen[700],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.all(12),
                      child: Icon(
                        Icons.save_alt,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 8,),
                  Text('Save',
                    style: TextStyle(color: Colors.black,
                        fontSize: 14),),

                ],

              ),

              Column(
                children: [
                  GestureDetector(
                    onTap: onStopNotificationsPressed,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.all(12),
                      child: Icon(
                        Icons.stop,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 8,),
                  Text('Stop',
                    style: TextStyle(color: Colors.black,
                        fontSize: 14),),

                ],

              ),

            ],
          ),

          // Additional content spacing
          SizedBox(height: 25),
          // Additional content specific to Stationary
          //     Text('Available Clinical Assessments for Stationary'),
          //     SizedBox(height: 25),

          //  Container(child: TextButton(onPressed: onDiscoverServicesPressed, child: const Text("Start Measuring"),)),

          Container(
            child: !isReady
                ? Container(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnglesUi()
                        ],
                     ) ,)
                : Container(
              child: StreamBuilder<List<int>>(
                stream: stream,
                builder: (BuildContext context,
                    AsyncSnapshot<List<int>> snapshot) {
                  if (snapshot.hasError)
                    return Text('Error: ${snapshot.error}');

                  if (snapshot.connectionState == ConnectionState.active) {
                    // Get Data From Bluetooth
                    String currentValue = _dataParser(snapshot.requireData);


                      if (currentValue.isNotEmpty &&
                          double.tryParse(currentValue) != null) {
                        _Dorsiflexion = double.parse(currentValue);
                        if(_Dorsiflexion <0){
                          _Dorsiflexion = 0;
                        }
                      }
                     else {
                      // Handle the case where the data is insufficient
                      return AnglesUi();
                    }

                    return SingleChildScrollView(
                      //Replace with the REAL ANGLES UI
                      child: Dorsiflexion(angle: _Dorsiflexion),
                    );
                  } else {
                    return AnglesUi();
                  }
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Future calibrateSensor() async {
    _services = await widget.device.discoverServices();
    _services.forEach((_services) {
      if (_services.uuid.toString() == SERVICE_UUID) {
        _services.characteristics.forEach((characteristic) async {
          if (characteristic.uuid.toString() == CHARACTERISTIC_UUID_RX) {
            try {
              await characteristic.write(
                  utf8.encode("CALIBRATE"), withoutResponse: false);

              print("Sent 'CALIBRATE' command to ESP32");
            } catch (e) {
              print("Error writing to characteristic: $e");
            }
            // return;
          }
        });
      }
    });
  }

  saveMeasurement() {
  }

  Future sendStartCommand() async {
    _services = await widget.device.discoverServices();
    _services.forEach((_services) {
      if (_services.uuid.toString() == SERVICE_UUID) {
        _services.characteristics.forEach((characteristic) async {
          if (characteristic.uuid.toString() == CHARACTERISTIC_UUID_RX) {
            try {
              await characteristic.write(
                  utf8.encode("START"), withoutResponse: false);

              print("Sent 'START' command to ESP32");
            } catch (e) {
              print("Error writing to characteristic: $e");
            }
            // return;
          }
        });
      }
    });
  }


  Future sendStopCommand() async {
    _services = await widget.device.discoverServices();
    _services.forEach((_services) {
      if (_services.uuid.toString() == SERVICE_UUID) {
        _services.characteristics.forEach((characteristic) async {
          if (characteristic.uuid.toString() == CHARACTERISTIC_UUID_RX) {
            try {
              await characteristic.write(
                  utf8.encode("STOP"), withoutResponse: false);

              print("Sent 'STOP' command to ESP32");
            } catch (e) {
              print("Error writing to characteristic: $e");
            }
            // return;
          }
        });
      }
    });
  }

  Future<void> setUpStatusNotifications() async {
    try {
      List<BluetoothService> services = await widget.device.discoverServices();
      for (var service in services) {
        if (service.uuid.toString() == SERVICE_UUID) {
          for (var characteristic in service.characteristics) {
            if (characteristic.uuid.toString() == CHARACTERISTIC_UUID_STATUS) {
              statusCharacteristic = characteristic;

              // Set up Notifications
              await characteristic.setNotifyValue(true);
              characteristic.value.listen((value) {
                // Determine the new status based on the received value
                String newStatus;
                if (value.isNotEmpty && value[0] == 1) {
                  newStatus = "CALIBRATING";
                } else if (value.isNotEmpty && value[0] == 0) {
                  newStatus = "READY";
                } else if(value.isNotEmpty && value[0] == 2){
                  newStatus = "START WALKING";
                }else if(value.isNotEmpty && value[0] == 3){
                  newStatus = "CHECK WEBPAGE";
                }else if(value.isNotEmpty && value[0] == 4){
                  newStatus = "ERROR. DID NOT POST";
                }else {
                  newStatus = "UNKNOWN";
                }

                // Only update the UI if the status has changed
                if (newStatus != lastStatus) {
                  setState(() {
                    status = newStatus;
                  });
                  lastStatus = newStatus; // Update last received status
                }
              });
              break; // Exit loop once characteristic is found
            }
          }
        }
      }
    } catch (e) {
      print("Error setting up notifications: $e");
    }
  }


}

