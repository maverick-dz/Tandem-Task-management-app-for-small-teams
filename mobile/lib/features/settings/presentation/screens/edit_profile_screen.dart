import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tandem/core/l10n/l10n_extension.dart';
import 'package:tandem/core/network/api_error.dart';
import 'package:tandem/core/network/current_user.dart';
import 'package:tandem/core/network/error_messages.dart';
import 'package:tandem/core/router/route_names.dart';
import 'package:tandem/core/theme/app_colors.dart';
import 'package:tandem/core/theme/app_spacing.dart';
import 'package:tandem/core/utils/validators.dart';
import 'package:tandem/core/widgets/app_button.dart';
import 'package:tandem/core/widgets/app_scaffold.dart';
import 'package:tandem/core/widgets/app_text_field.dart';
import 'package:tandem/core/widgets/avatar_initial.dart';
import 'package:tandem/core/widgets/info_banner.dart';
import 'package:tandem/core/widgets/loading_skeleton.dart';
import 'package:tandem/features/settings/data/profile_repository.dart';

/// Screen 057: change the name and the email.
class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = ref.watch(currentUserProvider);
    return AppScaffold(
      title: l10n.settings_editProfileTitle,
      onBack: context.pop,
      body: user.when(
        data: (u) => _ProfileForm(user: u),
        loading: () => const LoadingSkeleton(rows: 2),
        error: (error, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            InfoBanner(
              text: error is ApiError
                  ? apiErrorMessage(l10n, error)
                  : l10n.common_loadFailed,
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: l10n.common_retry,
              variant: AppButtonVariant.secondary,
              onPressed: () => ref.invalidate(currentUserProvider),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileForm extends ConsumerStatefulWidget {
  const _ProfileForm({required this.user});

  final CurrentUser user;

  @override
  ConsumerState<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<_ProfileForm> {
  late final TextEditingController _name = TextEditingController(text: widget.user.fullName);
  late final TextEditingController _email = TextEditingController(text: widget.user.email);
  bool _showErrors = false;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _showErrors = true);
    if (validateName(_name.text) != null || validateEmail(_email.text) != null) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      await ref.read(profileRepositoryProvider).updateProfile(
            fullName: _name.text.trim(),
            email: _email.text.trim(),
          );
      ref.invalidate(currentUserProvider);
      messenger.showSnackBar(SnackBar(content: Text(l10n.settings_profileSaved)));
      if (mounted) context.pop();
    } on ApiError catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(apiErrorMessage(l10n, error))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: ListView(
            children: <Widget>[
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: AvatarInitial(
                  initial: widget.user.initial,
                  tint: AppColors.tintSand,
                  size: 56,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: l10n.settings_fullName,
                controller: _name,
                textInputAction: TextInputAction.next,
                errorText: _showErrors && validateName(_name.text) != null
                    ? l10n.settings_nameRequired
                    : null,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: l10n.settings_email,
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                errorText: _showErrors && validateEmail(_email.text) != null
                    ? l10n.settings_emailInvalid
                    : null,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.xs),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: AppLinkButton(
                  label: l10n.settings_changePassword,
                  onPressed: () => context.push(RouteNames.changePassword),
                ),
              ),
            ],
          ),
        ),
        AppButton(
          label: l10n.settings_saveChanges,
          onPressed: _saving ? null : _save,
          isLoading: _saving,
        ),
      ],
    );
  }
}
