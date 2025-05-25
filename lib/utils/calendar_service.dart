import 'package:device_calendar/device_calendar.dart';
import '../models/shift.dart';

class CalendarService {
  final DeviceCalendarPlugin _calendarPlugin = DeviceCalendarPlugin();

  Future<List<Shift>> fetchShiftsFromCalendar() async {
  print('[CalendarService] Checking permission...');
  var permissionsGranted = await _calendarPlugin.hasPermissions();
  if (!(permissionsGranted.data ?? false)) {
    final result = await _calendarPlugin.requestPermissions();
    if (!(result.data ?? false)) {
      print('[CalendarService] Permission still denied');
      return [];
    }
  }

  print('[CalendarService] Permission granted, retrieving calendars...');
  final calendarsResult = await _calendarPlugin.retrieveCalendars();
  final calendars = calendarsResult.data ?? [];

  print('[CalendarService] Found ${calendars.length} calendars');

  List<Shift> shifts = [];
  final workKeywords = ['work', 'shift', 'job'];

  for (final calendar in calendars) {
    print('--- Calendar: ${calendar.name} (${calendar.id})');

    final eventsResult = await _calendarPlugin.retrieveEvents(
      calendar.id!,
      RetrieveEventsParams(
        startDate: DateTime.now().subtract(Duration(days: 30)),
        endDate: DateTime.now().add(Duration(days: 30)),
      ),
    );

    final events = eventsResult.data ?? [];
    print('  Events found: ${events.length}');

    for (final event in events) {
      print('    Event title: ${event.title}, start: ${event.start}');
      final title = event.title?.toLowerCase() ?? '';
      if (workKeywords.any((keyword) => title.contains(keyword))) {
        shifts.add(
          Shift(
            id: event.eventId ?? '',
            title: event.title ?? '',
            start: event.start!,
            end: event.end!,
          ),
        );
      }
    }
  }
  

  print('[CalendarService] Total valid shifts: ${shifts.length}');
  return shifts;
}
}
