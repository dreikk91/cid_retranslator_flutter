class StatsData {
  final bool connected;
  final int accepted;
  final int rejected;
  final int reconnects;
  final String uptime;

  StatsData({
    required this.connected,
    required this.accepted,
    required this.rejected,
    required this.reconnects,
    required this.uptime,
  });

  factory StatsData.fromJson(Map<String, dynamic> json) {
    return StatsData(
      connected: json['connected'] as bool,
      accepted: json['accepted'] as int,
      rejected: json['rejected'] as int,
      reconnects: json['reconnects'] as int,
      uptime: json['uptime'] as String,
    );
  }

  factory StatsData.initial() {
    return StatsData(
      connected: false,
      accepted: 0,
      rejected: 0,
      reconnects: 0,
      uptime: '00:00:00',
    );
  }
}
