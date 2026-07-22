import 'package:equatable/equatable.dart';

enum SearchResultType {
  transaction,
  account,
  category,
  budget,
  goal,
  report,
  command,
  setting
}

class SearchResultItem extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final SearchResultType type;
  final String targetRoute;
  final String icon;
  final double score;

  const SearchResultItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.targetRoute,
    this.icon = 'search',
    this.score = 1.0,
  });

  @override
  List<Object?> get props =>
      [id, title, subtitle, type, targetRoute, icon, score];
}

class CommandItem extends Equatable {
  final String id;
  final String label;
  final String description;
  final String targetRoute;
  final String icon;
  final String shortcut;

  const CommandItem({
    required this.id,
    required this.label,
    required this.description,
    required this.targetRoute,
    this.icon = 'touch_app',
    this.shortcut = 'Ctrl+K',
  });

  @override
  List<Object?> get props =>
      [id, label, description, targetRoute, icon, shortcut];
}
