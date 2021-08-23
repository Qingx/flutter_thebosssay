import 'package:flutter/material.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:get/get.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key key}) : super(key: key);

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  List<String> data = [];

  @override
  void initState() {
    super.initState();

    data = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          children: [
            Container(
              child: BaseWidget.statusBar(context, true),
            ),
            Container(
              height: 44,
              padding: EdgeInsets.only(left: 12, right: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_back,
                    color: BaseColor.textDark,
                    size: 28,
                  ).onClick(() {
                    Get.back();
                  }),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: 28),
                      alignment: Alignment.center,
                      child: Text(
                        "测试页面",
                        style: TextStyle(
                            fontSize: 16,
                            color: BaseColor.textDark,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            testWidget(),
          ],
        ),
      ),
    );
  }

  Widget testWidget() {
    return Container(
      height: 160,
      margin: EdgeInsets.only(left: 16, right: 16),
      child: Swiper(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Image.asset(R.assetsImgTestPhoto, fit: BoxFit.cover);
        },
        pagination: SwiperPagination(
          alignment: Alignment.bottomCenter,
          margin: EdgeInsets.only(bottom: 2),
          builder: DotSwiperPaginationBuilder(
              activeColor: Colors.white,
              color: Colors.grey,
              size: 8,
              activeSize: 8),
        ),
        autoplay: true,
        autoplayDelay: 4000,
        autoplayDisableOnInteraction: true,
      ),
    );
  }
}
