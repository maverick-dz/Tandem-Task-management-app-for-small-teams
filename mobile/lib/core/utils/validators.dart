/// Form checks shared by the profile and feedback screens. They mirror the
/// backend (`UserUpdate`, `FeedbackCreate`), which stays the authority.
enum FieldError { nameRequired, emailInvalid, messageEmpty }

FieldError? validateName(String value) =>
    value.trim().isEmpty ? FieldError.nameRequired : null;

final RegExp _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

FieldError? validateEmail(String value) =>
    _email.hasMatch(value.trim()) ? null : FieldError.emailInvalid;

/// The backend accepts at most this many characters.
const int maxFeedbackLength = 2000;

FieldError? validateFeedbackMessage(String value) =>
    value.trim().isEmpty ? FieldError.messageEmpty : null;
