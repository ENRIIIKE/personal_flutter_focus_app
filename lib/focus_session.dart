class FocusSession {
  final String id;
  final int secondsSpend;
  final String tag;

  FocusSession({
    required this.id,
    required this.secondsSpend,
    required this.tag,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'secondsSpend': secondsSpend,
      'tag': tag,
    };
  }
}