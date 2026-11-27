import 'package:tandem/core/network/api_error.dart';
import 'package:tandem/l10n/app_localizations.dart';

/// The translated text for an [ApiError]. Every kind has one.
String apiErrorMessage(AppLocalizations l10n, ApiError error) {
  return switch (error.kind) {
    ApiErrorKind.unauthenticated => l10n.errors_unauthenticated,
    ApiErrorKind.invalidCredentials => l10n.errors_invalidCredentials,
    ApiErrorKind.forbidden => l10n.errors_forbidden,
    ApiErrorKind.notFound => l10n.errors_unknown,
    ApiErrorKind.validation => l10n.errors_validation,
    ApiErrorKind.emailTaken => l10n.errors_emailTaken,
    ApiErrorKind.lastAdmin => l10n.errors_lastAdmin,
    ApiErrorKind.taskNotFound => l10n.errors_taskNotFound,
    ApiErrorKind.notAssignee => l10n.errors_notAssignee,
    ApiErrorKind.taskConflict => l10n.errors_taskConflict,
    ApiErrorKind.planRequired => l10n.errors_planRequired,
    ApiErrorKind.network => l10n.errors_network,
    ApiErrorKind.unknown => l10n.errors_unknown,
  };
}
