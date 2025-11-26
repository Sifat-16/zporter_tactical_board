import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:zporter_tactical_board/app/services/storage/image_conversion_service.dart';

void main() {
  group('ImageConversionService', () {
    group('base64ToBytes', () {
      test('should convert valid base64 string to bytes', () {
        // Valid base64 encoded "Hello"
        const base64 = 'SGVsbG8=';
        final result = ImageConversionService.base64ToBytes(base64);

        expect(result, isNotNull);
        expect(result, isA<Uint8List>());
        expect(String.fromCharCodes(result!), 'Hello');
      });

      test('should handle base64 with data URI prefix', () {
        const base64WithPrefix = 'data:image/jpeg;base64,SGVsbG8=';
        final result = ImageConversionService.base64ToBytes(base64WithPrefix);

        expect(result, isNotNull);
        expect(String.fromCharCodes(result!), 'Hello');
      });

      test('should return null for invalid base64', () {
        const invalidBase64 = 'not-valid-base64!!!';
        final result = ImageConversionService.base64ToBytes(invalidBase64);

        expect(result, isNull);
      });

      test('should return null for null input', () {
        final result = ImageConversionService.base64ToBytes(null);
        expect(result, isNull);
      });

      test('should return null for empty string', () {
        final result = ImageConversionService.base64ToBytes('');
        expect(result, isNull);
      });
    });

    group('bytesToBase64', () {
      test('should convert bytes to base64 string', () {
        final bytes = Uint8List.fromList('Hello'.codeUnits);
        final result = ImageConversionService.bytesToBase64(bytes);

        expect(result, isNotNull);
        expect(result, 'SGVsbG8=');
      });

      test('should return null for null input', () {
        final result = ImageConversionService.bytesToBase64(null);
        expect(result, isNull);
      });

      test('should handle empty bytes', () {
        final bytes = Uint8List(0);
        final result = ImageConversionService.bytesToBase64(bytes);

        expect(result, isNull);
      });
    });

    group('isBase64Image', () {
      test('should return true for valid base64 image with data URI', () {
        const base64Image = 'data:image/jpeg;base64,/9j/4AAQSkZJRg==';
        expect(ImageConversionService.isBase64Image(base64Image), isTrue);
      });

      test('should return true for base64 image with different formats', () {
        expect(
          ImageConversionService.isBase64Image(
              'data:image/png;base64,iVBORw0KGg=='),
          isTrue,
        );
        expect(
          ImageConversionService.isBase64Image(
              'data:image/webp;base64,UklGRg=='),
          isTrue,
        );
      });

      test('should return false for non-base64 strings', () {
        expect(
            ImageConversionService.isBase64Image(
                'https://example.com/image.jpg'),
            isFalse);
        expect(ImageConversionService.isBase64Image('not-a-base64-string'),
            isFalse);
      });

      test('should return false for null or empty', () {
        expect(ImageConversionService.isBase64Image(null), isFalse);
        expect(ImageConversionService.isBase64Image(''), isFalse);
      });
    });

    group('isFirebaseStorageUrl', () {
      test('should return true for valid Firebase Storage URLs', () {
        expect(
          ImageConversionService.isFirebaseStorageUrl(
            'https://firebasestorage.googleapis.com/v0/b/bucket/o/image.jpg',
          ),
          isTrue,
        );
      });

      test('should return false for non-Firebase URLs', () {
        expect(
          ImageConversionService.isFirebaseStorageUrl(
              'https://example.com/image.jpg'),
          isFalse,
        );
      });

      test('should return false for null or empty', () {
        expect(ImageConversionService.isFirebaseStorageUrl(null), isFalse);
        expect(ImageConversionService.isFirebaseStorageUrl(''), isFalse);
      });
    });

    group('isNetworkUrl', () {
      test('should return true for HTTP URLs', () {
        expect(
            ImageConversionService.isNetworkUrl('http://example.com/image.jpg'),
            isTrue);
      });

      test('should return true for HTTPS URLs', () {
        expect(
            ImageConversionService.isNetworkUrl(
                'https://example.com/image.jpg'),
            isTrue);
      });

      test('should return false for non-URL strings', () {
        expect(ImageConversionService.isNetworkUrl('file:///path/to/image.jpg'),
            isFalse);
        expect(
            ImageConversionService.isNetworkUrl('data:image/jpeg;base64,/9j/'),
            isFalse);
      });

      test('should return false for null or empty', () {
        expect(ImageConversionService.isNetworkUrl(null), isFalse);
        expect(ImageConversionService.isNetworkUrl(''), isFalse);
      });
    });

    group('estimateBase64Size', () {
      test('should estimate size correctly', () {
        // Base64 encoding increases size by ~33%
        // 4 characters = 3 bytes
        const base64 = 'SGVsbG8='; // "Hello" = 5 bytes
        final size = ImageConversionService.estimateBase64Size(base64);

        expect(size, 6); // 8 chars / 4 * 3 = 6 bytes
      });

      test('should handle base64 with data URI prefix', () {
        const base64WithPrefix = 'data:image/jpeg;base64,SGVsbG8=';
        final size =
            ImageConversionService.estimateBase64Size(base64WithPrefix);

        // Calculates entire string length
        expect(size, 23); // (31 chars * 3) / 4 = 23
      });

      test('should return 0 for null or empty', () {
        expect(ImageConversionService.estimateBase64Size(null), 0);
        expect(ImageConversionService.estimateBase64Size(''), 0);
      });
    });

    group('formatBytes', () {
      test('should format bytes correctly', () {
        expect(ImageConversionService.formatBytes(0), '0 B');
        expect(ImageConversionService.formatBytes(500), '500 B');
        expect(ImageConversionService.formatBytes(1024), '1.0 KB');
        expect(ImageConversionService.formatBytes(1536), '1.5 KB');
        expect(ImageConversionService.formatBytes(1048576), '1.0 MB');
        expect(ImageConversionService.formatBytes(1572864), '1.5 MB');
      });

      test('should handle negative values', () {
        expect(ImageConversionService.formatBytes(-1024), '-1024 B');
      });
    });

    group('isValidImageData', () {
      test('should detect valid JPEG signature', () {
        final jpegBytes = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]);
        expect(ImageConversionService.isValidImageData(jpegBytes), isTrue);
      });

      test('should detect valid PNG signature', () {
        final pngBytes = Uint8List.fromList(
            [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
        expect(ImageConversionService.isValidImageData(pngBytes), isTrue);
      });

      test('should detect valid WebP signature', () {
        final webpBytes = Uint8List.fromList([
          0x52, 0x49, 0x46, 0x46, // RIFF
          0x00, 0x00, 0x00, 0x00, // Size (placeholder)
          0x57, 0x45, 0x42, 0x50, // WEBP
        ]);
        expect(ImageConversionService.isValidImageData(webpBytes), isTrue);
      });

      test('should return false for invalid image data', () {
        final invalidBytes = Uint8List.fromList([0x00, 0x00, 0x00, 0x00]);
        expect(ImageConversionService.isValidImageData(invalidBytes), isFalse);
      });

      test('should return false for null or too short data', () {
        expect(ImageConversionService.isValidImageData(null), isFalse);
        expect(ImageConversionService.isValidImageData(Uint8List(0)), isFalse);
        expect(ImageConversionService.isValidImageData(Uint8List(2)), isFalse);
      });
    });

    group('calculateSavings', () {
      test('should calculate savings correctly', () {
        final result = ImageConversionService.calculateSavings(
          base64Size: 75000, // 75 KB
          urlSize: 50, // 50 bytes
        );

        expect(result['base64Size'], 75000);
        expect(result['urlSize'], 50);
        expect(result['savedBytes'], 74950);
        expect(result['percentSaved'], closeTo(99.93, 0.01));
        expect(result['base64SizeFormatted'], '73.2 KB');
        expect(result['urlSizeFormatted'], '50 B');
        expect(result['savedFormatted'], '73.2 KB');
      });

      test('should handle zero URL size', () {
        final result = ImageConversionService.calculateSavings(
          base64Size: 1000,
          urlSize: 0,
        );

        expect(result['savedBytes'], 1000);
        expect(result['percentSaved'], 100.0);
      });

      test('should handle equal sizes', () {
        final result = ImageConversionService.calculateSavings(
          base64Size: 100,
          urlSize: 100,
        );

        expect(result['savedBytes'], 0);
        expect(result['percentSaved'], 0.0);
      });

      test('should handle larger URL size (negative savings)', () {
        final result = ImageConversionService.calculateSavings(
          base64Size: 50,
          urlSize: 100,
        );

        expect(result['savedBytes'], -50);
        expect(result['percentSaved'], -100.0);
      });
    });
  });
}
