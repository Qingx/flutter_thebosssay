import 'package:flutter/material.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';

Future<dynamic> showShareDialog(BuildContext context, bool needSave,
    {Function(int) doClick, Function onDismiss}) {
  List<Color> colors = [
    Color(0xff50b674),
    Color(0xff6dd400),
    Color(0xff2343c2),
    Color(0xffffa32b)
  ];
  List<String> imgs = [
    R.assetsImgShareWechat,
    R.assetsImgShareTimeline,
    R.assetsImgShareLink,
    R.assetsImgShareSaveImg
  ];
  List<String> names = ["微信好友", "朋友圈", "复制链接", "生成海报"];
  return showModalBottomSheet<void>(
    context: context,
    isDismissible: false,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
    ),
    builder: (context) {
      return Container(
        padding: EdgeInsets.only(top: 16),
        height: 240,
        child: Column(
          children: [
            Text(
              "分享至",
              style: TextStyle(
                color: BaseColor.textDark,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              softWrap: false,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Container(
              height: 80,
              margin: EdgeInsets.only(top: 16),
              child: MediaQuery.removePadding(
                context: context,
                removeBottom: true,
                removeTop: true,
                child: GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.only(left: 16, right: 16),
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                    return Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colors[index],
                            ),
                            child: Image.asset(
                              imgs[index],
                              width: 24,
                              height: 24,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Text(
                            names[index],
                            style: TextStyle(
                              fontSize: 12,
                              color: BaseColor.textDarkLight,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ).marginOn(top: 8)
                        ],
                      ),
                    ).onClick(() {
                      doClick(index);
                    });
                  },
                  itemCount: needSave ? 4 : 3,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 0,
                    crossAxisSpacing: 16,
                    childAspectRatio:
                        80 / (MediaQuery.of(context).size.width - 96),
                  ),
                ),
              ),
            ),
            Container(
              height: 1,
              color: BaseColor.line,
              margin: EdgeInsets.only(top: 16),
            ),
            Container(
              padding: EdgeInsets.only(top: 16, bottom: 16),
              alignment: Alignment.center,
              child: Text(
                "取消",
                style: TextStyle(fontSize: 16, color: BaseColor.textGray),
                textAlign: TextAlign.center,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
            ).onClick(onDismiss),
          ],
        ),
      );
    },
  );
}
