String formatChatTimestamp(DateTime? dateTime, {DateTime? now}) {
  if (dateTime == null) return '';

  final local = dateTime.toLocal();
  final clock = (now ?? DateTime.now()).toLocal();
  final isToday =
      clock.year == local.year &&
      clock.month == local.month &&
      clock.day == local.day;

  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  if (isToday) return '$hour:$minute';

  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  return '$day/$month';
}
