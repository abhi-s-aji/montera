import 'dart:async';

import '../../domain/entities/category.dart';
import '../../domain/repositories/i_category_repository.dart';

class CategoryRepositoryImpl implements ICategoryRepository {
  final List<Category> _categories = [];
  final StreamController<List<Category>> _streamController =
      StreamController<List<Category>>.broadcast();

  CategoryRepositoryImpl([List<Category>? initialCategories]) {
    if (initialCategories != null) {
      _categories.addAll(initialCategories);
    } else {
      _seedDefaultCategories();
    }
    _emit();
  }

  void _seedDefaultCategories() {
    final now = DateTime.now();
    _categories.addAll([
      Category(
        id: 'cat-housing',
        name: 'Housing & Rent',
        description: 'Rent, mortgage, and property expenses',
        type: CategoryType.expense,
        icon: 'home',
        colorHex: '#EF4444',
        sortOrder: 1,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: 'cat-groceries',
        name: 'Groceries & Essentials',
        description: 'Supermarkets, food stores, and household supplies',
        type: CategoryType.expense,
        icon: 'shopping_cart',
        colorHex: '#F59E0B',
        sortOrder: 2,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: 'cat-dining',
        name: 'Dining & Restaurants',
        description: 'Restaurants, coffee shops, and takeout',
        type: CategoryType.expense,
        parentCategoryId: 'cat-groceries',
        icon: 'restaurant',
        colorHex: '#EC4899',
        sortOrder: 3,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: 'cat-salary',
        name: 'Salary & Employment',
        description: 'Regular paycheck and employment earnings',
        type: CategoryType.income,
        icon: 'payments',
        colorHex: '#10B981',
        sortOrder: 4,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: 'cat-freelance',
        name: 'Freelance & Consulting',
        description: 'Client work, side projects, and consulting income',
        type: CategoryType.income,
        icon: 'work',
        colorHex: '#06B6D4',
        sortOrder: 5,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: 'cat-transfer',
        name: 'Internal Account Transfer',
        description: 'Funds transferred between owned accounts',
        type: CategoryType.transfer,
        icon: 'swap_horiz',
        colorHex: '#3B82F6',
        sortOrder: 6,
        createdAt: now,
        updatedAt: now,
      ),
    ]);
  }

  void _emit() {
    final active = _categories.where((c) => !c.isDeleted).toList();
    active.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    _streamController.add(active);
  }

  @override
  Stream<List<Category>> watchAllCategories({bool includeArchived = false}) {
    return _streamController.stream.map(
      (list) => list.where((c) => includeArchived || !c.isArchived).toList(),
    );
  }

  @override
  Future<List<Category>> getAllCategories(
      {bool includeArchived = false}) async {
    final list = _categories
        .where((c) => !c.isDeleted && (includeArchived || !c.isArchived))
        .toList();
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    try {
      return _categories.firstWhere((c) => c.id == id && !c.isDeleted);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> createCategory(Category category) async {
    // Validate hierarchy circular reference
    if (category.parentCategoryId != null &&
        category.parentCategoryId == category.id) {
      throw Exception(
          'Circular hierarchy: A category cannot be its own parent.');
    }
    _categories.add(category);
    _emit();
  }

  @override
  Future<void> updateCategory(Category category) async {
    if (category.parentCategoryId != null &&
        category.parentCategoryId == category.id) {
      throw Exception(
          'Circular hierarchy: A category cannot be its own parent.');
    }
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category.copyWith(
        updatedAt: DateTime.now(),
        version: category.version + 1,
      );
      _emit();
    }
  }

  @override
  Future<void> archiveCategory(String id, bool archiveStatus) async {
    final index = _categories.indexWhere((c) => c.id == id);
    if (index != -1) {
      _categories[index] = _categories[index].copyWith(
        isArchived: archiveStatus,
        updatedAt: DateTime.now(),
      );
      _emit();
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    final index = _categories.indexWhere((c) => c.id == id);
    if (index != -1) {
      _categories[index] = _categories[index].copyWith(
        isDeleted: true,
        updatedAt: DateTime.now(),
      );
      _emit();
    }
  }

  @override
  Future<void> mergeCategories(
      {required String sourceCategoryId,
      required String targetCategoryId}) async {
    final source = await getCategoryById(sourceCategoryId);
    if (source == null) throw Exception('Source category not found');

    // Soft delete source category after merging
    await deleteCategory(sourceCategoryId);
  }

  @override
  Future<void> reorderCategories(List<String> orderedCategoryIds) async {
    for (int i = 0; i < orderedCategoryIds.length; i++) {
      final id = orderedCategoryIds[i];
      final index = _categories.indexWhere((c) => c.id == id);
      if (index != -1) {
        _categories[index] = _categories[index].copyWith(sortOrder: i + 1);
      }
    }
    _emit();
  }
}
