import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monetra/core/providers/performance_providers.dart';
import 'package:monetra/core/services/performance_cache_service.dart';
import 'package:monetra/core/widgets/monetra_card.dart';

class PerformancePage extends ConsumerWidget {
  const PerformancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final metrics = ref.watch(performanceMetricsProvider);
    final cacheStats = ref.watch(cacheStatsProvider);

    final isMobile = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile) ...[
            Text(
              'Performance Optimization & Reliability Studio',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Local diagnostics & in-memory query cache',
              style: TextStyle(
                fontSize: 13,
                color:
                    theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                RepositoryCacheManager.clear();
                ref.read(cacheStatsProvider.notifier).state =
                    RepositoryCacheManager.getStats();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('In-memory Repository Cache cleared!')),
                );
              },
              icon: const Icon(Icons.cleaning_services_rounded, size: 18),
              label: const Text('Clear Cache'),
            ),
          ] else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Performance Optimization & Reliability Studio',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Local diagnostics, in-memory query cache controls, and memory benchmarking',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textTheme.bodyMedium?.color
                            ?.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    RepositoryCacheManager.clear();
                    ref.read(cacheStatsProvider.notifier).state =
                        RepositoryCacheManager.getStats();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('In-memory Repository Cache cleared!')),
                    );
                  },
                  icon: const Icon(Icons.cleaning_services_rounded, size: 18),
                  label: const Text('Clear Cache'),
                ),
              ],
            ),
          const SizedBox(height: 24),
          // Startup & Response Benchmark MonetraCard
          MonetraCard(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Diagnostic Latency & Response Benchmarks',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    _buildMetricChip(
                        'Startup Time',
                        '${metrics.startupTimeMs.toStringAsFixed(1)} ms',
                        Colors.green),
                    _buildMetricChip(
                        'Query Latency',
                        '${metrics.queryExecutionTimeMs.toStringAsFixed(1)} ms',
                        Colors.blue),
                    _buildMetricChip(
                        'Search Index Latency',
                        '${metrics.searchIndexTimeMs.toStringAsFixed(1)} ms',
                        Colors.indigo),
                    _buildMetricChip(
                        'Memory Usage',
                        '${metrics.memoryUsageMb.toStringAsFixed(1)} MB',
                        Colors.amber),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Repository Cache Health MonetraCard
          MonetraCard(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('In-Memory Query Cache Health Statistics',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color)),
                const SizedBox(height: 16),
                if (isMobile)
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      SizedBox(
                          width: MediaQuery.of(context).size.width / 2 - 40,
                          child: _buildStatTile(
                              'Total Entries', '${cacheStats.totalEntries}')),
                      SizedBox(
                          width: MediaQuery.of(context).size.width / 2 - 40,
                          child: _buildStatTile(
                              'Cache Hits', '${cacheStats.hitCount}')),
                      SizedBox(
                          width: MediaQuery.of(context).size.width / 2 - 40,
                          child: _buildStatTile(
                              'Cache Misses', '${cacheStats.missCount}')),
                      SizedBox(
                          width: MediaQuery.of(context).size.width / 2 - 40,
                          child: _buildStatTile('Hit Ratio',
                              '${(cacheStats.hitRatio * 100).toStringAsFixed(1)}%')),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                          child: _buildStatTile(
                              'Total Entries', '${cacheStats.totalEntries}')),
                      Expanded(
                          child: _buildStatTile(
                              'Cache Hits', '${cacheStats.hitCount}')),
                      Expanded(
                          child: _buildStatTile(
                              'Cache Misses', '${cacheStats.missCount}')),
                      Expanded(
                          child: _buildStatTile('Hit Ratio',
                              '${(cacheStats.hitRatio * 100).toStringAsFixed(1)}%')),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 12, color: color, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildStatTile(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
