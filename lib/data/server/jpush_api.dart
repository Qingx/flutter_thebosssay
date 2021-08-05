import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:rxdart/rxdart.dart';

class JpushApi {
  JPush jPush;

  JpushApi._() {
    jPush = JPush();
  }

  static JpushApi _mIns;

  factory JpushApi.ins() => _mIns ??= JpushApi._();

  ///添加别名
  void addAlias(String alias, {int count = 6}) {
    if (count <= 0) {
      return;
    }
    jPush.setAlias(alias).then((value) {
      print("JpushAddAlias=>$value");
    }, onError: (e, s) {
      print(e);
      Observable.timer(0, Duration(milliseconds: 500)).listen((event) {
        addAlias(alias, count: count - 1);
      });
    });
  }

  ///添加tags
  void addTags(List<String> tags, {int count = 6}) {
    if (count <= 0) {
      return;
    }

    jPush.addTags(tags).then((value) {
      print("JpushAddTags=>$value");
    }, onError: (e, s) {
      print(e);
      Observable.timer(0, Duration(milliseconds: 500)).listen((event) {
        addTags(tags, count: count - 1);
      });
    });
  }

  ///删除tags
  void deleteTags(List<String> tags, {int count = 6}) {
    if (count <= 0) {
      return;
    }

    jPush.deleteTags(tags).then((value) {
      print("JpushDeleteTags=>$value");
    }, onError: (e, s) {
      print(e);
      Observable.timer(0, Duration(milliseconds: 500)).listen((event) {
        deleteTags(tags, count: count - 1);
      });
    });
  }

  ///清空所有tags
  void clearTags({int count = 6}) {
    if (count <= 0) {
      return;
    }

    jPush.cleanTags().then((value) {
      print("JpushCleanTags=>$value");
    }, onError: (e, s) {
      print(e);
      Observable.timer(0, Duration(milliseconds: 500)).listen((event) {
        clearTags(count: count - 1);
      });
    });
  }

  ///获取所有tags
  void getAllTags() {
    jPush.getAllTags().then((value) {
      print("JpushGetAllTags=>$value");
    }, onError: (e, s) {
      print(e);
    });
  }
}
