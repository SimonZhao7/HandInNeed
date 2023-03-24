class AuthException implements Exception {}

class GenericAuthException implements AuthException {}

class NotSignedInAuthException implements AuthException {}

class GoogleSignInAuthException implements AuthException {}

// Phone Verification
class InvalidPhoneNumberAuthException implements AuthException {}

class TooManyRequestsAuthException implements AuthException {}

class InvalidVerificationCodeAuthException implements AuthException {}

class PhoneNumberAlreadyInUseAuthException implements AuthException {}

class SessionExpiredAuthException implements AuthException {}

// Account Setup
class NoEmailProvidedAuthException implements AuthException {}

class NoUserNameProvidedAuthException implements AuthException {}

class UserNameTooShortAuthException implements AuthException {}

class UserNameAlreadyExistsAuthException implements AuthException {}

class NoFirstNameProvidedAuthException implements AuthException {}

class NoLastNameProvidedAuthException implements AuthException {}

class NoProfilePictureProvidedAuthException implements AuthException {}

class InvalidEmailAuthException implements AuthException {}

class EmailAlreadyInUseAuthException implements AuthException {}

class RequiresRecentLoginAuthException implements AuthException {}
