class EventItem {
  final int? id;
  final DateTime? time;
  final String? device;
  final String? code;
  final String? type;
  final String? desc;
  final String? zone;
  final int priority;

  EventItem({
    this.id,
    this.time,
    this.device,
    this.code,
    this.type,
    this.desc,
    this.zone,
    this.priority = 0,
  });

  factory EventItem.fromJson(Map<String, dynamic> json) {
    return EventItem(
      id: json['id'] as int?,
      time: json['time'] != null
          ? DateTime.parse(json['time'] as String)
          : null,
      device: json['device'] as String?,
      code: json['code'] as String?,
      type: json['type'] as String?,
      desc: json['desc'] as String?,
      zone: json['zone'] as String?,
      priority: json['priority'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': time?.toIso8601String(),
      'device': device,
      'code': code,
      'type': type,
      'desc': desc,
      'zone': zone,
      'priority': priority,
    };
  }
}
