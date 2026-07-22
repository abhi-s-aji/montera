import 'package:monetra/core/domain/entities/performance_metrics.dart';

class RepositoryCacheManager {
  static final Map<String, dynamic> _cacheStore = {};
  static int _hits = 0;
  static int _misses = 0;

  static void set(String key, dynamic value) {
    _cacheStore[key] = value;
  }

  static dynamic get(String key) {
    if (_cacheStore.containsKey(key)) {
      _hits++;
      return _cacheStore[key];
    }
    _misses++;
    return null;
  }

  static void invalidate(String key) {
    _cacheStore.remove(key);
  }

  static void clear() {
    _cacheStore.clear();
    _hits = 0;
    _misses = 0;
  }

  static CacheStats getStats() {
    return CacheStats(
      totalEntries: _cacheStore.length,
      hitCount: _hits,
      missCount: _misses,
    );
  }
}

class LocalPerformanceMonitor {
  static Future<T> measureOperation<T>(
      String operationName, Future<T> Function() action) async {
    final stopwatch = Stopwatch()..start();
    try {
      return await action();
    } finally {
      stopwatch.stop();
    }
  }
}

class ErrorRecoveryHandler {
  static T executeSafely<T>(T Function() action, T fallback) {
    try {
      return action();
    } catch (_) {
      return fallback;
    }
  }
}
