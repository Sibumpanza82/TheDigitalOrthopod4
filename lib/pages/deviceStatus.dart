import 'package:flutter/material.dart';

class Devicestatus extends StatelessWidget {
  final String status;
  const Devicestatus({
    super.key,
  required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12)),
      padding: EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Ankle Device Status:",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                ),)
            ],
          ),
          SizedBox(height: 5,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(status,
                    style: TextStyle(
                        color: status =="NOT CONNECTED"? Colors.blue[700]: status == "READY"? Colors.lightGreen[700]:
                        status == "UNKNOWN"? Colors.purple : status == "CALIBRATING"? Colors.amber: status == "START WALKING"? Colors.red:
                        status == "CHECK WEBPAGE"? Colors.green[700]: Colors.black,
                        fontSize: 25,
                        fontWeight: FontWeight.bold
                    ),)
                ],
              )
            ],
          )
        ],
      ),);
  }
}
