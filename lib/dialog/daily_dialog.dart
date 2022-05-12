import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/http_config.dart';
import 'package:flutter_boss_says/data/entity/daily_entity.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';

Future<dynamic> showDailyDialog(
  BuildContext context,
  DailyEntity entity, {
  Function(Function) doPoint,
  Function(Function) doFavorite,
  Function doShare,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      double matchParent = MediaQuery.of(context).size.width;
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(R.assetsImgDailyBg),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: matchParent,
              padding: EdgeInsets.only(left: 24),
              margin: EdgeInsets.only(top: 72, bottom: 40),
              child: Text(
                "Boss语录#",
                style: TextStyle(
                  color: BaseColor.textGray,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(left: 28, right: 28),
                child: Stack(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        color: Colors.white,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            R.assetsImgDailyMarks,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ).marginOn(top: 40, left: 22),
                          Expanded(
                            child: Text(
                              entity.content,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                height: 2,
                                fontWeight: FontWeight.w500,
                              ),
                              softWrap: true,
                              textAlign: TextAlign.start,
                              maxLines: 7,
                              overflow: TextOverflow.ellipsis,
                            ).marginOn(
                              left: 22,
                              right: 22,
                              top: 28,
                              bottom: 28,
                            ),
                          ),
                        ],
                      ),
                    ).positionOn(
                      top: 60,
                      bottom: 0,
                      right: 0,
                      left: 0,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      child: Image.network(
                        HttpConfig.fullUrl(entity.bossHead),
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                      ),
                    ).positionOn(right: 22, top: 0),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 72,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            entity.bossName,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                            softWrap: false,
                            maxLines: 1,
                            textAlign: TextAlign.end,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            entity.bossRole,
                            style: TextStyle(
                              color: Color(0xff7a7a7a),
                              fontSize: 12,
                            ),
                            softWrap: false,
                            maxLines: 1,
                            textAlign: TextAlign.end,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ).positionOn(left: 0, right: 102, top: 0),
                  ],
                ),
              ),
            ),
            Container(
              width: matchParent,
              margin: EdgeInsets.only(bottom: 64, top: 40),
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StatefulBuilder(builder: (context, state) {
                    return Container(
                      width: 70,
                      height: 70,
                      padding: EdgeInsets.all(16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 4,
                          color: Color(0x80f0f0f0),
                        ),
                        color: Colors.white,
                      ),
                      child: Image.asset(entity.isPoint
                          ? R.assetsImgPointAccent
                          : R.assetsImgPointGray),
                    ).onClick(() {
                      doPoint(() {
                        state(() {});
                      });
                    });
                  }),
                  StatefulBuilder(builder: (context, state) {
                    return Container(
                      width: 70,
                      height: 70,
                      margin: EdgeInsets.only(left: 36,right: 36),
                      padding: EdgeInsets.all(16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 4,
                          color: Color(0x80efefef),
                        ),
                        color: Colors.white,
                      ),
                      child: Image.asset(entity.isCollect
                          ? R.assetsImgFavoriteAccent
                          : R.assetsImgFavoriteGray),
                    ).onClick(() {
                      doFavorite(() {
                        state(() {});
                      });
                    });
                  }),
                  Container(
                    width: 70,
                    height: 70,
                    padding: EdgeInsets.all(16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 4,
                        color: Color(0x80efefef),
                      ),
                      color: Colors.white,
                    ),
                    child: Image.asset(R.assetsImgShareGray),
                  ).onClick(doShare),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 4),
              alignment: Alignment.center,
              child: Image.asset(
                R.assetsImgDailyQuit,
                width: 26,
                height: 26,
              ),
            ),
            Text(
              "下滑退出",
              style: TextStyle(
                color: Color(0xff7a7a7a),
                fontSize: 10,
              ),
            ).marginOn(bottom: 64),
          ],
        ),
      );
    },
  );
}
