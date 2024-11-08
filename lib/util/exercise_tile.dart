import 'package:flutter/material.dart';

class ExerciseTile extends StatelessWidget {

  final icon;
  final String exerciseName;
  final String Description;

  const ExerciseTile({
    Key? key,
    required this.icon,
    required this.exerciseName,
    required this.Description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        decoration:BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.circular(16)) ,
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
                padding: EdgeInsets.all(16),
                color: Colors.lightGreen.shade700,
                child: Icon(icon, color: Colors.white,)),
          ),
          title: Text(exerciseName,
            style: TextStyle(fontWeight: FontWeight.bold,
              fontSize: 16,),),
          subtitle: Text(Description),
        ),
      ),
    );
  }
}
