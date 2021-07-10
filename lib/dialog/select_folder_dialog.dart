import 'package:flutter/material.dart';
import 'package:flutter_boss_says/data/entity/favorite_entity.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';

Future<dynamic> showSelectFolderDialog(
    BuildContext context, List<FavoriteEntity> mData,
    {Function onDismiss, Function(String) onConfirm, Function onCreate}) {
  String selectId = mData[0].id;

  Widget folderItemWidget(FavoriteEntity entity, int index, Function state) {
    bool hasSelect = selectId == entity.id;
    return Container(
      height: 45,
      child: Column(
        children: [
          Container(
            height: 44,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.check,
                  color: hasSelect ? BaseColor.accent : Colors.transparent,
                  size: 20,
                ),
                Text(
                  entity.name,
                  style: TextStyle(
                      fontSize: 16,
                      color: BaseColor.accent,
                      fontWeight: FontWeight.bold),
                  softWrap: false,
                  maxLines: 1,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                ).marginOn(left: 16),
                Expanded(child: SizedBox()),
                Text(
                  "${entity.list.length}篇言论",
                  style: TextStyle(
                      fontSize: 16,
                      color: BaseColor.textDark,
                      fontWeight: FontWeight.bold),
                  softWrap: false,
                  maxLines: 1,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            height: 1,
            color: BaseColor.line,
          )
        ],
      ),
    ).onClick(() {
      if (selectId != entity.id) {
        selectId = entity.id;
        state();
      }
    });
  }

  return showDialog(
    barrierDismissible: true,
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, state) {
        return Container(
          alignment: Alignment.topCenter,
          margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 4),
          child: Material(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            child: Container(
              width: MediaQuery.of(context).size.width - 32,
              height: 320,
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "收藏到",
                        style: TextStyle(
                            fontSize: 18,
                            color: BaseColor.textDark,
                            fontWeight: FontWeight.bold),
                        maxLines: 1,
                        softWrap: false,
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 4, bottom: 4),
                        alignment: Alignment.center,
                        child: Row(
                          children: [
                            Icon(
                              Icons.add,
                              color: BaseColor.accent,
                              size: 16,
                            ),
                            Text(
                              "新建",
                              style: TextStyle(
                                  fontSize: 14, color: BaseColor.accent),
                              softWrap: false,
                              textAlign: TextAlign.end,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ).onClick(onCreate),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 16),
                    height: 1,
                    color: BaseColor.line,
                  ),
                  Flexible(
                    child: MediaQuery.removePadding(
                      removeBottom: true,
                      removeTop: true,
                      context: context,
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          return folderItemWidget(mData[index], index, () {
                            state(() {});
                          });
                        },
                        itemCount: mData.length,
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          height: 36,
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(top: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                            color: BaseColor.loadBg,
                          ),
                          child: Text(
                            "取消",
                            style: TextStyle(
                              fontSize: 14,
                              color: BaseColor.textDark,
                              fontWeight: FontWeight.w500,
                            ),
                            softWrap: false,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ).onClick(onDismiss),
                      ),
                      Expanded(
                        child: Container(
                          height: 36,
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(left: 16, top: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                            color: BaseColor.accent,
                          ),
                          child: Text(
                            "确认",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            softWrap: false,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ).onClick(() {
                          onConfirm(selectId);
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      });
    },
  );
}
