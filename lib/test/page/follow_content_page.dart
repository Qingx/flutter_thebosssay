import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_page_controller.dart';
import 'package:flutter_boss_says/data/entity/article_entity.dart';
import 'package:flutter_boss_says/data/server/boss_api.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_boss_says/config/page_data.dart' as WlPage;

class FollowContentPage extends StatefulWidget {
  String label;

  FollowContentPage(this.label, {Key key}) : super(key: key);

  @override
  _FollowContentPageState createState() => _FollowContentPageState();
}

class _FollowContentPageState extends State<FollowContentPage>
    with AutomaticKeepAliveClientMixin, BasePageController<ArticleEntity> {
  ScrollController scrollController;
  EasyRefreshController controller;

  var builderFuture;

  bool hasData = false;
  int totalArticleNumber;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Text(widget.label),
    );
  }

  @override
  void dispose() {
    super.dispose();

    controller?.dispose();
    scrollController?.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void loadData(bool loadMore) {}

  Future<WlPage.Page<ArticleEntity>> loadInitData() {
    return BossApi.ins()
        .obtainFollowBossList(widget.label, true)
        .flatMap((value) {
      return BossApi.ins().obtainFollowArticle(pageParam);
    }).last;
  }
}
