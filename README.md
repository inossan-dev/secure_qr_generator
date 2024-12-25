# secure_qr_generator

🔒 A robust Flutter library for generating and managing secure QR codes with automatic regeneration, incorporating encryption, digital signatures, and temporal validation.


## Prerequisites

Before getting started, make sure you have:
- Flutter SDK version 3.0.0 or higher
- Dart SDK version 3.0.0 or higher
- A basic understanding of:
    - Asynchronous programming in Dart
    - Cryptography concepts (for advanced usage)
    - Flutter widget system


## Features

- ⏱️ **QR Code Auto-regeneration :** Automatic and configurable code updates for enhanced security
- 🎨 **Customizable Flutter Widget :** Native and flexible integration into your Flutter interfaces
- 🔄 **Temporal Code Validation :** Automatic management of code validity duration
- 🔐 **AES Data Encryption (optional) :** Protection of sensitive information with robust encryption (optional)
- ✍️ **Digital Signature for Data Integrity (optional) :** Guarantee of data integrity and authenticity (optional)


## Installation

Add the dependency to your pubspec.yaml file:

```yaml
dependencies:
  secure_qr_flutter: ^1.0.0
```
Then run:

```bash
flutter pub get
```


## Usage Guide

### Basic Configuration

The configuration defines the security parameters for your QR codes. Here's a complete example with explanations:

```dart
final config = SecureQRConfig(
  // Duration for which the QR code remains valid after generation
  validityDuration: Duration(minutes: 5),
);
```

### Simple QR Code Generation

Here's how to generate a secure QR code with structured data:

```dart
// Create the generator with our configuration
final generator = SecureQRGenerator(config);

// Generate the secure payload
final qrData = generator.generateQRPayload({
  'userId': '12345',      // Unique identifier
  'access': 'full',       // Access level
  'timestamp': DateTime.now().toIso8601String(), // Timestamp
});
```

### Using the Auto-regenerating Widget

The auto-regenerating widget enables automatic QR code updates for enhanced security:

```dart
AutoRegeneratingQRWidget(
  // Data to encode in the QR code
  data: {'userId': '12345'},

  // Our configured generator
  generator: generator,

  // Code regeneration interval
  regenerationInterval: Duration(minutes: 4),

  // Appearance customization
  builder: (qrData) => QrImageView(
    data: qrData,
    size: 200,
  ),

  // Callback called on each regeneration
  onRegenerate: (newData) {
    print('QR Code successfully regenerated');
  },
)
```

### QR Code Validation

```dart
final result = generator.validateQRPayload(scannedData);
if (result.isValid) {
  print('Valid data : ${result.data}');
} else if (result.isExpired) {
  print('QR code expired');
} else {
  print('Error : ${result.error}');
}
```

## Advanced Configuration

### Maximum Security Mode

```dart
final secureConfig = SecureQRConfig(
  // Create a secure configuration
  secretKey: "votre_clé_secrète_32_caractères",

  // Duration for which the QR code remains valid after generation
  validityDuration: Duration(minutes: 5),

  // Enable AES encryption to protect sensitive data
  enableEncryption: true,

  // Enable digital signature to ensure authenticity
  enableSignature: true,
);
```

## Licence

MIT License - see the LICENSE file for more details.