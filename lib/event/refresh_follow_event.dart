class RefreshFollowEvent {
  String id;
  bool isFollow;
  List<String> labels;
  bool needLoading;

  RefreshFollowEvent(
      {this.id, this.isFollow, this.labels, this.needLoading = true});
}
