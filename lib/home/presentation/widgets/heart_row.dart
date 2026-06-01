// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class HeartRow extends StatefulWidget {
  const HeartRow({super.key, this.icon});

  final Icon? icon;

  @override
  _HeartRowState createState() => _HeartRowState();
}

class _HeartRowState extends State<HeartRow> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.favorite,
          size: 15,
          color: Theme.of(context).colorScheme.secondary,
        ),
        Icon(Icons.favorite, size: 15, color: Colors.white),
        Icon(
          Icons.favorite,
          size: 15,
          color: Theme.of(context).colorScheme.secondary,
        ),
        Icon(Icons.favorite, size: 15, color: Colors.white),
        Icon(
          Icons.favorite,
          size: 15,
          color: Theme.of(context).colorScheme.secondary,
        ),
        Icon(Icons.favorite, size: 15, color: Colors.white),
        Icon(
          Icons.favorite,
          size: 15,
          color: Theme.of(context).colorScheme.secondary,
        ),
        Icon(Icons.favorite, size: 15, color: Colors.white),
        Icon(
          Icons.favorite,
          size: 15,
          color: Theme.of(context).colorScheme.secondary,
        ),
        Icon(Icons.favorite, size: 15, color: Colors.white),
        Icon(
          Icons.favorite,
          size: 15,
          color: Theme.of(context).colorScheme.secondary,
        ),
        Icon(Icons.favorite, size: 15, color: Colors.white),
        Icon(
          Icons.favorite,
          size: 15,
          color: Theme.of(context).colorScheme.secondary,
        ),
        Icon(Icons.favorite, size: 15, color: Colors.white),
        Icon(
          Icons.favorite,
          size: 15,
          color: Theme.of(context).colorScheme.secondary,
        ),
        Icon(Icons.favorite, size: 15, color: Colors.white),
        Icon(
          Icons.favorite,
          size: 15,
          color: Theme.of(context).colorScheme.secondary,
        ),
        Icon(Icons.favorite, size: 15, color: Colors.white),
        Icon(
          Icons.favorite,
          size: 15,
          color: Theme.of(context).colorScheme.secondary,
        ),
        Icon(Icons.favorite, size: 15, color: Colors.white),
        Icon(
          Icons.favorite,
          size: 15,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ],
    );
  }
}
