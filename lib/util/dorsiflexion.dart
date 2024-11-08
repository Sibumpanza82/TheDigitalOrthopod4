import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class Dorsiflexion extends StatelessWidget {
  final double angle;

  const Dorsiflexion({
    super.key,
    required this.angle,
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
                    SfRadialGauge(
                        axes: <RadialAxis>[
                          RadialAxis(minimum: 0, maximum: 50,
                              ranges: <GaugeRange>[
                                GaugeRange(startValue: 0, endValue: 20, color:Colors.red),
                                GaugeRange(startValue: 20,endValue: 30,color: Colors.green),
                                GaugeRange(startValue: 30,endValue: 50,color: Colors.red)],
                              pointers: <GaugePointer>[
                                NeedlePointer(value: angle)],
                              annotations: <GaugeAnnotation>[
                                GaugeAnnotation(widget: Container(child:
                                Text('$angle˚',style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,
                                color: angle>20 && angle<30? Colors.green: Colors.red))),
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
