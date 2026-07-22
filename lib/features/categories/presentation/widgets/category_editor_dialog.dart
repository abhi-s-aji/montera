import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/domain/entities/category.dart';
import '../../../../core/providers/category_providers.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/theme/monetra_colors.dart';

class CategoryEditorDialog extends ConsumerStatefulWidget {
  final Category? initialCategory;

  const CategoryEditorDialog({super.key, this.initialCategory});

  static Future<void> show(BuildContext context, {Category? category}) {
    return showDialog(
      context: context,
      builder: (ctx) => CategoryEditorDialog(initialCategory: category),
    );
  }

  @override
  ConsumerState<CategoryEditorDialog> createState() =>
      _CategoryEditorDialogState();
}

class _CategoryEditorDialogState extends ConsumerState<CategoryEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;

  CategoryType _selectedType = CategoryType.expense;
  String? _selectedParentId;
  String _selectedColorHex = '#10B981';
  String _selectedIcon = 'category';

  final List<String> _colors = [
    '#10B981',
    '#EF4444',
    '#3B82F6',
    '#F59E0B',
    '#EC4899',
    '#06B6D4',
    '#8B5CF6'
  ];

  @override
  void initState() {
    super.initState();
    final cat = widget.initialCategory;
    _nameController = TextEditingController(text: cat?.name ?? '');
    _descController = TextEditingController(text: cat?.description ?? '');

    if (cat != null) {
      _selectedType = cat.type;
      _selectedParentId = cat.parentCategoryId;
      _selectedColorHex = cat.colorHex;
      _selectedIcon = cat.icon;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final repo = ref.read(categoryRepositoryProvider);

    if (widget.initialCategory == null) {
      final newCat = Category(
        id: 'cat-${const Uuid().v4()}',
        name: _nameController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        type: _selectedType,
        parentCategoryId: _selectedParentId,
        icon: _selectedIcon,
        colorHex: _selectedColorHex,
        createdAt: now,
        updatedAt: now,
      );
      await repo.createCategory(newCat);
    } else {
      final updatedCat = widget.initialCategory!.copyWith(
        name: _nameController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        type: _selectedType,
        parentCategoryId: _selectedParentId,
        icon: _selectedIcon,
        colorHex: _selectedColorHex,
        updatedAt: now,
      );
      await repo.updateCategory(updatedCat);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.initialCategory == null
                          ? 'Create Category'
                          : 'Edit Category',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                      labelText: 'Category Name *', hintText: 'e.g. Groceries'),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Category name is required'
                      : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<CategoryType>(
                  initialValue: _selectedType,
                  decoration: const InputDecoration(labelText: 'Category Type'),
                  items: CategoryType.values
                      .where((t) => t != CategoryType.system)
                      .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(t.name.toUpperCase()),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedType = val);
                  },
                ),
                const SizedBox(height: 12),
                categoriesAsync.when(
                  data: (categories) {
                    final validParents = categories
                        .where((c) =>
                            c.id != widget.initialCategory?.id &&
                            c.parentCategoryId == null)
                        .toList();

                    return DropdownButtonFormField<String?>(
                      initialValue: _selectedParentId,
                      decoration: const InputDecoration(
                          labelText: 'Parent Category (Optional)'),
                      items: [
                        const DropdownMenuItem<String?>(
                            value: null, child: Text('None (Top Level)')),
                        ...validParents.map((c) => DropdownMenuItem<String?>(
                              value: c.id,
                              child: Text(c.name),
                            )),
                      ],
                      onChanged: (val) =>
                          setState(() => _selectedParentId = val),
                    );
                  },
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      hintText: 'Notes on category usage'),
                ),
                const SizedBox(height: 16),
                Text('Color Swatch',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyMedium?.color)),
                const SizedBox(height: 8),
                Row(
                  children: _colors.map((hex) {
                    final color = MonetraColors.hexToColor(hex);
                    final isSelected = _selectedColorHex == hex;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColorHex = hex),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: Text(widget.initialCategory == null
                        ? 'Create Category'
                        : 'Save Changes'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
