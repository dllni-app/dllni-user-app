class AuthPhoneParams {
  final String phone;

  const AuthPhoneParams({required this.phone});

  Map<String, dynamic> getBody() {
    return {
      'phone': phone,
    };
  }
}

class ResetPasswordConfirmParams {
  final String phone;
  final String otp;
  final String password;
  final String passwordConfirmation;

  const ResetPasswordConfirmParams({
    required this.phone,
    required this.otp,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> getBody() {
    return {
      'phone': phone,
      'otp': otp,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
  }
}
