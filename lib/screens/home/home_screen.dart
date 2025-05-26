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
import 'package:shiftsmart/screens/payslips/payslip_review_screen.dart';
import 'package:shiftsmart/screens/payslips/payslip_list_screen.dart';


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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 100), // prevent overlap with button bar
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
                    // Section header for imported shifts
                    Text('Imported Shifts', style: TextStyle(fontWeight: FontWeight.bold)),

                    // Listen to Redux store for list of shifts and display them
                    StoreConnector<AppState, List<Shift>>(
                      converter: (store) => store.state.shifts,
                      builder: (context, shifts) {
                        if (shifts.isEmpty) {
                          return Text('No shifts imported yet.');
                        }

                        final now = DateTime.now();
                        final currentMonthShifts = shifts.where((s) =>
                          s.start.year == now.year && s.start.month == now.month);
                        final totalEarnings = currentMonthShifts.fold(0.0, (sum, s) => sum + s.earnings);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Text(
                                'Total this month: ${totalEarnings.toStringAsFixed(2)} kr',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            ...shifts.map((shift) => _buildShiftTile(shift)),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.grey[900],
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: Icon(Icons.calendar_month, color: Colors.white),
                      tooltip: 'Fetch Calendar Shifts',
                      onPressed: () => _fetchCalendarShifts(context),
                    ),
                    Tooltip(
                      message: 'Scan Payslip',
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(18),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: () async {
                          final result = await Navigator.pushNamed(context, '/scanPayslip');
                          if (result != null && result is Map<String, dynamic>) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PayslipReviewScreen(payslipData: result),
                              ),
                            );
                          }
                        },
                        child: Image.asset('assets/icon/scan_icon.png', height: 32),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.view_list, color: Colors.white),
                      tooltip: 'View All Shifts',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ShiftListScreen()),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.receipt_long, color: Colors.white),
                      tooltip: 'View Payslips',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PayslipListScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftTile(Shift shift) {
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
          Text(
            'Earnings: ${shift.earnings.toStringAsFixed(2)} kr',
            style: TextStyle(color: Colors.grey[300]),
          ),
        ],
      ),
    );
  }
}