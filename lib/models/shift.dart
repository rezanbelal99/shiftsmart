class Shift {
  final String id;
  final String title;
  final DateTime start;
  final DateTime end;

  Shift({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
  });

  Duration get duration => end.difference(start);

  // Optional: get hours as decimal
  double get hours => duration.inMinutes / 60.0;

  // Optional: for easier debugging
  @override
  String toString() {
    return 'Shift(title: $title, start: $start, end: $end, hours: ${hours.toStringAsFixed(2)})';
  }

  // Optional: for comparison in Redux
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Shift &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ start.hashCode ^ end.hashCode;
}