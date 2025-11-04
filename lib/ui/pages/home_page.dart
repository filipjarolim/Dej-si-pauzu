import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../foundations/spacing.dart';
import '../widgets/app_button.dart';
import '../widgets/app_loading.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_bottom_nav.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loading = false;

  Future<void> _simulateWork() async {
    setState(() => _loading = true);
    // Replace with real work; no mock data is used here.
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AppScaffold(
          appBar: AppBar(
            leading: const Hero(tag: 'app-logo', child: Icon(Icons.self_improvement)),
            title: const Text('Home'),
          ),
          bottomBar: const AppBottomNav(),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Welcome',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text('Press the button to simulate a quick task.'),
              const SizedBox(height: AppSpacing.xl),
              AppButton(label: 'Run task', onPressed: _simulateWork),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Open list skeleton demo',
                onPressed: () => context.push('/list'),
              ),
            ],
          ),
        ),
        LoadingOverlay(show: _loading, message: 'Working...')
      ],
    );
  }
}

