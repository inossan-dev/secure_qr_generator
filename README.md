# Secure QR Generator

A Flutter package for generating secure, auto-regenerating QR codes with encryption, digital signatures, and automatic expiration management.

## Features

- 🔒 **Secure by Design**: Support for AES encryption and HMAC-SHA256 signatures
- ⏱️ **Auto-Expiration**: Built-in validity duration management
- 🔄 **Auto-Regeneration**: Automatic QR code refresh before expiration
- 📱 **Flutter Integration**: Ready-to-use Flutter widget
- 🎨 **Customizable Styling**: Full control over QR code appearance
- ⚡ **Performance Optimized**: Efficient regeneration with minimal overhead

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  secure_qr_generator: ^1.0.4
```

Then run:

```bash
flutter pub get
```

## Quick Start

### Basic Usage

```dart
import 'package:secure_qr_generator/secure_qr_generator.dart';

// Create a configuration
final config = GeneratorConfig.production(
  secretKey: 'your-32-character-secret-key-here!!!',
  validityDuration: Duration(minutes: 5),
);

// Initialize the generator
final generator = SecureQRGenerator(config);

// Create QR data
final data = QRData(
  payload: {'userId': '123', 'access': 'granted'},
  metadata: {'purpose': 'access_control'},
  tags: ['entrance', 'visitor'],
);

// Generate a QR code
final result = await generator.generateQR(data);
```

### Using the Auto-Regenerating Widget

```dart
AutoRegeneratingQRView(
  data: data,
  generator: generator,
  size: 200,
  style: QrStyle(
    eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square),
    dataModuleStyle: QrDataModuleStyle(
      dataModuleShape: QrDataModuleShape.circle,
    ),
  ),
  onRegenerate: (result) {
    print('New QR generated: ${result.id}');
  },
  onError: (error) {
    print('Error: $error');
  },
)
```

## Configuration Options

### Development Configuration

```dart
final devConfig = GeneratorConfig.development();
```

### Production Configuration

```dart
final prodConfig = GeneratorConfig.production(
  secretKey: 'your-secure-production-key-here!!!!!!',
  validityDuration: Duration(minutes: 5),
);
```

### Custom Configuration

```dart
final customConfig = GeneratorConfig(
  secretKey: 'your-secret-key',
  validityDuration: Duration(minutes: 10),
  enableEncryption: true,
  enableSignature: true,
  dataVersion: 1,
  idPrefix: 'CUSTOM_',
);
```

## Advanced Features

### Custom QR Code Styling

```dart
QrStyle(
  eyeStyle: QrEyeStyle(
    eyeShape: QrEyeShape.square,
    color: Colors.blue,
  ),
  dataModuleStyle: QrDataModuleStyle(
    dataModuleShape: QrDataModuleShape.circle,
    color: Colors.black,
  ),
  embeddedImage: AssetImage('assets/logo.png'),
  embeddedImageStyle: QrEmbeddedImageStyle(
    size: Size(40, 40),
  ),
)
```

### Custom Regeneration Interval

```dart
AutoRegeneratingQRView(
  data: data,
  generator: generator,
  regenerationInterval: Duration(minutes: 2),
  // ... other parameters
)
```

### Custom QR Code Builder

```dart
AutoRegeneratingQRView(
  data: data,
  generator: generator,
  builder: (qrData) => Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.blue),
    ),
    child: QrImageView(
      data: qrData,
      size: 200,
    ),
  ),
)
```

## Error Handling

The package includes comprehensive error handling:

```dart
try {
  final result = await generator.generateQR(data);
  // Use the result
} on GenerationError catch (e) {
  switch (e.type) {
    case GenerationErrorType.configuration:
      print('Configuration error: ${e.message}');
      break;
    case GenerationErrorType.encryption:
      print('Encryption error: ${e.message}');
      break;
    case GenerationErrorType.payloadTooLarge:
      print('Payload too large: ${e.message}');
      break;
    // Handle other error types...
  }
}
```

## Security Considerations

- Keep your `secretKey` secure and never commit it to version control
- Use different keys for development and production environments
- Consider the QR code size limits when adding data
- Choose an appropriate validity duration for your use case
- Regularly rotate encryption keys in production

## Contributing

Contributions are welcome! Please read our contributing guidelines before submitting pull requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.