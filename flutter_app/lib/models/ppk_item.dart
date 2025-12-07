class PPKItem {
  final int number;
  final String? name;
  final String? event;
  final DateTime? date;

  PPKItem({required this.number, this.name, this.event, this.date});

  factory PPKItem.fromJson(Map<String, dynamic> json) {
    return PPKItem(
      number: json['number'] as int? ?? 0,
      name: json['name'] as String?,
      event: json['event'] as String?,
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name': name,
      'event': event,
      'date': date?.toIso8601String(),
    };
  }

  bool isTimedOut() {
    if (date == null) return true;
    return DateTime.now().difference(date!).inMinutes > 15;
  }
}
