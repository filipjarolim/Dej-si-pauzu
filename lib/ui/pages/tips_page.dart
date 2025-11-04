import 'package:flutter/material.dart';

import '../foundations/spacing.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_bottom_nav.dart';

class TipsPage extends StatelessWidget {
  const TipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return AppScaffold(
      appBar: AppBar(title: const Text('Tipy na zklidnění')),
      bottomBar: const AppBottomNav(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const <Widget>[
          SizedBox(height: AppSpacing.xl),
          Text('Krátké rady a nápady, jak se uvolnit a pečovat o sebe.'),
        ],
      ),
    );
  }
}
