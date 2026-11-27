import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tandem/core/l10n/l10n_extension.dart';
import 'package:tandem/core/theme/app_colors.dart';
import 'package:tandem/core/theme/app_spacing.dart';
import 'package:tandem/core/theme/theme_context.dart';
import 'package:tandem/core/widgets/app_scaffold.dart';

/// The short privacy policy, in the three languages of the app.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final type = context.type;
    final points = <String>[
      l10n.settings_policyStored,
      l10n.settings_policyServer,
      l10n.settings_policyPush,
      l10n.settings_policyDelete,
    ];
    return AppScaffold(
      title: l10n.settings_privacyPolicyTitle,
      onBack: context.pop,
      body: ListView(
        children: <Widget>[
          for (final point in points)
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsetsDirectional.only(top: 4, end: AppSpacing.sm),
                    child: Icon(Icons.check_rounded, size: 18, color: AppColors.accentDeep),
                  ),
                  Expanded(child: Text(point, style: type.body())),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
