import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:secure_qr_generator/secure_qr_generator.dart';
import 'package:uuid/uuid.dart';

/// Main generator for secure QR codes.
/// This class implements all generation logic, including:
/// - Data encryption
/// - Digital signature
/// - Metadata management
/// - Timestamping
class SecureQRGenerator {
  /// Generator configuration
  final GeneratorConfig config;

  /// AES encrypter instance (null if encryption is disabled)
  final Encrypter? _encrypter;

  /// Unique identifier generator
  final Uuid _uuid;

  /// Creates a new generator with the specified configuration
  SecureQRGenerator(this.config)
      : _encrypter = config.enableEncryption && config.secretKey != null
            ? Encrypter(AES(Key.fromUtf8(config.secretKey!.padRight(32))))
            : null,
        _uuid = const Uuid();

  /// Generates a secure QR code from the provided data
  Future<GenerationResult> generateQR(QRData data) async {
    try {
      // Generate unique identifier
      final id = '${config.idPrefix}${_uuid.v4()}';
      final now = DateTime.now();

      // Build complete payload
      final fullPayload = {
        'data': data.toMap(),
        'id': id,
        'timestamp': now.millisecondsSinceEpoch,
        'version': config.dataVersion,
      };

      // Add signature if enabled
      if (config.enableSignature) {
        fullPayload['signature'] = _generateSignature(fullPayload);
      }

      // JSON serialization
      final jsonPayload = jsonEncode(fullPayload);

      // Size verification (estimate of final QR size)
      if (jsonPayload.length > 2000) {
        // Arbitrary limit for this example
        throw GenerationError(
          type: GenerationErrorType.payloadTooLarge,
          message: 'Payload too large',
          details: {'size': jsonPayload.length, 'maxSize': 2000},
        );
      }

      // Encryption if enabled
      final String finalContent;
      final bool isEncrypted;
      if (config.enableEncryption && _encrypter != null) {
        try {
          // Create unique IV for each generation
          final iv = IV.fromSecureRandom(16);
          final encrypted = _encrypter!.encrypt(jsonPayload, iv: iv);
          // Combine IV and encrypted data
          final combined = iv.bytes + encrypted.bytes;
          finalContent = base64Encode(combined);
          isEncrypted = true;
        } catch (e) {
          throw GenerationError(
            type: GenerationErrorType.encryption,
            message: 'Error during encryption',
            details: {'error': e.toString()},
          );
        }
      } else {
        finalContent = base64Encode(utf8.encode(jsonPayload));
        isEncrypted = false;
      }

      // Create result
      return GenerationResult(
        qrContent: finalContent,
        id: id,
        generatedAt: now,
        expiresAt: now.add(config.validityDuration),
        isEncrypted: isEncrypted,
        isSigned: config.enableSignature,
        contentSize: finalContent.length,
      );
    } catch (e) {
      if (e is GenerationError) rethrow;

      throw GenerationError(
        type: GenerationErrorType.unknown,
        message: 'Unexpected error: ${e.toString()}',
      );
    }
  }

  /// Generates an HMAC-SHA256 signature for a payload
  String _generateSignature(Map<String, dynamic> payload) {
    if (!config.enableSignature || config.secretKey == null) {
      throw GenerationError(
        type: GenerationErrorType.signature,
        message: 'Signature disabled or missing key',
      );
    }

    try {
      final data = jsonEncode(payload);
      final key = utf8.encode(config.secretKey!);
      final bytes = utf8.encode(data);
      final hmac = Hmac(sha256, key);
      final digest = hmac.convert(bytes);
      return digest.toString();
    } catch (e) {
      throw GenerationError(
        type: GenerationErrorType.signature,
        message: 'Error during signature generation',
        details: {'error': e.toString()},
      );
    }
  }

  /// Estimates the final QR code size before generation
  /// Useful for checking if the data is not too large
  int estimateQRSize(QRData data) {
    try {
      final testPayload = {
        'data': data.toMap(),
        'id': 'test-id',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'version': config.dataVersion,
      };

      final jsonSize = jsonEncode(testPayload).length;

      // Add margin for signature if enabled
      final signatureSize = config.enableSignature ? 64 : 0;

      // Encryption and base64 encoding increase size by about 33%
      final encryptionOverhead = config.enableEncryption ? 0.33 : 0;

      return (jsonSize + signatureSize) * (1 + encryptionOverhead).round();
    } catch (e) {
      throw GenerationError(
        type: GenerationErrorType.unknown,
        message: 'Error during size estimation',
        details: {'error': e.toString()},
      );
    }
  }

  /// Checks if the data can be encoded in a QR code
  bool canEncodeData(QRData data) {
    try {
      final estimatedSize = estimateQRSize(data);
      return estimatedSize <= 2000; // Arbitrary limit for this example
    } catch (e) {
      return false;
    }
  }

  /// Creates a test version of the generator with simplified configuration
  factory SecureQRGenerator.test() {
    return SecureQRGenerator(GeneratorConfig.development());
  }
}
