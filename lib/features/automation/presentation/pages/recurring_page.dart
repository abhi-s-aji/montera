import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monetra/core/domain/entities/recurring_schedule.dart';
import 'package:monetra/core/widgets/monetra_card.dart';
import 'package:monetra/features/automation/presentation/providers/recurring_providers.dart';

class RecurringPage extends ConsumerStatefulWidget {
  const RecurringPage({super.key});

  @override
  ConsumerState<RecurringPage> createState() => _RecurringPageState();
}

class _RecurringPageState extends ConsumerState<RecurringPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final schedules = ref.watch(recurringScheduleListProvider);
    final forecasts = ref.watch(upcomingForecastPreviewProvider);
    final logs = ref.watch(automationLogListProvider);

    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isMobile) ...[
              Text(
                'Recurring Transactions & Automation Engine',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Deterministic scheduled transactions',
                style: TextStyle(
                  fontSize: 13,
                  color:
                      theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                ),
              ),
            ] else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recurring Transactions & Automation Engine',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Deterministic scheduled transactions, automated generation, and execution logs',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 20),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: [
                Tab(text: 'Active Schedules (${schedules.length})'),
                Tab(text: '30-Day Forecast (${forecasts.length})'),
                Tab(text: 'Automation History (${logs.length})'),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Active Schedules Tab
                  ListView.builder(
                    itemCount: schedules.length,
                    itemBuilder: (ctx, idx) {
                      final item = schedules[idx];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: MonetraCard(
                          padding: const EdgeInsets.all(16.0),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.primary
                                  .withValues(alpha: 0.1),
                              child: Icon(Icons.autorenew_rounded,
                                  color: theme.colorScheme.primary),
                            ),
                            title: Text(item.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                'Frequency: ${item.frequency.name.toUpperCase()} | Next: ${item.nextExecutionDate.toIso8601String().split('T').first}'),
                            trailing: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              children: [
                                Text(
                                    '${item.amount < 0 ? "-" : "+"}\$${item.amount.abs().toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: item.amount < 0
                                          ? Colors.red
                                          : Colors.green,
                                    )),
                                Switch(
                                  value: item.status ==
                                      RecurringScheduleStatus.active,
                                  onChanged: (val) {
                                    final updatedList = schedules.map((s) {
                                      if (s.id == item.id) {
                                        return s.copyWith(
                                          status: val
                                              ? RecurringScheduleStatus.active
                                              : RecurringScheduleStatus.paused,
                                        );
                                      }
                                      return s;
                                    }).toList();
                                    ref
                                        .read(recurringScheduleListProvider
                                            .notifier)
                                        .state = updatedList;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // 30-Day Forecast Tab
                  ListView.builder(
                    itemCount: forecasts.length,
                    itemBuilder: (ctx, idx) {
                      final f = forecasts[idx];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: MonetraCard(
                          padding: const EdgeInsets.all(16.0),
                          child: ListTile(
                            leading: const Icon(Icons.event_available_rounded,
                                color: Colors.blue),
                            title: Text(f.description),
                            subtitle: Text(
                                'Execution Date: ${f.date.toIso8601String().split('T').first}'),
                            trailing: Text('\$${f.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      );
                    },
                  ),

                  // Automation History Tab
                  logs.isEmpty
                      ? const Center(
                          child:
                              Text('No automation log history records found.'))
                      : ListView.builder(
                          itemCount: logs.length,
                          itemBuilder: (ctx, idx) {
                            final log = logs[idx];
                            return ListTile(
                              title: Text(log.scheduleTitle),
                              subtitle: Text(log.message),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
