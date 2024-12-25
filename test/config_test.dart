import 'package:flutter_test/flutter_test.dart';
import 'package:secure_qr_generator/secure_qr_generator.dart';

void main() {
  group('GeneratorConfig', () {
    test('should create default config', () {
      final config = GeneratorConfig();

      expect(config.secretKey, isNull);
      expect(config.validityDuration, equals(const Duration(minutes: 5)));
      expect(config.enableEncryption, isFalse);
      expect(config.enableSignature, isFalse);
      expect(config.dataVersion, equals(1));
      expect(config.idPrefix, isEmpty);
    });

    test('should create development config', () {
      final config = GeneratorConfig.development();

      expect(config.secretKey, isNotNull);
      expect(config.validityDuration, equals(const Duration(hours: 1)));
      expect(config.enableEncryption, isTrue);
      expect(config.enableSignature, isTrue);
      expect(config.idPrefix, equals('DEV_'));
    });

    test('should create production config', () {
      final config = GeneratorConfig.production(
        secretKey: 'production_secret_key_that_is_long_enough_123456',
      );

      expect(config.secretKey, isNotNull);
      expect(config.validityDuration, equals(const Duration(minutes: 5)));
      expect(config.enableEncryption, isTrue);
      expect(config.enableSignature, isTrue);
      expect(config.idPrefix, equals('PROD_'));
    });

    test('should validate encryption configuration', () {
      // Clé trop courte avec chiffrement activé
      expect(
        () => GeneratorConfig(
          secretKey: 'short',
          enableEncryption: true,
        ),
        throwsArgumentError,
      );

      // Chiffrement activé sans clé
      expect(
        () => GeneratorConfig(
          enableEncryption: true,
        ),
        throwsArgumentError,
      );

      // Configuration valide
      expect(
        () => GeneratorConfig(
          secretKey: 'this_is_a_long_enough_secret_key_123456',
          enableEncryption: true,
        ),
        returnsNormally,
      );
    });

    test('should validate signature configuration', () {
      // Signature activée sans clé
      expect(
        () => GeneratorConfig(
          enableSignature: true,
        ),
        throwsArgumentError,
      );

      // Configuration valide
      expect(
        () => GeneratorConfig(
          secretKey: 'valid_secret_key',
          enableSignature: true,
        ),
        returnsNormally,
      );
    });

    test('should validate validity duration', () {
      // Durée nulle
      expect(
        () => GeneratorConfig(
          validityDuration: const Duration(seconds: 0),
        ),
        throwsArgumentError,
      );

      // Durée négative
      expect(
        () => GeneratorConfig(
          validityDuration: const Duration(seconds: -1),
        ),
        throwsArgumentError,
      );

      // Durée valide
      expect(
        () => GeneratorConfig(
          validityDuration: const Duration(minutes: 1),
        ),
        returnsNormally,
      );
    });

    test('should validate data version', () {
      // Version invalide
      expect(
        () => GeneratorConfig(
          dataVersion: 0,
        ),
        throwsArgumentError,
      );

      expect(
        () => GeneratorConfig(
          dataVersion: -1,
        ),
        throwsArgumentError,
      );

      // Version valide
      expect(
        () => GeneratorConfig(
          dataVersion: 1,
        ),
        returnsNormally,
      );
    });

    test('should validate production config', () {
      // Clé trop courte
      expect(
        () => GeneratorConfig.production(
          secretKey: 'short',
        ),
        throwsArgumentError,
      );

      // Durée de validité personnalisée
      final config = GeneratorConfig.production(
        secretKey: 'production_secret_key_that_is_long_enough_123456',
        validityDuration: const Duration(minutes: 10),
      );

      expect(config.validityDuration, equals(const Duration(minutes: 10)));
    });
  });
}
