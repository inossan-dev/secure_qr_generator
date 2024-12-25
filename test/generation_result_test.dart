import 'package:flutter_test/flutter_test.dart';
import 'package:secure_qr_generator/secure_qr_generator.dart';

void main() {
  group('GenerationResult', () {
    late GenerationResult result;

    setUp(() {
      final now = DateTime.now();
      result = GenerationResult(
        qrContent: 'test_content',
        id: 'test_id',
        generatedAt: now,
        expiresAt: now.add(const Duration(minutes: 5)),
        isEncrypted: true,
        isSigned: true,
        contentSize: 100,
      );
    });

    test('should create GenerationResult with all fields', () {
      expect(result.qrContent, equals('test_content'));
      expect(result.id, equals('test_id'));
      expect(result.isEncrypted, isTrue);
      expect(result.isSigned, isTrue);
      expect(result.contentSize, equals(100));
    });

    test('should calculate validity correctly', () {
      expect(result.isValid, isTrue);

      final expiredResult = GenerationResult(
        qrContent: 'test_content',
        id: 'test_id',
        generatedAt: DateTime.now().subtract(const Duration(minutes: 10)),
        expiresAt: DateTime.now().subtract(const Duration(minutes: 5)),
        isEncrypted: true,
        isSigned: true,
        contentSize: 100,
      );

      expect(expiredResult.isValid, isFalse);
    });

    test('should calculate timeUntilExpiration correctly', () {
      expect(result.timeUntilExpiration.inMinutes, lessThanOrEqualTo(5));
      expect(result.timeUntilExpiration.isNegative, isFalse);

      final expiredResult = GenerationResult(
        qrContent: 'test_content',
        id: 'test_id',
        generatedAt: DateTime.now().subtract(const Duration(minutes: 10)),
        expiresAt: DateTime.now().subtract(const Duration(minutes: 5)),
        isEncrypted: true,
        isSigned: true,
        contentSize: 100,
      );

      expect(expiredResult.timeUntilExpiration.isNegative, isTrue);
    });

    test('toMap should include all fields', () {
      final map = result.toMap();

      expect(map['qrContent'], equals('test_content'));
      expect(map['id'], equals('test_id'));
      expect(map['isEncrypted'], isTrue);
      expect(map['isSigned'], isTrue);
      expect(map['contentSize'], equals(100));
      expect(map['isValid'], isTrue);
      expect(map['timeUntilExpiration'], isA<int>());
      expect(map['generatedAt'], isA<String>());
      expect(map['expiresAt'], isA<String>());
    });
  });
}
