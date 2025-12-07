class AppConfig {
  ServerConfig server;
  ClientConfig client;
  QueueConfig queue;
  LoggingConfig logging;
  CIDRulesConfig cidRules;
  MonitoringConfig monitoring;
  UIConfig ui;
  HTTPConfig http;

  AppConfig({
    required this.server,
    required this.client,
    required this.queue,
    required this.logging,
    required this.cidRules,
    required this.monitoring,
    required this.ui,
    required this.http,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      server: ServerConfig.fromJson(json['server'] ?? {}),
      client: ClientConfig.fromJson(json['client'] ?? {}),
      queue: QueueConfig.fromJson(json['queue'] ?? {}),
      logging: LoggingConfig.fromJson(json['logging'] ?? {}),
      cidRules: CIDRulesConfig.fromJson(json['cidrules'] ?? {}),
      monitoring: MonitoringConfig.fromJson(json['monitoring'] ?? {}),
      ui: UIConfig.fromJson(json['ui'] ?? {}),
      http: HTTPConfig.fromJson(json['http'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'server': server.toJson(),
      'client': client.toJson(),
      'queue': queue.toJson(),
      'logging': logging.toJson(),
      'cidrules': cidRules.toJson(),
      'monitoring': monitoring.toJson(),
      'ui': ui.toJson(),
      'http': http.toJson(),
    };
  }
}

class ServerConfig {
  String host;
  String port;
  int maxDeviceEvents;
  int maxGlobalEvents;

  ServerConfig({
    required this.host,
    required this.port,
    this.maxDeviceEvents = 100,
    this.maxGlobalEvents = 500,
  });

  factory ServerConfig.fromJson(Map<String, dynamic> json) {
    return ServerConfig(
      host: json['host'] ?? '0.0.0.0',
      port: json['port'] ?? '20005',
      maxDeviceEvents: json['maxdeviceevents'] ?? 100,
      maxGlobalEvents: json['maxglobalevents'] ?? 500,
    );
  }

  Map<String, dynamic> toJson() => {
    'host': host,
    'port': port,
    'maxdeviceevents': maxDeviceEvents,
    'maxglobalevents': maxGlobalEvents,
  };
}

class ClientConfig {
  String host;
  String port;
  String reconnectInitial;
  String reconnectMax;

  ClientConfig({
    required this.host,
    required this.port,
    this.reconnectInitial = '1s',
    this.reconnectMax = '60s',
  });

  factory ClientConfig.fromJson(Map<String, dynamic> json) {
    return ClientConfig(
      host: json['host'] ?? '10.32.1.49',
      port: json['port'] ?? '20004',
      reconnectInitial: json['reconnectinitial']?.toString() ?? '1s',
      reconnectMax: json['reconnectmax']?.toString() ?? '60s',
    );
  }

  Map<String, dynamic> toJson() => {
    'host': host,
    'port': port,
    'reconnectinitial': reconnectInitial,
    'reconnectmax': reconnectMax,
  };
}

class QueueConfig {
  int bufferSize;

  QueueConfig({this.bufferSize = 100});

  factory QueueConfig.fromJson(Map<String, dynamic> json) {
    return QueueConfig(bufferSize: json['buffersize'] ?? 100);
  }

  Map<String, dynamic> toJson() => {'buffersize': bufferSize};
}

class LoggingConfig {
  String filename;
  int maxSize;
  int maxBackups;
  int maxAge;
  bool compress;
  String level;

  LoggingConfig({
    required this.filename,
    this.maxSize = 10,
    this.maxBackups = 5,
    this.maxAge = 28,
    this.compress = true,
    this.level = 'INFO',
  });

  factory LoggingConfig.fromJson(Map<String, dynamic> json) {
    return LoggingConfig(
      filename: json['filename'] ?? 'app.log',
      maxSize: json['maxsize'] ?? 10,
      maxBackups: json['maxbackups'] ?? 5,
      maxAge: json['maxage'] ?? 28,
      compress: json['compress'] ?? true,
      level: json['level'] ?? 'INFO',
    );
  }

  Map<String, dynamic> toJson() => {
    'filename': filename,
    'maxsize': maxSize,
    'maxbackups': maxBackups,
    'maxage': maxAge,
    'compress': compress,
    'level': level,
  };
}

class CIDRulesConfig {
  String requiredPrefix;
  int validLength;
  Map<String, String> testCodeMap;
  int accNumOffset;
  int accNumAdd;

  CIDRulesConfig({
    this.requiredPrefix = '5',
    this.validLength = 21,
    required this.testCodeMap,
    this.accNumOffset = 2100,
    this.accNumAdd = 2100,
  });

  factory CIDRulesConfig.fromJson(Map<String, dynamic> json) {
    return CIDRulesConfig(
      requiredPrefix: json['requiredprefix'] ?? '5',
      validLength: json['validlength'] ?? 21,
      testCodeMap: Map<String, String>.from(json['testcodemap'] ?? {}),
      accNumOffset: json['accnumoffset'] ?? 2100,
      accNumAdd: json['accnumadd'] ?? 2100,
    );
  }

  Map<String, dynamic> toJson() => {
    'requiredprefix': requiredPrefix,
    'validlength': validLength,
    'testcodemap': testCodeMap,
    'accnumoffset': accNumOffset,
    'accnumadd': accNumAdd,
  };
}

class MonitoringConfig {
  String ppkTimeout;

  MonitoringConfig({this.ppkTimeout = '15m'});

  factory MonitoringConfig.fromJson(Map<String, dynamic> json) {
    return MonitoringConfig(
      ppkTimeout: json['ppktimeout']?.toString() ?? '15m',
    );
  }

  Map<String, dynamic> toJson() => {'ppktimeout': ppkTimeout};
}

class UIConfig {
  bool startMinimized;
  bool minimizeToTray;
  bool closeToTray;

  UIConfig({
    this.startMinimized = false,
    this.minimizeToTray = false,
    this.closeToTray = false,
  });

  factory UIConfig.fromJson(Map<String, dynamic> json) {
    return UIConfig(
      startMinimized: json['startminimized'] ?? false,
      minimizeToTray: json['minimizetotray'] ?? false,
      closeToTray: json['closetotray'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'startminimized': startMinimized,
    'minimizetotray': minimizeToTray,
    'closetotray': closeToTray,
  };
}

class HTTPConfig {
  bool enabled;
  String host;
  String port;

  HTTPConfig({this.enabled = true, this.host = '0.0.0.0', this.port = '8080'});

  factory HTTPConfig.fromJson(Map<String, dynamic> json) {
    return HTTPConfig(
      enabled: json['enabled'] ?? true,
      host: json['host'] ?? '0.0.0.0',
      port: json['port'] ?? '8080',
    );
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'host': host,
    'port': port,
  };
}
