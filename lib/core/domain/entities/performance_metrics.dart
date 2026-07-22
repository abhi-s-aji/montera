import 'package:equatable/equatable.dart';

class PerformanceMetrics extends Equatable {
  final double startupTimeMs;
  final double queryExecutionTimeMs;
  final double searchIndexTimeMs;
  final int totalIndexedRecords;
  final double memoryUsageMb;

  const PerformanceMetrics({
    required this.startupTimeMs,
    required this.queryExecutionTimeMs,
    required this.searchIndexTimeMs,
    required this.totalIndexedRecords,
    required this.memoryUsageMb,
  });

  @override
  List<Object?> get props => [
        startupTimeMs,
        queryExecutionTimeMs,
        searchIndexTimeMs,
        totalIndexedRecords,
        memoryUsageMb,
      ];
}

class CacheStats extends Equatable {
  final int totalEntries;
  final int hitCount;
  final int missCount;

  const CacheStats({
    required this.totalEntries,
    required this.hitCount,
    required this.missCount,
  });

  double get hitRatio =>
      (hitCount + missCount) == 0 ? 0.0 : hitCount / (hitCount + missCount);

  @override
  List<Object?> get props => [totalEntries, hitCount, missCount];
}
