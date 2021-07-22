import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

extension FunMap on Map {
  bool isNullOrEmpty() {
    return !(this != null && this.length > 0);
  }
}

extension FunList on List {
  bool isNullOrEmpty() {
    return !(this != null && this.length > 0);
  }

  bool isLabelEmpty() {
    return !(this != null && this.length > 1);
  }
}

extension StringList on List<String> {
  String addWrap() {
    String result = "";
    this.forEach((element) {
      result = "$result\n$element";
    });
    return result;
  }
}

extension FunString on String {
  void printf() {
    print("${DateTime.now()} $this");
  }

  bool isNullOrEmpty() {
    return this == null || this.isEmpty;
  }

  String hidePhoneNumber() {
    return this.replaceRange(3, 11, "********");
  }
}

extension WidgetClick on Widget {
  InkWell onClick(Function doClick) {
    return InkWell(
      radius: 0,
      highlightColor: Colors.transparent,
      onTap: () {
        doClick();
      },
      child: this,
    );
  }

  Widget marginOn({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) {
    return Container(
        margin: EdgeInsets.only(
          top: top,
          left: left,
          right: right,
          bottom: bottom,
        ),
        child: this);
  }

  Positioned positionOn({
    Key key,
    double left,
    double top,
    double right,
    double bottom,
    double width,
    double height,
  }) {
    return Positioned(
      key: key,
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      width: width,
      height: height,
      child: this,
    );
  }
}

extension DoubleMoney on int {
  String formatMoney() {
    String money = "0.00";
    var num = this / 100.0;
    if ((num.toString().length - num.toString().lastIndexOf(".") - 1) < 2) {
      money = num.toStringAsFixed(2)
          .substring(0, num.toString().lastIndexOf(".") + 3)
          .toString();
    } else {
      money = num.toString()
          .substring(0, num.toString().lastIndexOf(".") + 3)
          .toString();
    }
    return money;
  }
}
