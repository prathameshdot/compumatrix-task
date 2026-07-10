import 'package:flutter/material.dart';
import '../strings.dart';
import '../widgets/primary_button.dart';

class FirebaseErrorScreen extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;
  const FirebaseErrorScreen({super.key, required this.error, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off_rounded, size: 56, color: Colors.black),
                  const SizedBox(height: 16),
                  Text(
                    'Couldn\'t connect to ${AppStrings.appName}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Something went wrong starting the app. Check your internet '
                    'connection and try again.\n\n$error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(label: 'Retry', onPressed: onRetry),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
