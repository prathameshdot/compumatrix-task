import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme.dart';

Future<DateTime?> showAppDateTimePicker(
  BuildContext context, {
  required DateTime initialDateTime,
  DateTime? minimumDate,
  CupertinoDatePickerMode mode = CupertinoDatePickerMode.dateAndTime,
}) async {
  var selected = initialDateTime;
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLg)),
    ),
    builder: (sheetContext) {
      final brightness = Theme.of(sheetContext).brightness;
      return SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(true),
                  child: const Text('Done'),
                ),
              ],
            ),
            SizedBox(
              height: 260,
              child: CupertinoTheme(
                data: CupertinoThemeData(brightness: brightness),
                child: CupertinoDatePicker(
                  mode: mode,
                  initialDateTime: initialDateTime,
                  minimumDate: minimumDate,
                  use24hFormat: false,
                  onDateTimeChanged: (value) => selected = value,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
  return confirmed == true ? selected : null;
}
