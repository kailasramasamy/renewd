import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';

class MinderDateUtils {
  MinderDateUtils._();

  static int daysRemaining(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    return target.difference(today).inDays;
  }

  static String formatDate(DateTime date) {
    return DateFormat('d MMM yyyy').format(date);
  }

  static String formatShort(DateTime date) {
    return DateFormat('d MMM').format(date);
  }

  static Color statusColorFromDays(int days) {
    if (days < 0) return MinderColors.coralRed;
    if (days <= 7) return MinderColors.coralRed;
    if (days <= 30) return MinderColors.tangerine;
    if (days <= 60) return MinderColors.amber;
    return MinderColors.emerald;
  }
}
