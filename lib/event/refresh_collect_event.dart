class RefreshCollectEvent {
  bool fromFolder = false;
  bool doCollect = false;
  String articleId;

  RefreshCollectEvent(
      {this.fromFolder, this.articleId, this.doCollect});
}
