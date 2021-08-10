import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/event/refresh_search_boss_event.dart';
import 'package:flutter_boss_says/pages/home_boss_all_add_page.dart';
import 'package:flutter_boss_says/pages/home_boss_all_search_page.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:get/get.dart';

class HomeBossAllPage extends StatefulWidget {
  const HomeBossAllPage({Key key}) : super(key: key);

  @override
  _HomeBossAllPageState createState() => _HomeBossAllPageState();
}

class _HomeBossAllPageState extends State<HomeBossAllPage> {
  int mCurrentIndex;
  List<Widget> mPages;
  String searchText;

  HomeBossAllAddPage addPage;
  HomeBossAllSearchPage searchPage;

  TextEditingController editingController;
  PageController mPageController;

  @override
  void dispose() {
    super.dispose();

    editingController?.dispose();
  }

  @override
  void initState() {
    super.initState();
    mCurrentIndex = 0;
    searchText = "";

    addPage = HomeBossAllAddPage();
    searchPage = HomeBossAllSearchPage();
    mPages = [addPage, searchPage];

    editingController = TextEditingController();
    mPageController = PageController();
  }

  void onEditCleared() {
    if (!editingController.text.isNullOrEmpty()) {
      searchText = "";
      editingController.clear();
      mPageController.jumpToPage(0);
    }
  }

  void onEditSubmitted(String text) {
    if (text.isNullOrEmpty()) {
      searchText = "";
      editingController.clear();
      mPageController.jumpToPage(0);
    } else {
      searchText = text;
      searchPage.searchText = searchText;
      if (mCurrentIndex == 0) {
        mPageController.jumpToPage(1);
      } else {
        Global.eventBus.fire(RefreshSearchBossEvent());
      }
    }
  }

  void onEditChanged(text) {
    print('onEditChanged');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: BaseColor.pageBg,
      body: Container(
        child: Column(
          children: [
            BaseWidget.statusBar(context, true),
            topWidget(),
            Expanded(
              child: bodyWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Widget topWidget() {
    return Container(
      height: 56,
      padding: EdgeInsets.only(top: 4, bottom: 12, left: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.arrow_back,
            color: BaseColor.textDark,
            size: 28,
          ).onClick(() {
            Get.back();
          }),
          Expanded(
            child: Obx(() => TextField(
                  controller: editingController,
                  cursorColor: BaseColor.accent,
                  maxLines: 1,
                  textAlign: TextAlign.start,
                  autofocus: false,
                  style: TextStyle(fontSize: 16, color: BaseColor.textDark),
                  decoration: InputDecoration(
                    hintText: Global.hint.hint.value == "-1"
                        ? "请输入内容"
                        : Global.hint.hint.value,
                    hintStyle:
                        TextStyle(fontSize: 16, color: BaseColor.textGray),
                    fillColor: BaseColor.loadBg,
                    filled: true,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    suffixIcon: Icon(
                      Icons.cancel,
                      size: 20,
                      color: BaseColor.textGray,
                    ).onClick(onEditCleared),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 24,
                      color: BaseColor.textDark,
                    ),
                    border: InputBorder.none,
                  ),
                  onChanged: onEditChanged,
                  onSubmitted: onEditSubmitted,
                )).marginOn(left: 20),
          ),
          Container(
            height: 56,
            padding: EdgeInsets.only(left: 16, right: 16),
            alignment: Alignment.center,
            child: Text(
              "搜索",
              style: TextStyle(
                color: BaseColor.accent,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ).onClick(() {
            onEditSubmitted(editingController.text);
          })
        ],
      ),
    );
  }

  Widget bodyWidget() {
    return PageView.builder(
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
    );
  }
}
