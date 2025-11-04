import 'package:flutter/material.dart';

import '../foundations/spacing.dart';
import '../widgets/app_button.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_bottom_nav.dart';

class PausePage extends StatelessWidget {
  const PausePage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return AppScaffold(
      appBar: AppBar(title: const Text('Pauza')),
      bottomBar: const AppBottomNav(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: AppSpacing.xl),
          Text('Zastav se a nadechni', style: text.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          const Text('Krátká pauza ti může ulevit od stresu.'),
          const SizedBox(height: AppSpacing.xl),
          AppButton(label: 'Začít pauzu', onPressed: () {}),
        ],
      ),
    );
  }
}
