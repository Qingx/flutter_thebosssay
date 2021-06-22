import 'package:flutter/material.dart';
import 'package:flutter_boss_says/util/base_color.dart';

class SquarePage extends StatefulWidget {
  const SquarePage({Key key}) : super(key: key);

  @override
  _SquarePageState createState() => _SquarePageState();
}

class _SquarePageState extends State<SquarePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: BaseColor.pageBg,
      child: Center(
        child: Text("SquarePage"),
      ),
    );
  }
}
