enum PayloadType {
  normal,
  frontInject,
  backInject,
  frontQuery,
  backQuery,
  websocket,
  sni,
}

extension PayloadTypeLabel on PayloadType {
  String get label => switch (this) {
        PayloadType.normal => 'Normal',
        PayloadType.frontInject => 'Front inject',
        PayloadType.backInject => 'Back inject',
        PayloadType.frontQuery => 'Front query',
        PayloadType.backQuery => 'Back query',
        PayloadType.websocket => 'WebSocket',
        PayloadType.sni => 'SNI',
      };
}

class PayloadSpec {
  const PayloadSpec({
    required this.host,
    required this.port,
    required this.method,
    required this.protocol,
    required this.type,
    this.userAgent = '',
    this.headers = const {},
    this.split = false,
  });

  final String host;
  final int port;
  final String method;
  final String protocol;
  final PayloadType type;
  final String userAgent;
  final Map<String, String> headers;
  final bool split;

  PayloadSpec copyWith({
    String? host,
    int? port,
    String? method,
    String? protocol,
    PayloadType? type,
    String? userAgent,
    Map<String, String>? headers,
    bool? split,
  }) =>
      PayloadSpec(
        host: host ?? this.host,
        port: port ?? this.port,
        method: method ?? this.method,
        protocol: protocol ?? this.protocol,
        type: type ?? this.type,
        userAgent: userAgent ?? this.userAgent,
        headers: headers ?? this.headers,
        split: split ?? this.split,
      );
}

class PayloadResult {
  const PayloadResult({
    required this.payload,
    required this.warnings,
    required this.errors,
  });

  final String payload;
  final List<String> warnings;
  final List<String> errors;

  bool get isValid => errors.isEmpty;
}

class HistoryEntry {
  const HistoryEntry({
    required this.id,
    required this.title,
    required this.payload,
    required this.createdAt,
    this.favorite = false,
  });

  final String id;
  final String title;
  final String payload;
  final DateTime createdAt;
  final bool favorite;

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'payload': payload,
        'createdAt': createdAt.toIso8601String(),
        'favorite': favorite,
      };

  factory HistoryEntry.fromJson(Map<String, Object?> json) => HistoryEntry(
        id: json['id']! as String,
        title: json['title']! as String,
        payload: json['payload']! as String,
        createdAt: DateTime.parse(json['createdAt']! as String),
        favorite: json['favorite'] as bool? ?? false,
      );
}
