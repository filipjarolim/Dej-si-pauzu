import 'package:flutter/material.dart';

import '../foundations/spacing.dart';
import '../widgets/app_button.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_bottom_nav.dart';

class MoodPage extends StatelessWidget {
  const MoodPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return AppScaffold(
      appBar: AppBar(title: const Text('Nálada')),
      bottomBar: const AppBottomNav(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: AppSpacing.xl),
          Text('Jak se máš?', style: text.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          const Text('Krátké zaznamenání nálady ti pomůže lépe porozumět sobě.'),
          const SizedBox(height: AppSpacing.xl),
          AppButton(label: 'Zaznamenat náladu', onPressed: () {}),
        ],
      ),
    );
  }
}
