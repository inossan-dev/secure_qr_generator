import 'package:flutter_test/flutter_test.dart';
import 'package:secure_qr_generator/src/generation_error.dart';

void main() {
  group('GenerationError', () {
    test('should create error with minimal data', () {
      final error = GenerationError(
        type: GenerationErrorType.configuration,
        message: 'Test error',
      );

      expect(error.type, equals(GenerationErrorType.configuration));
      expect(error.message, equals('Test error'));
      expect(error.details, isNull);
    });

    test('should create error with details', () {
      final error = GenerationError(
        type: GenerationErrorType.encryption,
        message: 'Test error',
        details: {'key': 'value'},
      );

      expect(error.type, equals(GenerationErrorType.encryption));
      expect(error.message, equals('Test error'));
      expect(error.details, equals({'key': 'value'}));
    });

    test('toString should format message correctly', () {
      final error = GenerationError(
        type: GenerationErrorType.signature,
        message: 'Test error',
      );

      expect(error.toString(),
          equals('GenerationError(GenerationErrorType.signature): Test error'));
    });

    test('should cover all error types', () {
      // Vérifie que tous les types d'erreur sont utilisables
      const types = GenerationErrorType.values;

      expect(types, contains(GenerationErrorType.configuration));
      expect(types, contains(GenerationErrorType.encryption));
      expect(types, contains(GenerationErrorType.signature));
      expect(types, contains(GenerationErrorType.serialization));
      expect(types, contains(GenerationErrorType.payloadTooLarge));
      expect(types, contains(GenerationErrorType.unknown));
    });
  });
}
