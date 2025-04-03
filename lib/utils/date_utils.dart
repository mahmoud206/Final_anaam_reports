import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<DateTimeRange?> showDateRangePickerDialog(BuildContext context) async {
  final DateTimeRange? picked = await showDateRangePicker(
    context: context,
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
    initialDateRange: DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 30)),
      end: DateTime.now(),
    ),
  );
  return picked;
}

String formatDateRange(DateTimeRange range) {
  return '${DateFormat('yyyy-MM-dd').format(range.start)} to ${DateFormat('yyyy-MM-dd').format(range.end)}';
}