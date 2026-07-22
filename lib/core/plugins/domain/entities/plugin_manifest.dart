import 'package:equatable/equatable.dart';

enum PluginPermission {
  readTransactions,
  writeTransactions,
  readAccounts,
  writeAccounts,
  importFiles,
  exportFiles,
  dashboardAccess,
  pluginStorage,
}

enum PluginStatus { installed, enabled, disabled, error }

class PluginManifest extends Equatable {
  final String id;
  final String name;
  final String version;
  final String author;
  final String description;
  final String minMonetraVersion;
  final List<PluginPermission> permissions;
  final String entryPoint;
  final PluginStatus status;

  const PluginManifest({
    required this.id,
    required this.name,
    required this.version,
    required this.author,
    required this.description,
    required this.minMonetraVersion,
    required this.permissions,
    required this.entryPoint,
    this.status = PluginStatus.installed,
  });

  PluginManifest copyWith({
    String? id,
    String? name,
    String? version,
    String? author,
    String? description,
    String? minMonetraVersion,
    List<PluginPermission>? permissions,
    String? entryPoint,
    PluginStatus? status,
  }) {
    return PluginManifest(
      id: id ?? this.id,
      name: name ?? this.name,
      version: version ?? this.version,
      author: author ?? this.author,
      description: description ?? this.description,
      minMonetraVersion: minMonetraVersion ?? this.minMonetraVersion,
      permissions: permissions ?? this.permissions,
      entryPoint: entryPoint ?? this.entryPoint,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        version,
        author,
        description,
        minMonetraVersion,
        permissions,
        entryPoint,
        status,
      ];
}
