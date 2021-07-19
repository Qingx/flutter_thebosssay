import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/data_config.dart';
import 'package:flutter_boss_says/data/entity/boss_label_entity.dart';
import 'package:flutter_boss_says/test/page/follow_content_page.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';

class TestFollowPage extends StatefulWidget {
  const TestFollowPage({Key key}) : super(key: key);

  @override
  _TestFollowPageState createState() => _TestFollowPageState();
}

class _TestFollowPageState extends State<TestFollowPage>
    with AutomaticKeepAliveClientMixin {
  int mCurrentIndex;
  PageController mPageController;
  List<BossLabelEntity> labels;
  List<FollowContentPage> mPages;

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

    labels = DataConfig.getIns().bossLabels;
    mPages = labels.map((e) => FollowContentPage(e.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
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
      padding: EdgeInsets.only(top: 12),
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
}
