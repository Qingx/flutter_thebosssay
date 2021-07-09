import 'package:flutter_boss_says/config/base_data.dart';
import 'package:flutter_boss_says/config/page_data.dart';

class BasePage<T> extends DataSource {
  int timestamps;
  int status;
  String msg;
  Page<T> data;

  BasePage({this.timestamps, this.status, this.data});

  BasePage.fromJson(Map<String, dynamic> json) {
    msg = json['msg'].toString();
    timestamps = json['timestamps'];
    status = int.parse(json['status']);
    data = Page.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = Map<String, dynamic>();
    map['timestamps'] = this.timestamps;
    map['status'] = this.status;
    map['msg'] = this.msg;
    map['data'] = this.data;
    return map;
  }

  bool get success => status > 0;

  @override
  bool get isDataEmpty {
    if (data == null) return true;

    return data.isDataEmpty;
  }

  @override
  int get code => status;
}

/// 转换WlData数据
BasePage<T> json2WLPage<T>(Map<String, dynamic> map) {
  return BasePage.fromJson(map);
}
