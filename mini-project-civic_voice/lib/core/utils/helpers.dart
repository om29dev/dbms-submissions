// Core utility exports for Civic Voice Interface.
// Add utility functions and helpers here.

/// Formats a [DateTime] to a human-readable "time ago" string.
String timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inSeconds < 60)  return 'Just now';
  if (diff.inMinutes < 60)  return '${diff.inMinutes}m ago';
  if (diff.inHours < 24)    return '${diff.inHours}h ago';
  if (diff.inDays < 7)      return '${diff.inDays}d ago';
  return '${date.day}/${date.month}/${date.year}';
}

/// Returns initials from a full name (max 2 chars).
String getInitials(String name) {
  final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty)  return '?';
  if (parts.length == 1) return parts[0][0].toUpperCase();
  return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
}

/// Masks an Aadhaar number showing only last 4 digits.
String maskAadhaar(String aadhaar) {
  if (aadhaar.length < 4) return aadhaar;
  return 'XXXX-XXXX-${aadhaar.substring(aadhaar.length - 4)}';
}

/// Validates an email address format.
bool isValidEmail(String email) {
  return RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}

/// Validates an Indian phone number (10 digits, optionally with +91).
bool isValidIndianPhone(String phone) {
  return RegExp(r'^(\+91)?[6-9]\d{9}$').hasMatch(phone.replaceAll(' ', ''));
}
