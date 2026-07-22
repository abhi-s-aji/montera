import 'package:flutter_test/flutter_test.dart';
import 'package:monetra/core/database/repositories/category_repository_impl.dart';
import 'package:monetra/core/domain/entities/category.dart';

void main() {
  late CategoryRepositoryImpl repository;

  setUp(() {
    repository = CategoryRepositoryImpl([]);
  });

  group('Categories Module Unit & Hierarchy Tests', () {
    test('createCategory persists category record to list', () async {
      final now = DateTime.now();
      final cat = Category(
        id: 'cat-test-1',
        name: 'Subscriptions',
        type: CategoryType.expense,
        icon: 'subscriptions',
        colorHex: '#EC4899',
        createdAt: now,
        updatedAt: now,
      );

      await repository.createCategory(cat);
      final categories = await repository.getAllCategories();

      expect(categories.length, equals(1));
      expect(categories.first.name, equals('Subscriptions'));
    });

    test('Prevents circular parent hierarchy on category creation', () async {
      final now = DateTime.now();
      final invalidCat = Category(
        id: 'cat-self-parent',
        name: 'Self Parent',
        type: CategoryType.expense,
        parentCategoryId: 'cat-self-parent',
        icon: 'warning',
        colorHex: '#EF4444',
        createdAt: now,
        updatedAt: now,
      );

      expect(
        () async => await repository.createCategory(invalidCat),
        throwsA(isA<Exception>()),
      );
    });

    test('reorderCategories updates sort order integers', () async {
      final now = DateTime.now();
      final cat1 = Category(
          id: 'c1',
          name: 'Cat 1',
          type: CategoryType.expense,
          icon: 'icon',
          colorHex: '#10B981',
          sortOrder: 1,
          createdAt: now,
          updatedAt: now);
      final cat2 = Category(
          id: 'c2',
          name: 'Cat 2',
          type: CategoryType.expense,
          icon: 'icon',
          colorHex: '#10B981',
          sortOrder: 2,
          createdAt: now,
          updatedAt: now);

      await repository.createCategory(cat1);
      await repository.createCategory(cat2);

      await repository.reorderCategories(['c2', 'c1']);
      final list = await repository.getAllCategories();

      expect(list.first.id, equals('c2'));
      expect(list.last.id, equals('c1'));
    });

    test('mergeCategories soft deletes source category', () async {
      final now = DateTime.now();
      final source = Category(
          id: 'src-1',
          name: 'Old Fast Food',
          type: CategoryType.expense,
          icon: 'fastfood',
          colorHex: '#F59E0B',
          createdAt: now,
          updatedAt: now);
      final target = Category(
          id: 'tgt-1',
          name: 'Dining Out',
          type: CategoryType.expense,
          icon: 'restaurant',
          colorHex: '#EC4899',
          createdAt: now,
          updatedAt: now);

      await repository.createCategory(source);
      await repository.createCategory(target);

      await repository.mergeCategories(
          sourceCategoryId: 'src-1', targetCategoryId: 'tgt-1');
      final active = await repository.getAllCategories();

      expect(active.length, equals(1));
      expect(active.first.id, equals('tgt-1'));
    });
  });
}
