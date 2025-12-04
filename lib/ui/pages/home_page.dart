import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_constants.dart';
import '../../core/extensions/build_context_extensions.dart';
import '../../core/constants/app_routes.dart';
import '../../core/services/database_service.dart';
import '../foundations/spacing.dart';
import '../widgets/app_button.dart';
import '../widgets/app_loading.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/progress_ring.dart';
import '../widgets/plan_item.dart';
import '../widgets/custom_refresh_indicator.dart';
import '../widgets/quick_actions_widget.dart';
import '../foundations/design_tokens.dart';
import '../foundations/colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loading = false;
  final DatabaseService _db = DatabaseService();

  Future<void> _simulateWork() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _refresh() async {
    await Future<void>.delayed(AppConstants.refreshDelay);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _insertTestDocument() async {
    if (!_db.isConnected) {
      await _db.initialize();
    }

    if (!_db.isConnected) {
      _showSnackBar('Database not connected', AppColors.error);
      return;
    }

    try {
      final Map<String, dynamic> testDoc = <String, dynamic>{
        'name': 'Test Document',
        'type': 'dev_test',
        'timestamp': DateTime.now().toIso8601String(),
        'data': <String, dynamic>{
          'value': 42,
          'message': 'Hello from Flutter!',
        },
      };

      await _db.insertOne('test_collection', testDoc);
      _showSnackBar('Document inserted successfully!', AppColors.success);
      HapticFeedback.mediumImpact();
    } catch (e) {
      _showSnackBar('Error: $e', AppColors.error);
    }
  }

  Future<void> _findTestDocuments() async {
    if (!_db.isConnected) {
      await _db.initialize();
    }

    if (!_db.isConnected) {
      _showSnackBar('Database not connected', AppColors.error);
      return;
    }

    try {
      final List<Map<String, dynamic>> docs = await _db.find(
        'test_collection',
        filter: <String, dynamic>{'type': 'dev_test'},
        limit: 10,
      );
      _showSnackBar('Found ${docs.length} documents', AppColors.success);
      HapticFeedback.mediumImpact();
    } catch (e) {
      _showSnackBar('Error: $e', AppColors.error);
    }
  }

  Future<void> _updateTestDocument() async {
    if (!_db.isConnected) {
      await _db.initialize();
    }

    if (!_db.isConnected) {
      _showSnackBar('Database not connected', AppColors.error);
      return;
    }

    try {
      final Map<String, dynamic>? doc = await _db.findOne(
        'test_collection',
        filter: <String, dynamic>{'type': 'dev_test'},
      );

      if (doc == null) {
        _showSnackBar('No document found to update', AppColors.warning);
        return;
      }

      await _db.updateOne(
        'test_collection',
        <String, dynamic>{'_id': doc['_id']},
        <String, dynamic>{
          'updatedAt': DateTime.now().toIso8601String(),
          'updated': true,
        },
      );
      _showSnackBar('Document updated successfully!', AppColors.success);
      HapticFeedback.mediumImpact();
    } catch (e) {
      _showSnackBar('Error: $e', AppColors.error);
    }
  }

  Future<void> _deleteTestDocument() async {
    if (!_db.isConnected) {
      await _db.initialize();
    }

    if (!_db.isConnected) {
      _showSnackBar('Database not connected', AppColors.error);
      return;
    }

    try {
      final Map<String, dynamic>? doc = await _db.findOne(
        'test_collection',
        filter: <String, dynamic>{'type': 'dev_test'},
      );

      if (doc == null) {
        _showSnackBar('No document found to delete', AppColors.warning);
        return;
      }

      await _db.deleteOne(
        'test_collection',
        <String, dynamic>{'_id': doc['_id']},
      );
      _showSnackBar('Document deleted successfully!', AppColors.success);
      HapticFeedback.mediumImpact();
    } catch (e) {
      _showSnackBar('Error: $e', AppColors.error);
    }
  }

  Future<void> _countTestDocuments() async {
    if (!_db.isConnected) {
      await _db.initialize();
    }

    if (!_db.isConnected) {
      _showSnackBar('Database not connected', AppColors.error);
      return;
    }

    try {
      final int count = await _db.count('test_collection');
      _showSnackBar('Total documents: $count', AppColors.success);
      HapticFeedback.lightImpact();
    } catch (e) {
      _showSnackBar('Error: $e', AppColors.error);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _heroCard(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(
          color: AppColors.gray200,
          width: DesignTokens.borderMedium,
        ),
        boxShadow: DesignTokens.shadowMd,
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 0,
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: const ProgressRing(progress: 0.68, size: 100, stroke: 10),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Ahoj!',
                  style: text.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Pokračuj v cestě za klidem. Krátká pauza tě čeká kdykoliv.',
                  style: text.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                        ),
                      ),
                    onPressed: () => context.navigateToPause(),
                    icon: const Icon(Icons.play_arrow_rounded, size: 20),
                    label: Text(
                      'Začít pauzu',
                      style: text.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
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

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    return Stack(
      children: <Widget>[
        AppScaffold(
          appBar: AppBar(
            leading: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                onTap: () => context.navigateToProfile(),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Hero(
                    tag: 'app-logo',
                    child: Image(
                      image: AssetImage('icon512.png'),
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            title: const Text('Domů'),
          ),
          bottomBar: null, // Navbar provided by ShellRoute
          body: CustomRefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: AppSpacing.xl),
              children: <Widget>[
                // Top action chip row
                Row(
                  children: <Widget>[
                    Expanded(
                    child: Material(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                      onTap: () => context.navigateToPartner(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                            border: Border.all(
                              color: AppColors.gray200,
                              width: DesignTokens.borderThin,
                            ),
                          ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  Icons.psychology_alt,
                                  size: DesignTokens.iconSm,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Chat s Parťákem',
                                  style: text.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Material(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                        onTap: () => context.navigateToSettings(),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                            border: Border.all(
                              color: AppColors.gray200,
                              width: DesignTokens.borderThin,
                            ),
                          ),
                          child: Icon(
                            Icons.settings_rounded,
                            size: DesignTokens.iconSm,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _heroCard(context),
                const SizedBox(height: AppSpacing.xl),
                // Quick Actions Widget
                const QuickActionsWidget(),
                const SizedBox(height: AppSpacing.xl),
                // Today's plan
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Dnešní plán',
                            style: text.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '7 min',
                            style: text.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: Text(
                        'Upravit',
                        style: text.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const PlanItem(
                  title: 'Přečti si uklidňující afirmaci',
                  badge: 'AFIRMACE',
                  icon: Icons.self_improvement,
                ),
                const SizedBox(height: 10),
                const PlanItem(
                  title: 'Sleduj, jak se cítíš',
                  badge: 'NÁLADA',
                  icon: Icons.mood,
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Database / Dev',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: <Widget>[
                    _DatabaseButton(
                      icon: Icons.table_chart,
                      label: 'View Database',
                      onPressed: () => context.navigateTo(AppRoutes.database),
                      color: AppColors.primary,
                ),
                    _DatabaseButton(
                      icon: Icons.add_circle_outline,
                      label: 'Insert Test',
                      onPressed: _insertTestDocument,
                      color: AppColors.success,
                    ),
                    _DatabaseButton(
                      icon: Icons.search,
                      label: 'Find Test',
                      onPressed: _findTestDocuments,
                      color: AppColors.skyBlue,
                ),
                    _DatabaseButton(
                      icon: Icons.edit_outlined,
                      label: 'Update Test',
                      onPressed: _updateTestDocument,
                      color: AppColors.warning,
                    ),
                    _DatabaseButton(
                      icon: Icons.delete_outline,
                      label: 'Delete Test',
                      onPressed: _deleteTestDocument,
                      color: AppColors.error,
                    ),
                    _DatabaseButton(
                      icon: Icons.refresh,
                      label: 'Count Test',
                      onPressed: _countTestDocuments,
                      color: AppColors.mintGreen,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Utility / Dev',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(label: 'Run task', onPressed: _simulateWork),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Open list skeleton demo',
                  onPressed: () => context.navigateTo(AppRoutes.list),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
        LoadingOverlay(show: _loading, message: 'Working...')
      ],
    );
  }
}

class _DatabaseButton extends StatelessWidget {
  const _DatabaseButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return SizedBox(
      width: 120,
      child: Material(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(icon, color: color, size: 24),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  label,
                  style: text.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

