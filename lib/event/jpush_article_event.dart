class JpushArticleEvent {
  String bossId;
  int updateTime;

  JpushArticleEvent({this.bossId, this.updateTime});

  @override
  String toString() {
    return 'JpushArticleEvent{bossId: $bossId, updateTime: $updateTime}';
  }
}
