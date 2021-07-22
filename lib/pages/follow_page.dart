import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/data_config.dart';
import 'package:flutter_boss_says/data/entity/boss_label_entity.dart';
import 'package:flutter_boss_says/data/server/boss_api.dart';
import 'package:flutter_boss_says/pages/follow_content_page.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_empty.dart';
import 'package:flutter_boss_says/util/base_event.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:rxdart/rxdart.dart';

class FollowPage extends StatefulWidget {
  const FollowPage({Key key}) : super(key: key);

  @override
  _FollowPageState createState() => _FollowPageState();
}

class _FollowPageState extends State<FollowPage>
    with AutomaticKeepAliveClientMixin {
  int mCurrentIndex;
  PageController mPageController;

  List<BossLabelEntity> labels;
  List<FollowContentPage> mPages;

  StreamSubscription<BaseEvent> eventDispose;

  var builderFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();

    mPageController?.dispose();

    eventDispose?.cancel();
  }

  @override
  void initState() {
    super.initState();

    mCurrentIndex = 0;
    mPageController = PageController();

    builderFuture = loadInitData();
  }

  Future<List<dynamic>> loadInitData() {
    if (DataConfig.getIns().bossLabels.isLabelEmpty()) {
      return BossApi.ins()
          .obtainBossLabels()
          .onErrorReturn([]).doOnData((event) {
        labels = [BaseEmpty.emptyLabel, ...event];
        DataConfig.getIns().setBossLabels = event;

        mPages = labels.map((e) => FollowContentPage(e.id)).toList();
      }).last;
    } else {
      labels = DataConfig.getIns().bossLabels;
      mPages = labels.map((e) => FollowContentPage(e.id)).toList();

      return Observable.just([0, 1, 2]).last;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      builder: builderWidget,
      future: builderFuture,
    );
  }

  Widget builderWidget(
      BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasData && !labels.isLabelEmpty()) {
        Global.hint.setCanUse(true);
        return contentWidget();
      } else {
        return BaseWidget.errorWidget(() {
          builderFuture = loadInitData();
          setState(() {});
        });
      }
    } else {
      return loadingWidget();
    }
  }

  Widget contentWidget() {
    return Container(
      child: Column(
        children: [
          tabWidget(),
          Expanded(
            child: PageView.builder(
              physics: NeverScrollableScrollPhysics(),
              controller: mPageController,
              itemCount: mPages.length,
              itemBuilder: (context, index) {
                return mPages[index];
              },
              onPageChanged: (index) {
                mCurrentIndex = index;
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget tabWidget() {
    return Container(
      height: 40,
      padding: EdgeInsets.only(top: 6, bottom: 6),
      child: MediaQuery.removePadding(
        removeTop: true,
        removeBottom: true,
        context: context,
        child: ListView.builder(
          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return tabItemWidget(labels[index], index);
          },
          itemCount: labels.length,
        ),
      ),
    );
  }

  Widget tabItemWidget(BossLabelEntity entity, int index) {
    double left = index == 0 ? 16 : 8;
    double right = index == 15 ? 16 : 8;

    bool hasSelect = labels[mCurrentIndex].id == entity.id;

    Color bgColor = hasSelect ? BaseColor.accent : BaseColor.accentLight;
    Color fontColor = hasSelect ? Colors.white : BaseColor.accent;

    return Container(
      margin: EdgeInsets.only(left: left, right: right),
      padding: EdgeInsets.only(left: 12, right: 12),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(14)), color: bgColor),
      child: Center(
        child: Text(
          entity.name,
          style: TextStyle(color: fontColor, fontSize: 14),
        ),
      ),
    ).onClick(() {
      if (index != mCurrentIndex) {
        mCurrentIndex = index;
        mPageController.jumpToPage(mCurrentIndex);
      }
    });
  }

  Widget loadingWidget() {
    return Container(
      color: BaseColor.pageBg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          loadTabWidget(),
          loadCardWidget(),
          loadingItemWidget(0.7, 24),
          loadingItemWidget(0.3, 8),
          loadingItemWidget(1, 16),
          loadingItemWidget(1, 8),
          loadingItemWidget(1, 8),
          loadingItemWidget(0.4, 8),
          loadingItemWidget(0.6, 8),
          Container(
            margin: EdgeInsets.only(top: 16, left: 16, right: 16),
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SpinKitFadingCircle(
                  color: Color(0xff0e1e1e1),
                  size: 48,
                  duration: Duration(milliseconds: 2000),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget loadTabWidget() {
    return Container(
      height: 40,
      padding: EdgeInsets.only(top: 12),
      child: MediaQuery.removePadding(
        removeTop: true,
        removeBottom: true,
        context: context,
        child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return loadTabItemWidget(index);
          },
          itemCount: 4,
        ),
      ),
    );
  }

  Widget loadTabItemWidget(int index) {
    double left = index == 0 ? 16 : 8;
    double right = index == 15 ? 16 : 8;
    return Container(
      width: 80,
      margin: EdgeInsets.only(left: left, right: right),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          color: BaseColor.loadBg),
    );
  }

  Widget loadingItemWidget(double width, double margin) {
    return Container(
      width: (MediaQuery.of(context).size.width - 32) * width,
      height: 16,
      margin: EdgeInsets.only(left: 16, right: 16, top: margin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        color: BaseColor.loadBg,
      ),
    );
  }

  Widget loadCardWidget() {
    return Container(
      height: 188,
      padding: EdgeInsets.only(top: 24, bottom: 24),
      child: MediaQuery.removePadding(
        removeBottom: true,
        removeTop: true,
        context: context,
        child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return loadCardItemWidget(index);
          },
          itemCount: 4,
        ),
      ),
    );
  }

  Widget loadCardItemWidget(int index) {
    double left = index == 0 ? 16 : 8;
    double right = index == 15 ? 16 : 8;

    return Container(
      width: 100,
      height: 140,
      decoration: BoxDecoration(
        color: BaseColor.loadBg,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      margin: EdgeInsets.only(left: left, right: right),
    );
  }
}
