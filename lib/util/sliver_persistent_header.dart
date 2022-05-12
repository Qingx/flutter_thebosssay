import 'package:flutter/material.dart';

class MySliverPersistentHeader extends SliverPersistentHeaderDelegate {
  final Widget widget;

  MySliverPersistentHeader({this.widget});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: 40,
      child: widget,
      color: Colors.white,
    );
  }

  @override
  double get maxExtent => 40;

  @override
  double get minExtent => 40;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
