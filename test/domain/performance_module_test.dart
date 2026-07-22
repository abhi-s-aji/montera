import 'package:flutter_test/flutter_test.dart';

import 'package:monetra/core/services/performance_cache_service.dart';

void main() {
  group('Monetra Performance Optimization & Reliability Unit Tests', () {
    setUp(() {
      RepositoryCacheManager.clear();
    });

    test(
        'RepositoryCacheManager stores and retrieves cached values with hit/miss counting',
        () {
      RepositoryCacheManager.set('query_summary', {'totalBalance': 5000.0});

      final cachedValue =
          RepositoryCacheManager.get('query_summary') as Map<String, dynamic>?;
      expect(cachedValue, isNotNull);
      expect(cachedValue?['totalBalance'], equals(5000.0));

      final missValue = RepositoryCacheManager.get('non_existent_key');
      expect(missValue, isNull);

      final stats = RepositoryCacheManager.getStats();
      expect(stats.totalEntries, equals(1));
      expect(stats.hitCount, equals(1));
      expect(stats.missCount, equals(1));
      expect(stats.hitRatio, equals(0.5));
    });

    test(
        'LocalPerformanceMonitor measures operation execution latency accurately',
        () async {
      final result = await LocalPerformanceMonitor.measureOperation<int>(
        'test_delay',
        () async {
          await Future.delayed(const Duration(milliseconds: 10));
          return 42;
        },
      );

      expect(result, equals(42));
    });

    test(
        'ErrorRecoveryHandler executes actions safely and returns fallback on failure',
        () {
      final safeResult = ErrorRecoveryHandler.executeSafely<int>(
        () => 10 + 20,
        0,
      );
      expect(safeResult, equals(30));

      final fallbackResult = ErrorRecoveryHandler.executeSafely<int>(
        () => throw Exception('Database Lock Failure'),
        -1,
      );
      expect(fallbackResult, equals(-1));
    });
  });
}
