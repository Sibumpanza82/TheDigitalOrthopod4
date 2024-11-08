import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class PfAnglesUi extends StatelessWidget {
  //final double angle;
  // final String text;

  const PfAnglesUi({
    super.key,
    // required this.angle,
    // required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                ),
                width: double.infinity,
                child: Column(
                  children: [
                    Text("Waiting for data/connection...",
                      style: TextStyle(fontSize: 17,
                          fontWeight: FontWeight.bold),),
                    SfRadialGauge(
                        axes: <RadialAxis>[
                          RadialAxis(minimum: 0, maximum: 70,
                              ranges: <GaugeRange>[
                                GaugeRange(startValue: 0, endValue: 20, color:Colors.red),
                                GaugeRange(startValue: 20,endValue: 50,color: Colors.green),
                                GaugeRange(startValue: 50,endValue: 70,color: Colors.red)],
                              pointers: <GaugePointer>[
                                NeedlePointer(value: 0)],
                              annotations: <GaugeAnnotation>[
                                GaugeAnnotation(widget: Container(child:
                                Text('0.00˚',style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold))),
                                    angle: 90, positionFactor: 1
                                )]
                          )]
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
