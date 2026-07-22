import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monetra/core/domain/entities/performance_metrics.dart';
import 'package:monetra/core/services/performance_cache_service.dart';

final performanceMetricsProvider = StateProvider<PerformanceMetrics>((ref) {
  return const PerformanceMetrics(
    startupTimeMs: 420.0,
    queryExecutionTimeMs: 12.5,
    searchIndexTimeMs: 24.0,
    totalIndexedRecords: 1540,
    memoryUsageMb: 45.2,
  );
});

final cacheStatsProvider = StateProvider<CacheStats>((ref) {
  return RepositoryCacheManager.getStats();
});
