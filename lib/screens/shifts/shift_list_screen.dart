import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart'; // For compact date formatting
import '../../models/shift.dart';
import '../../store/app_state.dart';
import '../../store/actions/shift_actions.dart'; // Redux action to add new shift

class ShiftListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Your Shifts'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StoreConnector<AppState, List<Shift>>(
            converter: (store) => store.state.shifts,
            builder: (context, shifts) {
              if (shifts.isEmpty) {
                return Center(child: Text('No shifts added yet.'));
              }

              // Compute total monthly earnings
              final now = DateTime.now();
              final currentMonthShifts = shifts.where((s) =>
                s.start.year == now.year && s.start.month == now.month);
              final totalEarnings = currentMonthShifts.fold(0.0, (sum, s) => sum + s.earnings);

              return ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
                child: ListView.separated(
                  itemCount: shifts.length + 1,
                  separatorBuilder: (context, index) =>
                      index == 0 ? SizedBox.shrink() : SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Total this month: ${totalEarnings.toStringAsFixed(2)} kr',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }
                    final shift = shifts[index - 1];
                    return SizedBox(
                      width: double.infinity,
                      child: Dismissible(
                        key: ValueKey(shift.id),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        secondaryBackground: Container(
                          color: Colors.blue,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Icon(Icons.edit, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            // Delete
                            final store = StoreProvider.of<AppState>(context);
                            final updatedShifts = List<Shift>.from(store.state.shifts)..remove(shift);
                            store.dispatch(SetShiftsAction(updatedShifts));
                            return true;
                          } else if (direction == DismissDirection.endToStart) {
                            // Edit
                            final editedShift = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ManualShiftEntryScreen(existingShift: shift),
                              ),
                            );
                            if (editedShift != null && editedShift is Shift) {
                              final store = StoreProvider.of<AppState>(context);
                              final updatedShifts = List<Shift>.from(store.state.shifts)
                                ..removeWhere((s) => s.id == shift.id)
                                ..add(editedShift);
                              store.dispatch(SetShiftsAction(updatedShifts));
                            }
                            return false;
                          }
                          return false;
                        },
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                shift.title,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text('${DateFormat('dd-MM-yyyy HH:mm').format(shift.start)} → ${DateFormat('dd-MM-yyyy HH:mm').format(shift.end)}'),
                              Text('Duration: ${shift.hours.toStringAsFixed(1)} h'),
                              Text('Earnings: ${shift.earnings.toStringAsFixed(2)} kr'),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newShift = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ManualShiftEntryScreen()),
          );
          if (newShift != null && newShift is Shift) {
            final store = StoreProvider.of<AppState>(context);
            final currentShifts = store.state.shifts;
            store.dispatch(SetShiftsAction([...currentShifts, newShift]));
          }
        },
        child: Icon(Icons.add),
        tooltip: 'Add Shift',
      ),
    );
  }
}

class ManualShiftEntryScreen extends StatefulWidget {
  final Shift? existingShift;

  ManualShiftEntryScreen({this.existingShift});

  @override
  _ManualShiftEntryScreenState createState() => _ManualShiftEntryScreenState();
}

class _ManualShiftEntryScreenState extends State<ManualShiftEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  DateTime? _startTime;
  DateTime? _endTime;
  double? _hourlyRate;

  @override
  void initState() {
    super.initState();
    if (widget.existingShift != null) {
      _titleController.text = widget.existingShift!.title;
      _startTime = widget.existingShift!.start;
      _endTime = widget.existingShift!.end;
      _hourlyRate = widget.existingShift!.hourlyRate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Shift'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Shift Title'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter a title' : null,
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text(_startTime == null
                    ? 'Select Start Time'
                    : 'Start: ${DateFormat('dd-MM-yyyy HH:mm').format(_startTime!)}'),
                trailing: Icon(Icons.access_time),
                onTap: () async {
                  final picked = await showDateTimePicker(context);
                  if (picked != null) setState(() => _startTime = picked);
                },
              ),
              ListTile(
                title: Text(_endTime == null
                    ? 'Select End Time'
                    : 'End: ${DateFormat('dd-MM-yyyy HH:mm').format(_endTime!)}'),
                trailing: Icon(Icons.access_time),
                onTap: () async {
                  final picked = await showDateTimePicker(context);
                  if (picked != null) setState(() => _endTime = picked);
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Hourly Rate (kr)'),
                keyboardType: TextInputType.number,
                initialValue: _hourlyRate != null ? _hourlyRate.toString() : null,
                onChanged: (value) {
                  setState(() {
                    _hourlyRate = double.tryParse(value);
                  });
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() &&
                      _startTime != null &&
                      _endTime != null &&
                      _startTime!.isBefore(_endTime!)) {
                    final shift = Shift(
                      id: widget.existingShift?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                      title: _titleController.text,
                      start: _startTime!,
                      end: _endTime!,
                      hourlyRate: _hourlyRate,
                    );
                    Navigator.pop(context, shift);
                  }
                },
                child: Text('Save Shift'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<DateTime?> showDateTimePicker(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (date == null) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
}
