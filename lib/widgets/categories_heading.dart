import 'package:flutter/material.dart';
import 'package:careerapp/size_config.dart';

class CategoryHeading extends StatelessWidget {
  final String title;

  const CategoryHeading({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: Row(
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 2.2 * SizeConfig.textMultiplier!),
          ),
          const Spacer(),
          Text(
            "",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 1.7 * SizeConfig.textMultiplier!,
            ),
          ),
        ],
      ),
    );
  }
}
