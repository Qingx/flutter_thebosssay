import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class BossPage extends StatefulWidget {
  const BossPage({Key key}) : super(key: key);

  @override
  _BossPageState createState() => _BossPageState();
}

class _BossPageState extends State<BossPage>
    with AutomaticKeepAliveClientMixin {
  int time = 0;
  StreamSubscription<int> mDispose;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        time.toString(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    print('BossPage====>init');

    if (mDispose != null) {
      mDispose?.cancel();
    }

    mDispose =
        Observable.periodic(Duration(seconds: 1), (i) => i++).listen((event) {
      time = event;
      setState(() {});
    });
  }

  @override
  void dispose() {
    print('BossPage====>dispose');
    super.dispose();
    mDispose?.cancel();
  }

  @override
  bool get wantKeepAlive => true;
}
