import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/data_config.dart';
import 'package:flutter_boss_says/data/entity/boss_label_entity.dart';
import 'package:flutter_boss_says/data/server/boss_api.dart';
import 'package:flutter_boss_says/event/scroll_top_event.dart';
import 'package:flutter_boss_says/pages/speech_square_content_page.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_empty.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:rxdart/rxdart.dart';

class SpeechSquarePage extends StatefulWidget {
  const SpeechSquarePage({Key key}) : super(key: key);

  @override
  _SpeechSquarePageState createState() => _SpeechSquarePageState();
}

class _SpeechSquarePageState extends State<SpeechSquarePage>
    with AutomaticKeepAliveClientMixin {
  int mCurrentIndex;

  PageController mPageController;
  List<BossLabelEntity> mLabels;
  List<SpeechSquareContentPage> mPages;

  Future<bool> builderFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();

    mPageController?.dispose();
  }

  @override
  void initState() {
    super.initState();

    mCurrentIndex = 0;
    mPageController = PageController();

    builderFuture = loadInitData();
  }

  Future<bool> loadInitData() {
    bool canUse = !DataConfig.getIns().bossLabels.isLabelEmpty();

    if (canUse) {
      return Observable.just(true).doOnData((event) {
        mLabels = DataConfig.getIns().bossLabels;
        mPages = mLabels.map((e) => SpeechSquareContentPage(e.id)).toList();
      }).last;
    } else {
      return BossApi.ins().obtainBossLabels().flatMap((value) {
        value = [BaseEmpty.emptyLabel, ...value];
        mLabels = value;

        DataConfig.getIns().setBossLabels = mLabels;
        mPages = mLabels.map((e) => SpeechSquareContentPage(e.id)).toList();

        return Observable.just(!value.isLabelEmpty());
      }).last;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      builder: builderWidget,
      future: builderFuture,
    );
  }

  Widget builderWidget(BuildContext context, AsyncSnapshot<bool> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasData && snapshot.data) {
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
      height: 52,
      padding: EdgeInsets.only(top: 12, bottom: 12),
      child: MediaQuery.removePadding(
        removeTop: true,
        removeBottom: true,
        context: context,
        child: ListView.builder(
          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return tabItemWidget(mLabels[index], index);
          },
          itemCount: mLabels.length,
        ),
      ),
    );
  }

  Widget tabItemWidget(BossLabelEntity entity, int index) {
    double left = index == 0 ? 16 : 8;
    double right = index == 15 ? 16 : 8;

    bool hasSelect = mLabels[mCurrentIndex].id == entity.id;

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
      } else {
        Global.eventBus
            .fire(ScrollToTopEvent(pageName: "square", labelId: entity.id));
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
          loadingItemWidget(0.7, 24),
          loadingItemWidget(0.3, 8),
          loadingItemWidget(1, 16),
          loadingItemWidget(1, 8),
          loadingItemWidget(1, 8),
          loadingItemWidget(0.4, 8),
          loadingItemWidget(0.6, 8),
          loadingItemWidget(1, 16),
          loadingItemWidget(0.2, 8),
          loadingItemWidget(0.6, 8),
          loadingItemWidget(0.7, 24),
          loadingItemWidget(0.3, 8),
          loadingItemWidget(1, 16),
          loadingItemWidget(1, 8),
          loadingItemWidget(1, 8),
          loadingItemWidget(0.6, 8),
          loadingItemWidget(0.4, 8),
        ],
      ),
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
}
