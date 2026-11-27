/// What went wrong with a request, in terms the app can translate.
///
/// The backend answers errors as `{"code": "LAST_ADMIN", "message": "...",
/// "detail": {...}}`. The app maps the *code* to a translated text
/// (`error_messages.dart`) and never shows the English `message`.
enum ApiErrorKind {
  unauthenticated,
  invalidCredentials,
  forbidden,
  notFound,
  validation,
  emailTaken,
  lastAdmin,
  taskNotFound,
  notAssignee,
  taskConflict,
  planRequired,
  network,
  unknown,
}

const Map<String, ApiErrorKind> _kinds = <String, ApiErrorKind>{
  'UNAUTHENTICATED': ApiErrorKind.unauthenticated,
  'INVALID_CREDENTIALS': ApiErrorKind.invalidCredentials,
  'FORBIDDEN': ApiErrorKind.forbidden,
  'NOT_FOUND': ApiErrorKind.notFound,
  'VALIDATION_ERROR': ApiErrorKind.validation,
  'EMAIL_TAKEN': ApiErrorKind.emailTaken,
  'LAST_ADMIN': ApiErrorKind.lastAdmin,
  'TASK_NOT_FOUND': ApiErrorKind.taskNotFound,
  'NOT_ASSIGNEE': ApiErrorKind.notAssignee,
  'TASK_CONFLICT': ApiErrorKind.taskConflict,
  'PLAN_REQUIRED': ApiErrorKind.planRequired,
};

class ApiError implements Exception {
  const ApiError({
    required this.kind,
    this.code,
    this.statusCode,
    this.detail = const <String, dynamic>{},
  });

  /// No answer from the server: offline, timeout, DNS.
  const ApiError.network()
      : kind = ApiErrorKind.network,
        code = null,
        statusCode = null,
        detail = const <String, dynamic>{};

  /// Reads the body of an error response. Anything unexpected is `unknown`.
  factory ApiError.fromResponse(int? statusCode, Object? data) {
    if (data is Map<String, dynamic>) {
      final code = data['code'];
      final detail = data['detail'];
      if (code is String) {
        return ApiError(
          kind: _kinds[code] ?? ApiErrorKind.unknown,
          code: code,
          statusCode: statusCode,
          detail: detail is Map<String, dynamic>
              ? detail
              : const <String, dynamic>{},
        );
      }
    }
    return ApiError(kind: ApiErrorKind.unknown, statusCode: statusCode);
  }

  final ApiErrorKind kind;
  final String? code;
  final int? statusCode;
  final Map<String, dynamic> detail;

  bool get isNetwork => kind == ApiErrorKind.network;

  @override
  String toString() => 'ApiError($kind, code: $code, status: $statusCode)';
}
