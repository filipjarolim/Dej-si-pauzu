import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../foundations/spacing.dart';
import '../widgets/app_button.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/shimmer.dart';
import '../widgets/app_bottom_nav.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  bool _loading = true;

  void _toggle() => setState(() => _loading = !_loading);

  Future<void> _refresh() async {
    // No mock data is fetched; just a quick UI refresh gesture.
    await Future<void>.delayed(AppConstants.refreshDelay);
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('List')),
      bottomBar: const AppBottomNav(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: _loading ? 'Show content' : 'Show skeletons',
            onPressed: _toggle,
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: RefreshIndicator.adaptive(
              onRefresh: _refresh,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: 12,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
                itemBuilder: (BuildContext context, int index) {
                  if (_loading) {
                    return const _SkeletonListItem();
                  }
                  return const _ContentTile();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonListItem extends StatelessWidget {
  const _SkeletonListItem();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: <Widget>[
        SkeletonBox(width: 56, height: 56, borderRadius: 12),
        SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SkeletonBox(width: double.infinity, height: 14),
              SizedBox(height: AppSpacing.sm),
              SkeletonBox(width: 160, height: 12),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContentTile extends StatelessWidget {
  const _ContentTile();

  @override
  Widget build(BuildContext context) {
    // No mock data here; just a generic content skeleton replacement.
    return Row(
      children: <Widget>[
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 16,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: 160,
                height: 12,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

