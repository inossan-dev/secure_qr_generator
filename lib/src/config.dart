/// Configuration for secure QR code generation.
/// This class groups all parameters that control how
/// QR codes are generated and secured.
class GeneratorConfig {
  /// Secret key used for encryption and signing.
  /// Must be at least 32 characters if encryption is enabled.
  final String? secretKey;

  /// Validity duration of generated QR codes.
  /// After this duration, QR codes will be considered expired.
  final Duration validityDuration;

  /// Enables or disables content encryption.
  /// When enabled, QR code content can only be read by
  /// applications possessing the secret key.
  final bool enableEncryption;

  /// Enables or disables digital signature.
  /// When enabled, allows verification of QR code authenticity.
  final bool enableSignature;

  /// Version of the data format used.
  /// Allows future evolution of the format while maintaining
  /// compatibility with older versions.
  final int dataVersion;

  /// Prefix added to unique identifiers.
  /// Allows distinguishing QR codes from different applications
  /// or environments.
  final String idPrefix;

  GeneratorConfig({
    this.secretKey,
    this.validityDuration = const Duration(minutes: 5),
    this.enableEncryption = false,
    this.enableSignature = false,
    this.dataVersion = 1,
    this.idPrefix = '',
  }) {
    // Parameter validation
    if ((enableEncryption || enableSignature) && secretKey == null) {
      throw ArgumentError(
        'Secret key is required when encryption or signature is enabled',
      );
    }

    if (enableEncryption && secretKey != null && secretKey!.length < 32) {
      throw ArgumentError(
        'Secret key must be at least 32 characters when encryption is enabled',
      );
    }

    if (dataVersion < 1) {
      throw ArgumentError('Version must be greater than 0');
    }

    if (validityDuration.inSeconds <= 0) {
      throw ArgumentError('Validity duration must be positive');
    }
  }

  /// Creates a configuration for a development environment
  factory GeneratorConfig.development() {
    return GeneratorConfig(
      secretKey: 'dev_key_for_testing_purposes_only!!!',
      validityDuration: const Duration(hours: 1),
      enableEncryption: true,
      enableSignature: true,
      idPrefix: 'DEV_',
    );
  }

  /// Creates a configuration for a production environment
  /// with enhanced security parameters
  factory GeneratorConfig.production({
    required String secretKey,
    Duration validityDuration = const Duration(minutes: 5),
  }) {
    if (secretKey.length < 32) {
      throw ArgumentError('Production key must be at least 32 characters');
    }

    return GeneratorConfig(
      secretKey: secretKey,
      validityDuration: validityDuration,
      enableEncryption: true,
      enableSignature: true,
      idPrefix: 'PROD_',
    );
  }
}
