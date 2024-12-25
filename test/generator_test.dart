import 'package:flutter_test/flutter_test.dart';
import 'package:secure_qr_generator/secure_qr_generator.dart';
import 'package:secure_qr_generator/src/generation_error.dart';


void main() {
  const testKey = '2024#@#qrcod#orange@##perform#==';

  group('SecureQRGenerator - Configuration standard', () {
    late SecureQRGenerator generator;
    late QRData testData;

    setUp(() {
      final config = GeneratorConfig(
        secretKey: testKey,
        validityDuration: const Duration(minutes: 5),
        enableEncryption: true,
        enableSignature: true,
        dataVersion: 1,
        idPrefix: 'TEST_',
      );

      generator = SecureQRGenerator(config);

      testData = const QRData(
        payload: {
          'id': '123',
          'name': 'Test Product',
          'price': 99.99,
        },
        metadata: {
          'source': 'unit_test',
          'environment': 'test',
        },
        tags: ['test', 'product'],
      );
    });

    test('should generate QR code with correct properties', () async {
      final result = await generator.generateQR(testData);

      expect(result.id.startsWith('TEST_'), isTrue);
      expect(result.isEncrypted, isTrue);
      expect(result.isSigned, isTrue);
      expect(result.qrContent.isNotEmpty, isTrue);

      expect(result.isValid, isTrue);
      expect(result.generatedAt.isBefore(result.expiresAt), isTrue);
      expect(
        result.expiresAt.difference(result.generatedAt),
        const Duration(minutes: 5),
      );
    });

    test('should estimate QR size correctly', () {
      final size = generator.estimateQRSize(testData);

      expect(size, greaterThan(0));
      expect(size, lessThan(2000));
    });

    test('should validate data size', () {
      expect(generator.canEncodeData(testData), isTrue);

      final largeData = QRData(
        payload: {
          'large_field': List.filled(1000, 'very_long_string_that_repeats'),
        },
      );

      expect(generator.canEncodeData(largeData), isFalse);
    });

    test('should generate different IDs for each QR code', () async {
      final result1 = await generator.generateQR(testData);
      final result2 = await generator.generateQR(testData);

      expect(result1.id, isNot(equals(result2.id)));
      expect(result1.qrContent, isNot(equals(result2.qrContent)));
    });

    test('result should provide correct expiration information', () async {
      final result = await generator.generateQR(testData);

      expect(result.timeUntilExpiration, isA<Duration>());
      expect(result.timeUntilExpiration.inMinutes, lessThanOrEqualTo(5));
      expect(result.isValid, isTrue);
    });
  });

  group('SecureQRGenerator - Sans chiffrement ni signature', () {
    late SecureQRGenerator generator;
    late QRData testData;

    setUp(() {
      final config = GeneratorConfig(
        validityDuration: const Duration(minutes: 5),
        enableEncryption: false,
        enableSignature: false,
        dataVersion: 1,
        idPrefix: 'TEST_',
      );

      generator = SecureQRGenerator(config);

      testData = const QRData(
        payload: {'test': 'data'},
      );
    });

    test('should generate unencrypted QR code', () async {
      final result = await generator.generateQR(testData);

      expect(result.isEncrypted, isFalse);
      expect(result.isSigned, isFalse);
    });

    test('should have smaller content size without encryption', () async {
      final resultUnencrypted = await generator.generateQR(testData);

      // Créer un générateur avec chiffrement pour comparer
      final encryptedGenerator = SecureQRGenerator(
        GeneratorConfig(
          secretKey: testKey,
          enableEncryption: true,
        ),
      );

      final resultEncrypted = await encryptedGenerator.generateQR(testData);

      expect(resultUnencrypted.contentSize, lessThan(resultEncrypted.contentSize));
    });
  });

  group('SecureQRGenerator - Gestion des erreurs', () {
    test('should throw on data too large', () async {
      final generator = SecureQRGenerator(GeneratorConfig.development());

      final largeData = QRData(
        payload: {
          'large_field': List.filled(2000, 'very_long_string_that_repeats'),
        },
      );

      expect(
            () => generator.generateQR(largeData),
        throwsA(isA<GenerationError>().having(
              (e) => e.type,
          'error type',
          GenerationErrorType.payloadTooLarge,
        )),
      );
    });

    test('should throw on invalid configuration combinations', () {
      expect(
            () => GeneratorConfig(
          enableEncryption: true,
          enableSignature: true,
        ),
        throwsArgumentError,
      );

      expect(
            () => GeneratorConfig(
          secretKey: 'short',
          enableEncryption: true,
        ),
        throwsArgumentError,
      );

      expect(
            () => GeneratorConfig(
          validityDuration: const Duration(seconds: 0),
        ),
        throwsArgumentError,
      );
    });
  });

  group('SecureQRGenerator - Environnements prédéfinis', () {
    test('development config should have expected values', () {
      final devConfig = GeneratorConfig.development();

      expect(devConfig.enableEncryption, isTrue);
      expect(devConfig.enableSignature, isTrue);
      expect(devConfig.idPrefix, equals('DEV_'));
      expect(devConfig.validityDuration, equals(const Duration(hours: 1)));
    });

    test('production config should enforce security', () {
      final prodConfig = GeneratorConfig.production(
        secretKey: testKey,
      );

      expect(prodConfig.enableEncryption, isTrue);
      expect(prodConfig.enableSignature, isTrue);
      expect(prodConfig.idPrefix, equals('PROD_'));
      expect(prodConfig.validityDuration, equals(const Duration(minutes: 5)));
    });

    test('should throw on weak production configuration', () {
      expect(
            () => GeneratorConfig.production(
          secretKey: 'too_short',
        ),
        throwsArgumentError,
      );
    });
  });
}