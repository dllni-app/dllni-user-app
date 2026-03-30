/// Payload for updating profile (no [dart:io] here — avatar is a local file path when present).
class RsPersonalDetailsUpdateInput {
  const RsPersonalDetailsUpdateInput({
    required this.name,
    required this.dialCode,
    required this.phoneLocal,
    this.avatarPath,
    this.currentPassword,
    this.newPassword,
  });

  final String name;
  final String dialCode;
  final String phoneLocal;
  final String? avatarPath;
  final String? currentPassword;
  final String? newPassword;
}
