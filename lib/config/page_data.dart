import 'package:flutter_boss_says/generated/json/base/json_convert_content.dart';

class Page<T> {

  int size;
  int pages;
  int total;
  int current;
  bool searchCount = false;

  List<T> records;

  Page(
      {this.size,
      this.pages,
      this.total,
      this.current,
      this.searchCount,
      this.records});

  /// 判断是否还有分页
  bool get hasData => current < pages;

  /// 判断分页列表是否为空
  bool get isDataEmpty => records?.isEmpty ?? true;

  Page.fromJson(Map<String, dynamic> json) {
    size = json['size'];
    pages = json['pages'];
    total = json['total'];
    current = json['current'];
    records = JsonConvert.fromJsonAsT(json['records']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = Map<String, dynamic>();
    map['size'] = this.size;
    map['pages'] = this.pages;
    map['total'] = this.total;
    map['current'] = this.current;
    map['records'] = this.records;
    return map;
  }

  @override
  String toString() {
    return 'Page{size: $size, pages: $pages, total: $total, current: $current, searchCount: $searchCount, records: $records}';
  }
}


