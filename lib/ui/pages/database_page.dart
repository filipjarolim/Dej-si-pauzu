import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/database_service.dart';
import '../../core/constants/app_routes.dart';
import '../foundations/spacing.dart';
import '../foundations/design_tokens.dart';
import '../foundations/colors.dart';
import '../widgets/app_scaffold.dart';

class DatabasePage extends StatefulWidget {
  const DatabasePage({super.key});

  @override
  State<DatabasePage> createState() => _DatabasePageState();
}

class _DatabasePageState extends State<DatabasePage> {
  final DatabaseService _db = DatabaseService();
  bool _loading = false;
  List<String> _collections = <String>[];
  String? _selectedCollection;
  List<Map<String, dynamic>> _documents = <Map<String, dynamic>>[];
  Map<String, int> _collectionCounts = <String, int>{};

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    if (!_db.isConnected) {
      await _db.initialize();
    }

    if (!_db.isConnected) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Database not connected. Check your .env file.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    setState(() => _loading = true);
    try {
      final List<String?> collectionsNullable = await _db.database!.getCollectionNames();
      final List<String> collections = collectionsNullable
          .whereType<String>()
          .where((String name) => name.isNotEmpty)
          .toList();
      final Map<String, int> counts = <String, int>{};
      
      for (final String collection in collections) {
        final int count = await _db.count(collection);
        counts[collection] = count;
      }

      if (mounted) {
        setState(() {
          _collections = collections;
          _collectionCounts = counts;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading collections: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _loadDocuments(String collection) async {
    setState(() {
      _loading = true;
      _selectedCollection = collection;
    });

    try {
      final List<Map<String, dynamic>> docs = await _db.find(
        collection,
        sort: <String, dynamic>{'_id': -1},
        limit: 100,
      );

      if (mounted) {
        setState(() {
          _documents = docs;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading documents: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return AppScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
        title: const Text('Database Viewer'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCollections,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _loading && _documents.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: <Widget>[
                // Collections sidebar
                Container(
                  width: 250,
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    border: Border(
                      right: BorderSide(
                        color: AppColors.gray200,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Collections',
                              style: text.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: _db.isConnected
                                    ? AppColors.success.withOpacity(0.1)
                                    : AppColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _db.isConnected
                                          ? AppColors.success
                                          : AppColors.error,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(
                                    _db.isConnected ? 'Connected' : 'Disconnected',
                                    style: text.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: _db.isConnected
                                          ? AppColors.success
                                          : AppColors.error,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: _collections.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.lg),
                                  child: Text(
                                    'No collections found',
                                    style: text.bodyMedium?.copyWith(
                                      color: AppColors.gray600,
                                    ),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _collections.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final String collection = _collections[index];
                                  final bool isSelected =
                                      _selectedCollection == collection;
                                  final int count =
                                      _collectionCounts[collection] ?? 0;

                                  return Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => _loadDocuments(collection),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.lg,
                                          vertical: AppSpacing.md,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.primary.withOpacity(0.1)
                                              : Colors.transparent,
                                          border: Border(
                                            left: BorderSide(
                                              color: isSelected
                                                  ? AppColors.primary
                                                  : Colors.transparent,
                                              width: 3,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    collection,
                                                    style: text.titleSmall?.copyWith(
                                                      fontWeight: isSelected
                                                          ? FontWeight.w700
                                                          : FontWeight.w600,
                                                      color: isSelected
                                                          ? AppColors.primary
                                                          : AppColors.black,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    '$count documents',
                                                    style: text.bodySmall?.copyWith(
                                                      color: AppColors.gray600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (isSelected)
                                              const Icon(
                                                Icons.chevron_right,
                                                color: AppColors.primary,
                                                size: 20,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
                // Documents table
                Expanded(
                  child: _selectedCollection == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.table_chart_outlined,
                                size: 64,
                                color: AppColors.gray400,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                'Select a collection to view documents',
                                style: text.bodyLarge?.copyWith(
                                  color: AppColors.gray600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            // Header
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                border: Border(
                                  bottom: BorderSide(
                                    color: AppColors.gray200,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          _selectedCollection!,
                                          style: text.titleLarge?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        Text(
                                          '${_documents.length} documents',
                                          style: text.bodySmall?.copyWith(
                                            color: AppColors.gray600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy),
                                    onPressed: () {
                                      final String json = _documents
                                          .map((Map<String, dynamic> doc) =>
                                              doc.toString())
                                          .join('\n');
                                      Clipboard.setData(
                                        ClipboardData(text: json),
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('Copied to clipboard'),
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                    tooltip: 'Copy all',
                                  ),
                                ],
                              ),
                            ),
                            // Table
                            Expanded(
                              child: _loading
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : _documents.isEmpty
                                      ? Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Icon(
                                                Icons.inbox_outlined,
                                                size: 64,
                                                color: AppColors.gray400,
                                              ),
                                              const SizedBox(
                                                height: AppSpacing.lg,
                                              ),
                                              Text(
                                                'No documents found',
                                                style: text.bodyLarge?.copyWith(
                                                  color: AppColors.gray600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: SingleChildScrollView(
                                            child: _DataTable(
                                              documents: _documents,
                                            ),
                                          ),
                                        ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
    );
  }
}

class _DataTable extends StatelessWidget {
  const _DataTable({required this.documents});

  final List<Map<String, dynamic>> documents;

  List<String> get _allKeys {
    final Set<String> keys = <String>{};
    for (final Map<String, dynamic> doc in documents) {
      keys.addAll(doc.keys);
    }
    return keys.toList()..sort();
  }

  String _formatValue(dynamic value) {
    if (value == null) return 'null';
    if (value is DateTime) {
      return value.toIso8601String();
    }
    if (value is Map) {
      return '{...}';
    }
    if (value is List) {
      return '[...]';
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final List<String> keys = _allKeys;

    if (keys.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Table(
        border: TableBorder.all(
          color: AppColors.gray200,
          width: 1,
        ),
        columnWidths: <int, TableColumnWidth>{
          for (int i = 0; i < keys.length; i++)
            i: const FlexColumnWidth(1),
        },
        children: <TableRow>[
          // Header row
          TableRow(
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
            ),
            children: keys.map((String key) {
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  key,
                  style: text.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              );
            }).toList(),
          ),
          // Data rows
          ...documents.map((Map<String, dynamic> doc) {
            return TableRow(
              decoration: BoxDecoration(
                color: documents.indexOf(doc) % 2 == 0
                    ? AppColors.white
                    : AppColors.gray50,
              ),
              children: keys.map((String key) {
                final dynamic value = doc[key];
                return Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Tooltip(
                    message: _formatValue(value),
                    child: Text(
                      _formatValue(value),
                      style: text.bodySmall,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}
