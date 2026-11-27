import 'package:flutter/material.dart';
import 'package:tandem/core/l10n/l10n_extension.dart';
import 'package:tandem/core/theme/app_colors.dart';
import 'package:tandem/core/theme/app_spacing.dart';
import 'package:tandem/core/theme/theme_context.dart';

/// The page frame: paper background, safe area, an optional header with a back
/// button and a title, an optional bottom bar. Primary actions go at the bottom
/// of [body] (the bottom third, spec section 6).
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    super.key,
    this.title,
    this.onBack,
    this.trailing,
    this.bottom,
    this.floatingActionButton,
    this.padding = const EdgeInsetsDirectional.fromSTEB(
      AppSpacing.md,
      AppSpacing.sm,
      AppSpacing.md,
      AppSpacing.md,
    ),
  });

  final Widget body;
  final String? title;
  final VoidCallback? onBack;
  final Widget? trailing;
  final Widget? bottom;
  final Widget? floatingActionButton;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final hasHeader = title != null || onBack != null || trailing != null;
    return Scaffold(
      backgroundColor: AppColors.paper,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottom,
      body: SafeArea(
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (hasHeader)
                AppHeader(title: title, onBack: onBack, trailing: trailing),
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}

class AppHeader extends StatelessWidget {
  const AppHeader({super.key, this.title, this.onBack, this.trailing});

  final String? title;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final type = context.type;
    return SizedBox(
      height: AppSpacing.minTap + AppSpacing.sm,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: AppSpacing.minTap,
            child: onBack == null
                ? null
                : Semantics(
                    button: true,
                    label: context.l10n.common_back,
                    excludeSemantics: true,
                    child: Material(
                      color: AppColors.light,
                      shape: const CircleBorder(side: BorderSide(color: AppColors.rule)),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onBack,
                        child: const SizedBox(
                          width: AppSpacing.minTap,
                          height: AppSpacing.minTap,
                          child: Icon(Icons.arrow_back_rounded, size: 22),
                        ),
                      ),
                    ),
                  ),
          ),
          Expanded(
            child: title == null
                ? const SizedBox.shrink()
                : Semantics(
                    header: true,
                    child: Text(
                      title!,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: type.heading(type.lg),
                    ),
                  ),
          ),
          SizedBox(width: AppSpacing.minTap, child: trailing),
        ],
      ),
    );
  }
}
