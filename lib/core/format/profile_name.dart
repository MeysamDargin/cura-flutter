const defaultProfileName = 'Explorer';
const defaultProfileInitial = 'U';

String displayFirstName(String? fullName) {
  final trimmed = fullName?.trim() ?? '';
  if (trimmed.isEmpty) return defaultProfileName;
  return trimmed.split(RegExp(r'\s+')).first;
}

String displayInitial(String? fullName) {
  final trimmed = fullName?.trim() ?? '';
  if (trimmed.isEmpty) return defaultProfileInitial;
  return trimmed.substring(0, 1).toUpperCase();
}
