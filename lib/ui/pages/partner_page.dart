import 'package:flutter/material.dart';

import '../foundations/spacing.dart';
import '../widgets/app_button.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_bottom_nav.dart';

class PartnerPage extends StatelessWidget {
  const PartnerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return AppScaffold(
      appBar: AppBar(title: const Text('Parťák pro pauzu')),
      bottomBar: const AppBottomNav(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: AppSpacing.xl),
          Text('Jsem tu pro tebe', style: text.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          const Text('Krátká konverzace, která ti pomůže zorientovat se v emocích.'),
          const SizedBox(height: AppSpacing.xl),
          AppButton(label: 'Začít konverzaci', onPressed: () {}),
        ],
      ),
    );
  }
}
