import 'package:flutter/material.dart';

class AppBackButton extends StatelessWidget {
  final String fallbackRoute;

  const AppBackButton({
    super.key,
    this.fallbackRoute = '/select',
  });

  Future<void> _goBack(BuildContext context) async {
    final popped = await Navigator.maybePop(context);
    if (!popped && context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, fallbackRoute, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => _goBack(context),
    );
  }
}
