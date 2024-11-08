import 'package:flutter/material.dart';

class RomBlocks extends StatelessWidget {
  final String romBlocks;

  const RomBlocks({
    Key? key,
    required this.romBlocks
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(decoration: BoxDecoration(color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12)
    ),
      padding: EdgeInsets.all(16),
      child: Center(child: Text(
          romBlocks,
          style: TextStyle(fontSize: 30),)),
    );
  }
}
