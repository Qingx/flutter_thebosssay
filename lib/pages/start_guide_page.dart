import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/http_config.dart';
import 'package:flutter_boss_says/config/page_param.dart';
import 'package:flutter_boss_says/config/user_config.dart';
import 'package:flutter_boss_says/data/cache/cache_provider.dart';
import 'package:flutter_boss_says/data/entity/guide_boss_entity.dart';
import 'package:flutter_boss_says/data/entity/user_entity.dart';
import 'package:flutter_boss_says/data/server/app_api.dart';
import 'package:flutter_boss_says/data/server/jpush_api.dart';
import 'package:flutter_boss_says/data/server/user_api.dart';
import 'package:flutter_boss_says/pages/home_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_empty.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:get/get.dart';

class StartGuidePage extends StatefulWidget {
  const StartGuidePage({Key key}) : super(key: key);

  @override
  _StartGuidePageState createState() => _StartGuidePageState();
}

class _StartGuidePageState extends State<StartGuidePage> {
  double indicatorWidth = 0;
  ScrollController controller;
  List<GuidBossEntity> mData = [];
  List<String> listSelect = [];

  @override
  void dispose() {
    super.dispose();

    controller?.dispose();
  }

  @override
  void initState() {
    super.initState();

    mData = Get.arguments as List<GuidBossEntity>;
    listSelect = mData.map((e) => e.id).toList();

    controller = ScrollController();
    controller.addListener(() {
      var current = controller.position.pixels;
      var max = controller.position.maxScrollExtent;
      var min = controller.position.minScrollExtent;

      if (current >= min && current <= max) {
        indicatorWidth = 100 * (current / max);
        setState(() {});
      }
    });
  }

  ///一键追踪
  void addAll() {
    if (!listSelect.isNullOrEmpty()) {
      followBoss();
    } else {
      BaseTool.toast(msg: "请至少选择一位老板");
    }
  }

  ///全不选
  void removeAll() {
    if (!mData.isNullOrEmpty()) {
      listSelect.clear();
      setState(() {});
    }
  }

  void jumpGuide() {
    CacheProvider.getIns().insertBossList([]);
    BaseWidget.showLoadingAlert("尝试跳过...", context);

    AppApi.ins()
        .obtainGetTackArticleList(PageParam(), "-1")
        .onErrorReturn(BaseEmpty.emptyArticle)
        .flatMap((value) {
          CacheProvider.getIns().insertArticle(value);

          return UserApi.ins().obtainRefresh();
        })
        .timeout(Duration(seconds: 8))
        .listen((event) {
          UserConfig.getIns().token = event.token;
          Global.user.setUser(event.userInfo);

          if (!event.userInfo.tags.isNullOrEmpty()) {
            JpushApi.ins().addTags(event.userInfo.tags);
          }

          Get.offAll(() => HomePage(), transition: Transition.fadeIn);
        });
  }

  ///追踪boss
  void followBoss() {
    BaseWidget.showLoadingAlert("搜寻并追踪...", context);

    UserEntity entity = Global.user.user.value;

    AppApi.ins()
        .obtainFollowBossList(listSelect)
        .flatMap((value) {
          entity.traceNum = listSelect.length;
          Global.user.setUser(entity);

          JpushApi.ins().addTags(listSelect);

          return AppApi.ins().obtainGetAllFollowBoss("-1");
        })
        .onErrorReturn([])
        .flatMap((value) {
          CacheProvider.getIns().insertBossList(value);

          return AppApi.ins().obtainGetTackArticleList(PageParam(), "-1");
        })
        .onErrorReturn(BaseEmpty.emptyArticle)
        .flatMap((value) {
          CacheProvider.getIns().insertArticle(value);
          return UserApi.ins().obtainRefresh();
        })
        .timeout(Duration(seconds: 8))
        .listen((event) {
          UserConfig.getIns().token = event.token;
          Global.user.setUser(event.userInfo);

          if (!event.userInfo.tags.isNullOrEmpty()) {
            JpushApi.ins().addTags(event.userInfo.tags);
          }

          Get.offAll(() => HomePage(), transition: Transition.fadeIn);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        color: BaseColor.pageBg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            topWidget(),
            Text(
              "为你挑选出追踪人数最多的老板",
              style: TextStyle(color: BaseColor.textGray, fontSize: 14),
              maxLines: 1,
              softWrap: false,
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
            ).marginOn(left: 15),
            bodyWidget(),
            addAllWidget(),
            removeAllWidget(),
          ],
        ),
      ),
    );
  }

  Widget topWidget() {
    double marginTop = MediaQuery.of(context).padding.top + 40;
    Color timeBg = Color(0x1a2343C2);

    return Container(
      height: 48,
      margin: EdgeInsets.only(top: marginTop),
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "追踪你感兴趣的老板",
            style: TextStyle(
                fontSize: 24,
                color: BaseColor.textDark,
                fontWeight: FontWeight.bold),
            softWrap: false,
            maxLines: 1,
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
          ),
          Container(
            width: 48,
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              color: timeBg,
            ),
            child: Center(
              child: Text(
                "跳过",
                style: TextStyle(color: BaseColor.accent, fontSize: 14),
                textAlign: TextAlign.center,
                softWrap: false,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ).onClick(jumpGuide),
            ),
          ),
        ],
      ),
    );
  }

  Widget bodyWidget() {
    return Container(
      child: Column(
        children: [
          Container(
            height: 424,
            padding: EdgeInsets.only(top: 24, bottom: 24),
            child: MediaQuery.removePadding(
              removeTop: true,
              removeBottom: true,
              context: context,
              child: GridView.builder(
                padding: EdgeInsets.only(left: 16, right: 16),
                controller: controller,
                scrollDirection: Axis.horizontal,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 8,
                  childAspectRatio:
                      180 / ((MediaQuery.of(context).size.width - 48) / 3),
                ),
                itemBuilder: (context, index) {
                  return itemWidget(mData[index], index);
                },
                itemCount: mData.length,
              ),
            ),
          ),
          Container(
            height: 4,
            width: 100,
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              color: BaseColor.loadBg,
            ),
            child: Container(
              height: 4,
              width: indicatorWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                color: BaseColor.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget itemWidget(GuidBossEntity entity, int index) {
    bool hasSelect = listSelect.contains(entity.id);
    String icon = hasSelect ? R.assetsImgCheckAccent : R.assetsImgCheckWhite;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(4)),
        color: Colors.white,
      ),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          ClipRRect(
            child: Image.network(
              entity.head,
              fit: BoxFit.cover,
              width: (MediaQuery.of(context).size.width - 48) / 3,
              height: 100,
            ),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(4),
              topLeft: Radius.circular(4),
            ),
          ),
          Container(
            height: 80,
            padding: EdgeInsets.only(top: 8, bottom: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(4)),
              color: Colors.white,
            ),
            child: Column(
              children: [
                Container(
                  height: 20,
                  child: Row(
                    children: [
                      Text(
                        entity.name,
                        style: TextStyle(
                          color: BaseColor.textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ).marginOn(left: 6),
                      Expanded(
                        child: Container(
                          height: 12,
                          child: MediaQuery.removePadding(
                            context: context,
                            removeBottom: true,
                            removeTop: true,
                            removeLeft: true,
                            removeRight: true,
                            child: ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return Image.network(
                                  HttpConfig.fullUrl(
                                    entity.photoUrl[index],
                                  ),
                                  fit: BoxFit.cover,
                                ).marginOn(left: index == 0 ? 8 : 1);
                              },
                              itemCount: entity?.photoUrl?.isNullOrEmpty()
                                  ? 0
                                  : entity?.photoUrl?.length,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: (MediaQuery.of(context).size.width - 48) / 3,
                  margin: EdgeInsets.only(top: 8),
                  padding: EdgeInsets.only(left: 6, right: 6),
                  child: Text(
                    entity.role,
                    style: TextStyle(
                      color: BaseColor.textGray,
                      fontSize: 12,
                    ),
                    softWrap: true,
                    maxLines: 2,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.clip,
                  ),
                ),
              ],
            ),
          ).paddingOnly(top: 100),
          Container(
            alignment: Alignment.topRight,
            padding: EdgeInsets.only(top: 6, right: 6),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Color(0x80ffffff),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                topLeft: Radius.circular(2),
                bottomRight: Radius.circular(2),
              ),
            ),
            child: Image.asset(
              icon,
              width: 16,
              height: 16,
            ),
          ).paddingOnly(right: 0, top: 0)
        ],
      ),
    ).onClick(() {
      if (listSelect.contains(entity.id)) {
        listSelect.remove(entity.id);
      } else {
        listSelect.add(entity.id);
      }
      setState(() {});
    });
  }

  Widget addAllWidget() {
    return Container(
      height: 48,
      margin: EdgeInsets.only(left: 16, right: 16, top: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: BaseColor.accent,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            R.assetsImgAim,
            width: 16,
            height: 16,
            fit: BoxFit.cover,
          ),
          Text(
            "一键追踪",
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.start,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ).marginOn(left: 8)
        ],
      ),
    ).onClick(addAll);
  }

  Widget removeAllWidget() {
    return Container(
      height: 48,
      margin: EdgeInsets.only(left: 16, right: 16, top: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: BaseColor.loadBg,
      ),
      alignment: Alignment.center,
      child: Text(
        "全不选",
        style: TextStyle(
            color: BaseColor.textDark,
            fontSize: 16,
            fontWeight: FontWeight.bold),
        textAlign: TextAlign.start,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
      ),
    ).onClick(removeAll);
  }

  Widget loadingWidget() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          topWidget(),
          Text(
            "为你挑选出追踪人数最多的老板",
            style: TextStyle(color: BaseColor.textGray, fontSize: 14),
            maxLines: 1,
            softWrap: false,
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
          ).marginOn(left: 15),
          Container(
            child: Column(
              children: [
                Container(
                  height: 352,
                  padding: EdgeInsets.only(top: 24, bottom: 24),
                  child: MediaQuery.removePadding(
                    removeTop: true,
                    removeBottom: true,
                    context: context,
                    child: GridView.builder(
                      padding: EdgeInsets.only(left: 8),
                      controller: controller,
                      scrollDirection: Axis.horizontal,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        childAspectRatio:
                            144 / (MediaQuery.of(context).size.width - 24) * 3,
                      ),
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.only(left: 8, right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                            color: BaseColor.loadBg,
                          ),
                        );
                      },
                      itemCount: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
