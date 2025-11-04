import 'package:flutter/material.dart';

import '../foundations/spacing.dart';
import '../widgets/app_scaffold.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Auth')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const <Widget>[
          SizedBox(height: AppSpacing.xl),
          Text('Auth page'),
        ],
      ),
    );
  }
}
