import 'package:flutter/material.dart';

class ClassificatioinItem extends StatelessWidget {
  final String item;
  final String value;

  const ClassificatioinItem({
    super.key,
    required this.item,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(item, style: Theme.of(context).textTheme.headlineMedium),
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class ClassificatioinItemShimmer extends StatelessWidget {
  const ClassificatioinItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ColoredBox(
            color: Colors.black,
            child: Text(
              "Food name",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          const Spacer(),
          ColoredBox(
            color: Colors.black,
            child: Text(
              "34%",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ],
      ),
    );
  }
}
