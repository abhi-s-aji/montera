import '../entities/category.dart';

abstract class ICategoryRepository {
  Stream<List<Category>> watchAllCategories({bool includeArchived = false});
  Future<List<Category>> getAllCategories({bool includeArchived = false});
  Future<Category?> getCategoryById(String id);
  Future<void> createCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> archiveCategory(String id, bool archiveStatus);
  Future<void> deleteCategory(String id);
  Future<void> mergeCategories(
      {required String sourceCategoryId, required String targetCategoryId});
  Future<void> reorderCategories(List<String> orderedCategoryIds);
}
