import 'package:flutter/material.dart';

class GroceryWidget extends StatelessWidget {
  const GroceryWidget(
      {super.key,
      required this.boxColor,
      required this.title,
      required this.groceryAmount});

  final Color boxColor;
  final String title;
  final int groceryAmount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(color: boxColor),
          ),
          const SizedBox(
            width: 30,
          ),
          Text(title),
          const Spacer(),
          Text('$groceryAmount')
        ],
      ),
    );
  }
}
