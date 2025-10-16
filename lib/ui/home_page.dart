import 'dart:io';

import 'package:flutter/material.dart';
import 'package:foodie_ml/controller/home_provider.dart';
import 'package:foodie_ml/services/image_classification_service.dart';
import 'package:foodie_ml/ui/result_page.dart';
import 'package:foodie_ml/widget/widget_extension.dart';

import 'package:provider/provider.dart';
import 'package:foodie_ml/provider/image_classification_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(
          create: (_) =>
              ImageClassificationViewmodel(ImageClassificationService()),
        ),
      ],
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Online Image Classification"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const _HomeBody(),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            spacing: 4,
            children: [
              Expanded(
                child: Consumer<HomeProvider>(
                  builder: (context, value, child) {
                    final imagePath = value.imagePath;
                    return imagePath == null
                        ? const Align(
                            alignment: Alignment.center,
                            child: Icon(Icons.image, size: 100),
                          )
                        : Image.file(
                            File(imagePath.toString()),
                            fit: BoxFit.contain,
                          );
                  },
                ),
              ),
              Column(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    spacing: 8,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () =>
                            context.read<HomeProvider>().openGallery(),
                        child: const Text("Gallery"),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<HomeProvider>().openCamera(),
                        child: const Text("Camera"),
                      ),
                      ElevatedButton(
                        onPressed: () => context
                            .read<HomeProvider>()
                            .openCustomCamera(context),
                        child: const Text(
                          "Custom Camera",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ].expanded(),
                  ),
                  FilledButton.tonal(
                    onPressed: () {
                      final homeProvider = context.read<HomeProvider>();
                      final imagePath = homeProvider.imagePath;

                      if (imagePath == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please select an image first"),
                          ),
                        );
                        return;
                      }

                      // Navigate to result page with the image
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ResultPage(imagePath: imagePath),
                        ),
                      );
                    },
                    child: const Text("Analyze"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
