import 'package:flutter/material.dart';
import 'package:tandem/core/theme/app_spacing.dart';
import 'package:tandem/core/theme/theme_context.dart';

/// A labelled text field. The label sits above the field, as in the design.
class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    required this.controller,
    super.key,
    this.errorText,
    this.hint,
    this.onChanged,
    this.keyboardType,
    this.textInputAction,
    this.minLines = 1,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
  });

  final String label;
  final TextEditingController controller;
  final String? errorText;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int minLines;
  final int maxLines;
  final int? maxLength;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final type = context.type;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: type.label()),
        const SizedBox(height: AppSpacing.xxs),
        TextField(
          controller: controller,
          onChanged: onChanged,
          enabled: enabled,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          minLines: minLines,
          maxLines: maxLines,
          maxLength: maxLength,
          style: type.body(),
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            counterText: '',
          ),
        ),
      ],
    );
  }
}
