class Shift {
  final String id; // Unique ID for the shift
  final String title; // Shift title or label
  final DateTime start; // Start time of the shift
  final DateTime end; // End time of the shift
  final double? hourlyRate; // Optional custom hourly pay rate

  Shift({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    this.hourlyRate,
  });

  Duration get duration => end.difference(start); // Total shift duration

  double get hours => duration.inMinutes / 60.0; // Duration in hours

  double get earnings {
    final rate = hourlyRate ?? 200; // Fallback to 200 if no rate provided
    return hours * rate;
  }

  // Create a copy of this shift with optional overrides
  Shift copyWith({
    String? id,
    String? title,
    DateTime? start,
    DateTime? end,
    double? hourlyRate,
  }) {
    return Shift(
      id: id ?? this.id,
      title: title ?? this.title,
      start: start ?? this.start,
      end: end ?? this.end,
      hourlyRate: hourlyRate ?? this.hourlyRate,
    );
  }

  // Helpful for debugging
  @override
  String toString() {
    return 'Shift(title: $title, start: $start, end: $end, hours: ${hours.toStringAsFixed(2)})';
  }

  // Equality check
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