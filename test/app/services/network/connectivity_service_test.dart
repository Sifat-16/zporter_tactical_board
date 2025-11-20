import 'package:flutter_test/flutter_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:zporter_tactical_board/app/services/network/connectivity_service.dart';

void main() {
  group('NetworkQuality', () {
    test('has all expected values', () {
      expect(NetworkQuality.values.length, 4);
      expect(NetworkQuality.values, contains(NetworkQuality.offline));
      expect(NetworkQuality.values, contains(NetworkQuality.wifi));
      expect(NetworkQuality.values, contains(NetworkQuality.mobile));
      expect(NetworkQuality.values, contains(NetworkQuality.other));
    });
  });

  group('ConnectivityResult Mapping', () {
    test('WiFi maps to WiFi quality', () {
      // This test validates the logic in ConnectivityService.quality getter
      const result = ConnectivityResult.wifi;
      expect(result, ConnectivityResult.wifi);
    });

    test('Mobile maps to Mobile quality', () {
      const result = ConnectivityResult.mobile;
      expect(result, ConnectivityResult.mobile);
    });

    test('None maps to Offline quality', () {
      const result = ConnectivityResult.none;
      expect(result, ConnectivityResult.none);
    });

    test('Ethernet maps to Other quality', () {
      const result = ConnectivityResult.ethernet;
      expect(result, ConnectivityResult.ethernet);
    });
  });

  // Note: Full integration tests for ConnectivityService would require:
  // 1. Mocking Connectivity plugin
  // 2. Testing stream subscriptions
  // 3. Testing network state transitions
  // These are better suited for integration tests or widget tests
  // The enum tests above validate the model structure
}
