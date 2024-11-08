import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import "descriptor_tile.dart";

class CharacteristicsTile extends StatelessWidget {
  final BluetoothCharacteristic characteristic;
  final List<DescriptorTile> descriptorTiles;
  final VoidCallback onReadPressed;
  final VoidCallback onWritePressed;
  final VoidCallback onNotificationPressed;

  const CharacteristicsTile({
    super.key,
    required this.characteristic,
    required this.descriptorTiles,
    required this.onReadPressed,
    required this.onWritePressed,
    required this.onNotificationPressed,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<int>>(
      stream: characteristic.value,
      initialData: characteristic.lastValue,
      builder: (BuildContext c, AsyncSnapshot<List<int>> snapshot) {
        final List<int>? value = snapshot.data;
        return ExpansionTile(
          title: ListTile(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Characteristic'),
                Text(
                  '0x${characteristic.uuid.toString().toUpperCase().substring(4, 8)}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
            subtitle: Text(value.toString()),
            contentPadding: const EdgeInsets.all(0.0),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.file_download,
                  color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
                ),
                onPressed: onReadPressed,
              ),
              IconButton(
                icon: Icon(
                  Icons.file_upload,
                  color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
                ),
                onPressed: onWritePressed,
              ),
              IconButton(
                icon: Icon(
                  characteristic.isNotifying ? Icons.sync_disabled : Icons.sync,
                  color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
                ),
                onPressed: onNotificationPressed,
              ),
            ],
          ),
          children: descriptorTiles,
        );
      },
    );
  }
}
