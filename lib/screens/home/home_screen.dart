// External libraries
import 'package:flutter_redux/flutter_redux.dart'; // Access Redux store from UI
import 'package:flutter/material.dart'; // Core Flutter UI components
import 'package:device_calendar/device_calendar.dart'; // Plugin to access native calendar
import 'package:intl/intl.dart'; // For date formatting

// Internal project files
import '../../utils/calendar_service.dart'; // Service for fetching calendar shifts
import '../../models/shift.dart'; // Data model for a work shift
import '../../store/app_state.dart'; // Global app state class
import '../../store/actions/shift_actions.dart'; // Redux action for storing shifts
import '../shifts/shift_list_screen.dart'; // Screen to view all shifts

/// Fetches work-related shifts from the calendar and dispatches them to the Redux store.
/// Then shows a snackbar with the number of found shifts.
void _fetchCalendarShifts(BuildContext context) async {
  final service = CalendarService();
  final shifts = await service.fetchShiftsFromCalendar();

  // Store shifts in Redux
  StoreProvider.of<AppState>(context).dispatch(SetShiftsAction(shifts));

  // Show result to user
  final snackBar = SnackBar(content: Text('Found ${shifts.length} work shifts.'));
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar with title
      appBar: AppBar(title: Text('ShiftSmart Home')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome message
                Text(
                  'Welcome to ShiftSmart!',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),

                // Button to check if calendar permission is granted
                ElevatedButton(
                  onPressed: () async {
                    final plugin = DeviceCalendarPlugin();
                    final result = await plugin.hasPermissions();
                    final granted = result.data ?? false;
                    final msg = granted ? '✅ Permission granted' : '❌ Still denied';
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                  },
                  child: Text('Check Calendar Permission'),
                ),
                SizedBox(height: 20),

                // Button to fetch shifts from the user's calendar
                ElevatedButton(
                  onPressed: () => _fetchCalendarShifts(context),
                  child: Text('Fetch Calendar Shifts'),
                ),

                SizedBox(height: 20),

                // Button to view all shifts
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ShiftListScreen()),
                    );
                  },
                  child: Text('View All Shifts'),
                ),

                SizedBox(height: 20),

                // Section header for imported shifts
                Text('Imported Shifts', style: TextStyle(fontWeight: FontWeight.bold)),

                // Listen to Redux store for list of shifts and display them
                StoreConnector<AppState, List<Shift>>(
                  converter: (store) => store.state.shifts,
                  builder: (context, shifts) {
                    if (shifts.isEmpty) {
                      return Text('No shifts imported yet.');
                    }

                    // Render each shift inside a styled container
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: shifts.map((shift) {
                        final formatter = DateFormat('dd-MM-yyyy HH:mm');
                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[900],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                shift.title,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${formatter.format(shift.start)} → ${formatter.format(shift.end)}',
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Duration: ${shift.hours.toStringAsFixed(1)} h',
                                style: TextStyle(color: Colors.grey[300]),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}