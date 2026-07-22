import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/entities/category.dart';
import '../../../../core/providers/category_providers.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/theme/monetra_colors.dart';
import '../../../../core/theme/monetra_design_system.dart';
import '../../../../core/utils/icon_helper.dart';
import '../../../../core/widgets/monetra_card.dart';
import '../../../../core/widgets/monetra_empty_state.dart';
import '../widgets/category_editor_dialog.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  void _showCategoryActions(
      BuildContext context, WidgetRef ref, Category category) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Edit Category'),
            onTap: () {
              Navigator.of(ctx).pop();
              CategoryEditorDialog.show(context, category: category);
            },
          ),
          ListTile(
            leading: Icon(category.isArchived
                ? Icons.unarchive_outlined
                : Icons.archive_outlined),
            title: Text(
                category.isArchived ? 'Restore Category' : 'Archive Category'),
            onTap: () async {
              Navigator.of(ctx).pop();
              await ref
                  .read(categoryRepositoryProvider)
                  .archiveCategory(category.id, !category.isArchived);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(category.isArchived
                          ? 'Category restored'
                          : 'Category archived')),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline,
                color: MonetraColors.expenseRed),
            title: const Text('Delete Category',
                style: TextStyle(color: MonetraColors.expenseRed)),
            onTap: () async {
              Navigator.of(ctx).pop();
              await ref
                  .read(categoryRepositoryProvider)
                  .deleteCategory(category.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Category deleted')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categoryTree = ref.watch(categoryTreeProvider);
    final searchQuery = ref.watch(categorySearchQueryProvider);
    final typeFilter = ref.watch(categoryTypeFilterProvider);

    final isMobile = MediaQuery.of(context).size.width < 600;

    final filterChips = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ChoiceChip(
          label: const Text('All'),
          selected: typeFilter == null,
          onSelected: (_) =>
              ref.read(categoryTypeFilterProvider.notifier).state = null,
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('Expenses'),
          selected: typeFilter == CategoryType.expense,
          onSelected: (_) => ref
              .read(categoryTypeFilterProvider.notifier)
              .state = CategoryType.expense,
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('Income'),
          selected: typeFilter == CategoryType.income,
          onSelected: (_) => ref
              .read(categoryTypeFilterProvider.notifier)
              .state = CategoryType.income,
        ),
      ],
    );

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Category Taxonomy',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => CategoryEditorDialog.show(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Hierarchical categories',
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
                      'Category Taxonomy',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hierarchical income, expense, and transfer categories',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textTheme.bodyMedium?.color
                            ?.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => CategoryEditorDialog.show(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Category'),
                ),
              ],
            ),
          const SizedBox(height: 20),
          // Search & Filter Row
          if (isMobile) ...[
            TextField(
              onChanged: (val) =>
                  ref.read(categorySearchQueryProvider.notifier).state = val,
              decoration: InputDecoration(
                hintText: 'Search categories...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => ref
                            .read(categorySearchQueryProvider.notifier)
                            .state = '',
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: filterChips,
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) => ref
                        .read(categorySearchQueryProvider.notifier)
                        .state = val,
                    decoration: InputDecoration(
                      hintText: 'Search categories...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () => ref
                                  .read(categorySearchQueryProvider.notifier)
                                  .state = '',
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                filterChips,
              ],
            ),
          const SizedBox(height: 24),
          Expanded(
            child: AnimatedSwitcher(
              duration: MonetraDesignSystem.durationNormal,
              child: categoryTree.isEmpty
                  ? const MonetraEmptyState(
                      icon: Icons.category_outlined,
                      title: 'No Categories Found',
                      description: 'No matching categories were found. You can add a new one by clicking the Add Category button.',
                    )
                  : ListView.builder(
                      itemCount: categoryTree.length,
                    itemBuilder: (context, index) {
                      final parent = categoryTree.keys.elementAt(index);
                      final children = categoryTree[parent] ?? [];
                      final parentColor =
                          MonetraColors.hexToColor(parent.colorHex);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: MonetraCard(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: parentColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    IconHelper.getIconData(parent.icon),
                                    color: parentColor,
                                    size: 20,
                                  ),
                                ),
                                title: Text(parent.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                                subtitle: Text(parent.type.name.toUpperCase(),
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: theme.textTheme.bodyMedium?.color
                                            ?.withValues(alpha: 0.6))),
                                trailing: IconButton(
                                  icon: const Icon(Icons.more_vert_rounded,
                                      size: 18),
                                  onPressed: () => _showCategoryActions(
                                      context, ref, parent),
                                ),
                                onTap: () => CategoryEditorDialog.show(context,
                                    category: parent),
                              ),
                              if (children.isNotEmpty) ...[
                                const Divider(height: 1, indent: 56),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 56, top: 4, bottom: 4),
                                  child: Column(
                                    children: children.map((child) {
                                      final childColor =
                                          MonetraColors.hexToColor(
                                              child.colorHex);
                                      return ListTile(
                                        dense: true,
                                        leading: Icon(
                                            Icons
                                                .subdirectory_arrow_right_rounded,
                                            size: 16,
                                            color: childColor),
                                        title: Text(child.name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13)),
                                        trailing: IconButton(
                                          icon: const Icon(
                                              Icons.more_horiz_rounded,
                                              size: 16),
                                          onPressed: () => _showCategoryActions(
                                              context, ref, child),
                                        ),
                                        onTap: () => CategoryEditorDialog.show(
                                            context,
                                            category: child),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
