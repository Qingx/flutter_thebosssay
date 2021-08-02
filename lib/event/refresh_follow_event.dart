class RefreshFollowEvent {
  String id;
  bool isFollow;
  bool needLoading;

  RefreshFollowEvent({this.id, this.isFollow, this.needLoading = true});
}
