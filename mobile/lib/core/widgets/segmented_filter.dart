import 'package:flutter/material.dart';
import 'package:tandem/core/theme/app_spacing.dart';
import 'package:tandem/core/widgets/app_chip.dart';

class SegmentOption<T> {
  const SegmentOption({required this.value, required this.label});

  final T value;
  final String label;
}

/// A row of choice keys where exactly one is selected (Mine | Everyone,
/// List | Board, one language of three).
class SegmentedFilter<T> extends StatelessWidget {
  const SegmentedFilter({
    required this.options,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final List<SegmentOption<T>> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: <Widget>[
        for (final option in options)
          AppChoiceChip(
            label: option.label,
            selected: option.value == value,
            onTap: () => onChanged(option.value),
          ),
      ],
    );
  }
}
