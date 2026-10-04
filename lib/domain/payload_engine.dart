import 'dart:convert';

import 'payload.dart';

class PayloadEngine {
  PayloadResult generate(PayloadSpec spec) {
    final errors = <String>[];
    final warnings = <String>[];

    final host = spec.host.trim();
    if (host.isEmpty) errors.add('Host is required.');
    if (host.contains(RegExp(r'[\r\n]'))) {
      errors.add('Host must not contain CR or LF characters.');
    }
    if (spec.port < 1 || spec.port > 65535) {
      errors.add('Port must be between 1 and 65535.');
    }
    if (spec.method.trim().isEmpty) errors.add('HTTP method is required.');
    if (spec.protocol.trim().isEmpty) errors.add('Protocol is required.');

    for (final entry in spec.headers.entries) {
      if (entry.key.trim().isEmpty) errors.add('Header name cannot be empty.');
      if (entry.key.contains(RegExp(r'[\r\n:]'))) {
        errors.add('Header names cannot contain CR, LF, or colon.');
      }
      if (entry.value.contains(RegExp(r'[\r\n]'))) {
        errors.add('Header values cannot contain CR or LF characters.');
      }
    }

    if (errors.isNotEmpty) {
      return PayloadResult(payload: '', warnings: warnings, errors: errors);
    }

    const crlf = '\r\n';
    final authority = '$host:${spec.port}';
    final method = spec.method.trim().toUpperCase();
    final protocol = spec.protocol.trim();

    String request;
    switch (spec.type) {
      case PayloadType.normal:
      case PayloadType.sni:
        request = '$method $authority $protocol$crlf';
      case PayloadType.frontInject:
        request =
            'GET http://$host/ $protocol$crlf${_header('Host', host)}$crlf'
            '$method $authority $protocol$crlf';
      case PayloadType.backInject:
        request =
            '$method $authority $protocol$crlf$crlf'
            'GET http://$host/ $protocol$crlf${_header('Host', host)}';
      case PayloadType.frontQuery:
        request = '$method $host@$authority $protocol$crlf';
      case PayloadType.backQuery:
        request = '$method $authority@$host $protocol$crlf';
      case PayloadType.websocket:
        request =
            '$method $authority $protocol$crlf'
            '${_header('Upgrade', 'websocket')}$crlf'
            '${_header('Connection', 'Upgrade')}$crlf';
    }

    final buffer = StringBuffer(request);

    final hasHost = spec.type == PayloadType.frontInject ||
        spec.type == PayloadType.backInject ||
        spec.type == PayloadType.websocket;

    if (!hasHost && spec.type != PayloadType.frontQuery && spec.type != PayloadType.backQuery) {
      buffer.write(_header('Host', host));
      buffer.write(crlf);
    }

    if (spec.userAgent.trim().isNotEmpty) {
      buffer.write(_header('User-Agent', spec.userAgent.trim()));
      buffer.write(crlf);
    }

    for (final entry in spec.headers.entries) {
      if (entry.key.toLowerCase() == 'host' && hasHost) continue;
      buffer.write(_header(entry.key.trim(), entry.value));
      buffer.write(crlf);
    }

    buffer.write(crlf);
    var result = buffer.toString();

    if (spec.split) {
      result = result.replaceFirst('$crlf${_header('Host', host)}', '[split]$crlf${_header('Host', host)}');
      warnings.add('Split marker is an application-level marker; it is not transmitted as literal text by this engine.');
    }

    if (spec.type == PayloadType.sni) {
      warnings.add('SNI is a TLS-layer setting and cannot be encoded into an HTTP request line.');
    }

    return PayloadResult(payload: result, warnings: warnings, errors: errors);
  }

  String _header(String name, String value) => '$name: $value';

  String toBase64(String value) => base64Encode(utf8.encode(value));
  String fromBase64(String value) => utf8.decode(base64Decode(value.trim()));

  String toUrl(String value) => Uri.encodeComponent(value);
  String fromUrl(String value) => Uri.decodeComponent(value);

  String toHex(String value) =>
      utf8.encode(value).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');

  String fromHex(String value) {
    final clean = value.replaceAll(RegExp(r'[\s:]'), '');
    if (clean.length.isOdd || !RegExp(r'^[0-9a-fA-F]*$').hasMatch(clean)) {
      throw const FormatException('Invalid hexadecimal input.');
    }
    final bytes = <int>[];
    for (var i = 0; i < clean.length; i += 2) {
      bytes.add(int.parse(clean.substring(i, i + 2), radix: 16));
    }
    return utf8.decode(bytes);
  }

  List<String> validateRaw(String value) {
    final errors = <String>[];
    final lines = value.split('\r\n');

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.contains('\n')) {
        errors.add('Line ${i + 1}: bare LF detected.');
      }
      if (i == 0 && line.isNotEmpty && !line.contains(' ')) {
        errors.add('First line does not appear to contain a method, target, and protocol.');
      }
    }

    final headerEnd = value.indexOf('\r\n\r\n');
    if (headerEnd < 0 && value.isNotEmpty) {
      errors.add('No HTTP-style header terminator (CRLF CRLF) found.');
    }

    return errors;
  }
}
