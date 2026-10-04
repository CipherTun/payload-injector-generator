import 'package:flutter_test/flutter_test.dart';
import 'package:payloadlab/domain/payload.dart';
import 'package:payloadlab/domain/payload_engine.dart';

void main() {
  final engine = PayloadEngine();

  test('normal payload contains host and CRLF terminator', () {
    final result = engine.generate(const PayloadSpec(
      host: 'example.com',
      port: 443,
      method: 'CONNECT',
      protocol: 'HTTP/1.1',
      type: PayloadType.normal,
    ));
    expect(result.isValid, isTrue);
    expect(result.payload, contains('CONNECT example.com:443 HTTP/1.1'));
    expect(result.payload, contains('Host: example.com'));
    expect(result.payload, endsWith('\r\n\r\n'));
  });

  test('invalid port is rejected', () {
    final result = engine.generate(const PayloadSpec(
      host: 'example.com',
      port: 70000,
      method: 'GET',
      protocol: 'HTTP/1.1',
      type: PayloadType.normal,
    ));
    expect(result.isValid, isFalse);
  });

  test('base64 round trip works', () {
    const input = 'hello\r\nworld';
    expect(engine.fromBase64(engine.toBase64(input)), input);
  });

  test('hex round trip works', () {
    const input = 'hello';
    expect(engine.fromHex(engine.toHex(input)), input);
  });

  test('raw validation catches missing terminator', () {
    expect(engine.validateRaw('GET example.com HTTP/1.1'), isNotEmpty);
  });
}
