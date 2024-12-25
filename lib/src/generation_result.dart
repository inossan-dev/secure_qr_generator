/// Result of secure QR code generation.
/// This class contains all information about the generated QR code,
/// including its content and metadata.
class GenerationResult {
  /// Final QR code content (encoded and secured)
  final String qrContent;

  /// Unique identifier of the QR code
  final String id;

  /// Generation date
  final DateTime generatedAt;

  /// Calculated expiration date
  final DateTime expiresAt;

  /// Indicates if the content is encrypted
  final bool isEncrypted;

  /// Indicates if the content is signed
  final bool isSigned;

  /// Size in characters of the final content
  final int contentSize;

  const GenerationResult({
    required this.qrContent,
    required this.id,
    required this.generatedAt,
    required this.expiresAt,
    required this.isEncrypted,
    required this.isSigned,
    required this.contentSize,
  });

  /// Indicates if the QR code is currently valid
  bool get isValid {
    final now = DateTime.now();
    return now.isBefore(expiresAt);
  }

  /// Time remaining until expiration
  Duration get timeUntilExpiration {
    final now = DateTime.now();
    return expiresAt.difference(now);
  }

  /// Converts the result to a Map for logging or storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'generatedAt': generatedAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'isEncrypted': isEncrypted,
      'isSigned': isSigned,
      'contentSize': contentSize,
      'isValid': isValid,
      'qrContent': qrContent,
      'timeUntilExpiration': timeUntilExpiration.inSeconds,
    };
  }
}
