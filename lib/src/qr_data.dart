/// Represents the data to be encoded in a QR code before securing.
/// This class ensures that the data is in a valid format
/// before QR code generation.
class QRData {
  /// Business data to be encoded in the QR code
  final Map<String, dynamic> payload;

  /// Optional metadata that will be included in the QR code
  final Map<String, dynamic>? metadata;

  /// Optional tags to categorize or filter QR codes
  final List<String>? tags;

  const QRData({
    required this.payload,
    this.metadata,
    this.tags,
  });

  /// Converts the data to a Map for serialization
  Map<String, dynamic> toMap() {
    return {
      'payload': payload,
      if (metadata != null) 'metadata': metadata,
      if (tags != null && tags!.isNotEmpty) 'tags': tags,
    };
  }
}
