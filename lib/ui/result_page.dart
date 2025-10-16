import 'dart:io';

import 'package:flutter/material.dart';
import 'package:foodie_ml/widget/classification_item.dart';
import 'package:foodie_ml/provider/image_classification_provider.dart';
import 'package:foodie_ml/services/image_classification_service.dart';
import 'package:provider/provider.dart';

class ResultPage extends StatelessWidget {
  final String imagePath;

  const ResultPage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    // Wrap with Provider to make it available to ResultPage
    return ChangeNotifierProvider(
      create: (_) => ImageClassificationViewmodel(ImageClassificationService()),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Result Page'),
        ),
        body: SafeArea(child: _ResultBody(imagePath: imagePath)),
      ),
    );
  }
}

class _ResultBody extends StatefulWidget {
  final String imagePath;

  const _ResultBody({required this.imagePath});

  @override
  State<_ResultBody> createState() => _ResultBodyState();
}

class _ResultBodyState extends State<_ResultBody> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _runInference();
  }

  Future<void> _runInference() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Run inference from file
      await context
          .read<ImageClassificationViewmodel>()
          .runClassificationFromFile(widget.imagePath);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: widget.imagePath.startsWith('http')
              ? Image.network(widget.imagePath, fit: BoxFit.contain)
              : Image.file(File(widget.imagePath), fit: BoxFit.contain),
        ),
        Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.3,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Analyzing image...'),
                      ],
                    ),
                  )
                : _error != null
                ? Center(
                    child: Text(
                      'Error: $_error',
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  )
                : Consumer<ImageClassificationViewmodel>(
                    builder: (context, viewModel, child) {
                      final classifications = viewModel.classifications;

                      if (classifications.isEmpty) {
                        return const Center(child: Text('No results found'));
                      }

                      return Column(
                        spacing: 8,
                        children: classifications.entries.map((entry) {
                          final percentage = (entry.value).toStringAsFixed(2);
                          return ClassificatioinItem(
                            item: entry.key,
                            value: "$percentage%",
                          );
                        }).toList(),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
