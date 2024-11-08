import 'package:ankleromapp/util/exercise_tile.dart';
import 'package:ankleromapp/util/rom_blocks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:ankleromapp/pages/bluetooth_screen.dart';
import 'package:ankleromapp/pages/progress.dart';
import 'package:ankleromapp/pages/bluetooth_off_screen.dart';
import 'package:ankleromapp/pages/flutterBlueAppState.dart';


class HomePage extends StatefulWidget {
   HomePage({super.key});



  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  //Sign user out method
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

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
        //This is the home page, do nothing
        break;

      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (context)=> Progress()),
        );
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
        currentIndex: 1,
        onTap: onNavItemTapped,
      ),
      body: SafeArea(
        child: Column(
          children: [

            Padding(
              padding: const EdgeInsets.symmetric(horizontal:25.0 ),
              child: Column(children: [
                // Greetings Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //Hi Sibusiso
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 25,),
                        Text(
                          'The Digital Orthopod',
                          style: TextStyle(color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8,
                        ),
                        Text('Mobile Application',
                          style: TextStyle(color: Colors.white,
                          fontSize: 20),
                        )
                      ],
                    ),

                    //Log-Out
                    GestureDetector(
                      onTap: signUserOut,
                      child: Container(
                        decoration: BoxDecoration(color: Colors.white,
                            borderRadius: BorderRadius.circular(12)
                        ),
                        padding: EdgeInsets.all(12),
                        child: Icon(
                          Icons.logout,
                          color: Colors.black,
                        ),
                      ),
                    )

                  ],),

                SizedBox(
                  height: 25,
                ),
                //Search Bar
                Container(
                    decoration: BoxDecoration(color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('Lets Get Started!',
                          style: TextStyle(
                            color: Colors.lightGreen[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 20
                          ),
                        )
                      ],)
                ),
                SizedBox(height: 20,),

                // Column(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     Center(
                //       child:Column(children: [
                //         Row(
                //           children: [
                //             Column(
                //               children: [
                //                 Icon(Icons.bluetooth_connected, color: Colors.black,
                //                 size: 50,),
                //               ],
                //             ),
                //             Column(
                //               children: [
                //                 Text('Bluetooth Connection Required',style: TextStyle(color: Colors.white,
                //                     fontSize: 17,
                //                     fontWeight: FontWeight.bold),),
                //               ],
                //             )
                //           ],
                //         ),
                //       ],)
                //     ),
                //   ],
                // ),
                // SizedBox(
                //   height: 20,
                // ),

                //Available Clinical Assessments
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   children: [
                //     //Static Ankle ROM
                //     Column(
                //       children: [
                //         RomBlocks(romBlocks: '🦶🏽',
                //         ),
                //         SizedBox(
                //           height: 8,
                //         ),
                //         Text('Ankle',
                //           style: TextStyle(color: Colors.white,
                //           fontSize: 18),),
                //
                //       ],
                //     ),
                //     //Dynamic Ankle ROM
                //     Column(
                //       children: [
                //         RomBlocks(romBlocks: '🚶',
                //         ),
                //         SizedBox(
                //           height: 8,
                //         ),
                //         Text('Walking Gait',
                //           style: TextStyle(color: Colors.white,
                //           fontSize: 18),),
                //
                //       ],
                //     ),
                //   ],),
              ],),
            ),

          SizedBox(
            height: 20,
          ),

          Expanded(
            child: Container(
              padding: EdgeInsets.all(25),
              color: Colors.grey[200],
              child: Center(
                child: Column(children: [
                  //exercise heading
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Range of Motion Exercises',
                      style: TextStyle(fontWeight: FontWeight.bold,
                      fontSize: 20
                      ),
                      ),
                      Icon(Icons.more_horiz)
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  
                  //Listview of Exercises
                  Expanded(
                    child: ListView(children: [
                      ExerciseTile(icon:Icons.square_foot,
                        exerciseName: 'Plantar/Dorsiflexion',
                        Description: '1 Exercise Available',),
                      ExerciseTile(icon:Icons.airline_seat_legroom_extra,
                      exerciseName: 'Inversion/Eversion',
                      Description: '1 Exercise Available',),
                      ExerciseTile(icon: Icons.directions_walk,
                          exerciseName: 'Walking Gait Cycle',
                          Description: 'Perform an essessment of the ankle Range of Motion during the Walking Gait')
                    ],),
                  )
                ],),
              ),
            ),
          )

        ],),
      )
    );
  }




}
