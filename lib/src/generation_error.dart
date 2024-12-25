/// Represents an error that occurred during QR code generation.
class GenerationError extends Error {
  /// Error type
  final GenerationErrorType type;

  /// Detailed error message
  final String message;

  /// Additional technical details about the error
  final Map<String, dynamic>? details;

  GenerationError({
    required this.type,
    required this.message,
    this.details,
  });

  @override
  String toString() => 'GenerationError($type): $message';
}

/// Possible error types during generation
enum GenerationErrorType {
  /// Configuration error (missing key, invalid parameters...)
  configuration,

  /// Error during data encryption
  encryption,

  /// Error during signature generation
  signature,

  /// Error during data serialization
  serialization,

  /// Data size too large
  payloadTooLarge,

  /// Unexpected error
  unknown,
}