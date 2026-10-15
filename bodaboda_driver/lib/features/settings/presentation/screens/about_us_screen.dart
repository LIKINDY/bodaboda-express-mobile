import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          'Bodaboda Express is a professional ride-sharing platform dedicated to providing you the best rideshare experience with a focus on dependability and earnings. We\'re working to turn our passion for rideshare into a booming service for everyone.\n\nWe hope you enjoy our services as much as we enjoy offering them to you. We will keep improving our platform to provide you with the best experience possible.',
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }
}
