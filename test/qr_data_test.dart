import 'package:flutter_test/flutter_test.dart';
import 'package:secure_qr_generator/secure_qr_generator.dart';

void main() {
  group('QRData', () {
    test('should create QRData with minimal data', () {
      const data = QRData(payload: {'test': 'value'});

      expect(data.payload, equals({'test': 'value'}));
      expect(data.metadata, isNull);
      expect(data.tags, isNull);
    });

    test('should create QRData with all fields', () {
      const data = QRData(
        payload: {'test': 'value'},
        metadata: {'version': '1.0'},
        tags: ['test', 'demo'],
      );

      expect(data.payload, equals({'test': 'value'}));
      expect(data.metadata, equals({'version': '1.0'}));
      expect(data.tags, equals(['test', 'demo']));
    });

    test('toMap should include only non-null fields', () {
      const minimalData = QRData(payload: {'test': 'value'});
      const fullData = QRData(
        payload: {'test': 'value'},
        metadata: {'version': '1.0'},
        tags: ['test', 'demo'],
      );

      expect(
          minimalData.toMap(),
          equals({
            'payload': {'test': 'value'},
          }));

      expect(
          fullData.toMap(),
          equals({
            'payload': {'test': 'value'},
            'metadata': {'version': '1.0'},
            'tags': ['test', 'demo'],
          }));
    });

    test('toMap should handle empty tags list', () {
      const data = QRData(
        payload: {'test': 'value'},
        tags: [],
      );

      expect(
          data.toMap(),
          equals({
            'payload': {'test': 'value'},
          }));
    });
  });
}
