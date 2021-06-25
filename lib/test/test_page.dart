import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_page_controller.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:rxdart/rxdart.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key key}) : super(key: key);

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> with BasePageController {
  ScrollController scrollController;
  EasyRefreshController controller;
  bool hasData = true;

  @override
  void initState() {
    super.initState();

    scrollController = ScrollController();
    controller = EasyRefreshController();
    concat([0, 1, 2, 3, 4], false);
  }

  @override
  void loadData(bool loadMore) {
    if (!loadMore) {
      pageParam.reset();
    }

    Observable.just([0, 1, 2, 3, 4, 5]).delay(Duration(seconds: 2)).listen(
        (event) {
      hasData = true;
      concat(event, loadMore);
      setState(() {});
    }, onDone: () {
      if (loadMore) {
        controller.finishLoad();
      } else {
        controller.resetLoadState();
        controller.finishRefresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          children: [
            BaseWidget.statusBar(context, true),
            Expanded(
              child: BaseWidget.refreshWidgetPage(
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return bodyWidget();
                      },
                      childCount: 1,
                    ),
                  ),
                ],
                controller: controller,
                scrollController: scrollController,
                hasData: hasData,
                loadData: loadData,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget bodyWidget() {
    return MediaQuery.removePadding(
      removeTop: true,
      removeBottom: true,
      context: context,
      child: StaggeredGridView.countBuilder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        itemCount: mData.length,
        itemBuilder: (context, index) {
          return Container(
            height: index <= 1
                ? 96
                : index % 2 == 0
                    ? 96
                    : 144,
            color: Colors.primaries[index % Colors.primaries.length],
            alignment: Alignment.center,
            child: Text(
              '$index',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          );
        },
        staggeredTileBuilder: (index) {
          return index <= 1
              ? StaggeredTile.count(2, 1)
              : index == 2
                  ? StaggeredTile.count(4, 1)
                  : StaggeredTile.fit(2);
        },
      ),
    );
  }
}
