import 'package:flutter_test/flutter_test.dart';
import 'package:monetra/features/dashboard/domain/entities/dashboard_widget_config.dart';

void main() {
  group('Dashboard Module Unit & Layout Tests', () {
    test(
        'DashboardWidgetConfig copyWith updates sort order and visibility cleanly',
        () {
      const config = DashboardWidgetConfig(
        id: 'w-1',
        type: DashboardWidgetType.netWorthCard,
        title: 'Net Worth',
        sortOrder: 1,
      );

      final updated = config.copyWith(sortOrder: 2, isVisible: false);

      expect(updated.id, equals('w-1'));
      expect(updated.sortOrder, equals(2));
      expect(updated.isVisible, isFalse);
    });

    test('DashboardWidgetConfig Equatable props comparison works as expected',
        () {
      const w1 = DashboardWidgetConfig(
          id: 'w-1',
          type: DashboardWidgetType.cashFlowChart,
          title: 'Cash Flow',
          sortOrder: 1);
      const w2 = DashboardWidgetConfig(
          id: 'w-1',
          type: DashboardWidgetType.cashFlowChart,
          title: 'Cash Flow',
          sortOrder: 1);

      expect(w1, equals(w2));
    });
  });
}
