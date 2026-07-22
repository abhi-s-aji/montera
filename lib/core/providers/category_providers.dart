import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/category.dart';
import 'repository_providers.dart';

// State providers for Search & Type Filtering
final categorySearchQueryProvider = StateProvider<String>((ref) => '');
final categoryTypeFilterProvider = StateProvider<CategoryType?>((ref) => null);
final categoryShowArchivedProvider = StateProvider<bool>((ref) => false);

// Categories Watch Stream Provider
final categoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  final showArchived = ref.watch(categoryShowArchivedProvider);
  return repo.watchAllCategories(includeArchived: showArchived);
});

// Filtered Categories List Provider
final filteredCategoriesProvider = Provider<List<Category>>((ref) {
  final categoriesAsync = ref.watch(categoriesStreamProvider);
  final query = ref.watch(categorySearchQueryProvider).trim().toLowerCase();
  final typeFilter = ref.watch(categoryTypeFilterProvider);

  return categoriesAsync.when(
    data: (categories) {
      return categories.where((c) {
        final matchesQuery = query.isEmpty ||
            c.name.toLowerCase().contains(query) ||
            (c.description?.toLowerCase().contains(query) ?? false);
        final matchesType = typeFilter == null || c.type == typeFilter;
        return matchesQuery && matchesType;
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Hierarchical Parent-Child Category Tree Provider
final categoryTreeProvider = Provider<Map<Category, List<Category>>>((ref) {
  final categories = ref.watch(filteredCategoriesProvider);

  final Map<Category, List<Category>> tree = {};
  final parents = categories.where((c) => c.parentCategoryId == null).toList();

  for (final parent in parents) {
    final children =
        categories.where((c) => c.parentCategoryId == parent.id).toList();
    tree[parent] = children;
  }

  return tree;
});
