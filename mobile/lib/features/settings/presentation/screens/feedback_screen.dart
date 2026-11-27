import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tandem/core/l10n/l10n_extension.dart';
import 'package:tandem/core/network/api_error.dart';
import 'package:tandem/core/network/error_messages.dart';
import 'package:tandem/core/theme/app_spacing.dart';
import 'package:tandem/core/theme/theme_context.dart';
import 'package:tandem/core/utils/validators.dart';
import 'package:tandem/core/widgets/app_button.dart';
import 'package:tandem/core/widgets/app_scaffold.dart';
import 'package:tandem/core/widgets/app_text_field.dart';
import 'package:tandem/core/widgets/segmented_filter.dart';
import 'package:tandem/features/settings/data/feedback_repository.dart';

/// Screen 058: a problem, an idea or something else, in a few words.
class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  final TextEditingController _message = TextEditingController();
  FeedbackKind _kind = FeedbackKind.idea;
  bool _sending = false;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  bool get _canSend => validateFeedbackMessage(_message.text) == null && !_sending;

  Future<void> _send() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _sending = true);
    try {
      await ref.read(feedbackRepositoryProvider).send(kind: _kind, message: _message.text);
      messenger.showSnackBar(SnackBar(content: Text(l10n.settings_feedbackThanks)));
      if (mounted) context.pop();
    } on ApiError catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(apiErrorMessage(l10n, error))));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final type = context.type;
    return AppScaffold(
      title: l10n.settings_feedbackTitle,
      onBack: context.pop,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: ListView(
              children: <Widget>[
                Text(l10n.settings_feedbackIntro, style: type.caption()),
                const SizedBox(height: AppSpacing.md),
                Text(l10n.settings_feedbackAbout, style: type.label()),
                const SizedBox(height: AppSpacing.xs),
                SegmentedFilter<FeedbackKind>(
                  value: _kind,
                  onChanged: (kind) => setState(() => _kind = kind),
                  options: <SegmentOption<FeedbackKind>>[
                    SegmentOption<FeedbackKind>(
                      value: FeedbackKind.problem,
                      label: l10n.settings_kindProblem,
                    ),
                    SegmentOption<FeedbackKind>(
                      value: FeedbackKind.idea,
                      label: l10n.settings_kindIdea,
                    ),
                    SegmentOption<FeedbackKind>(
                      value: FeedbackKind.other,
                      label: l10n.settings_kindOther,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: l10n.settings_feedbackMessage,
                  hint: l10n.settings_feedbackHint,
                  controller: _message,
                  minLines: 5,
                  maxLines: 8,
                  maxLength: maxFeedbackLength,
                  keyboardType: TextInputType.multiline,
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          ),
          AppButton(
            label: l10n.settings_feedbackSend,
            onPressed: _canSend ? _send : null,
            isLoading: _sending,
          ),
        ],
      ),
    );
  }
}
