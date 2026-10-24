/// Some seeded product media are 1x1 transparent PNGs (68 bytes).
/// They have a valid URL but should be shown as missing photos rather than
/// stretched into a large empty image.
bool isTinySupermarketPlaceholder(String? reportedSize) {
  final match = RegExp(
    r'^\s*(\d+)\s*B\s*$',
    caseSensitive: false,
  ).firstMatch(reportedSize ?? '');
  if (match == null) return false;
  final bytes = int.tryParse(match.group(1)!);
  return bytes != null && bytes <= 128;
}
