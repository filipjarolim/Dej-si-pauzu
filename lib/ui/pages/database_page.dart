import 'package:flutter/material.dart';

import '../foundations/spacing.dart';
import '../widgets/app_scaffold.dart';

class DatabasePage extends StatelessWidget {
  const DatabasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Database')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const <Widget>[
          SizedBox(height: AppSpacing.xl),
          Text('Database page'),
        ],
      ),
    );
  }
}
