class BossTackEvent {
  String id;
  bool isFollow;
  List<String> labels;

  BossTackEvent({this.id, this.isFollow, this.labels});

  @override
  String toString() {
    return 'BossTackEvent{id: $id, isFollow: $isFollow, labels: $labels}';
  }
}
