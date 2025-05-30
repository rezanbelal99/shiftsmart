import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:shiftsmart/models/payslip.dart';
import 'package:shiftsmart/store/actions/payslip_actions.dart';
import 'package:shiftsmart/store/app_state.dart';

class PayslipReviewScreen extends StatefulWidget {
  final Map<String, String> payslipData;

  PayslipReviewScreen({required this.payslipData});

  @override
  _PayslipReviewScreenState createState() => _PayslipReviewScreenState();
}

class _PayslipReviewScreenState extends State<PayslipReviewScreen> {
  late final Map<String, TextEditingController> _controllers;
  bool _isSaving = false;

  static const Map<String, String> displayLabels = {
    'employer': 'Employer',
    'grossPay': 'Gross Pay',
    'netPay': 'Net Pay',
    'hoursWorked': 'Hours Worked',
    'paymentDate': 'Payment Date',
    'period': 'Period',
  };

  @override
  void initState() {
    super.initState();
    _controllers = {};

    final keyMapping = {
      'employer': 'employer',
      'pay_period': 'period',
      'gross_pay': 'grossPay',
      'net_pay': 'netPay',
      'total_hours': 'hoursWorked',
      'deductions': 'deductions',
      'payment_date': 'paymentDate'
    };

    widget.payslipData.forEach((key, value) {
      final normalizedKey = keyMapping[key] ?? key;
      _controllers[normalizedKey] = TextEditingController(text: value);
    });

    for (var expectedKey in keyMapping.values) {
      _controllers.putIfAbsent(expectedKey, () => TextEditingController());
    }
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _savePayslip() async {
    // Simple validation example: check required fields are not empty
    if (_controllers['employer']!.text.isEmpty ||
        _controllers['period']!.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all required fields.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final updatedPayslip = Payslip(
      employer: _controllers['employer']?.text ?? '',
      period: _controllers['period']?.text ?? '',
      hoursWorked: double.tryParse(_controllers['hoursWorked']?.text ?? '') ?? 0.0,
      grossPay: double.tryParse(_controllers['grossPay']?.text ?? '') ?? 0.0,
      netPay: double.tryParse(_controllers['netPay']?.text ?? '') ?? 0.0,
      paymentDate: _controllers['paymentDate']?.text ?? '',
    );

    final store = StoreProvider.of<AppState>(context);
    store.dispatch(AddPayslipAction(updatedPayslip));

    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payslip saved!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review Payslip'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ..._controllers.entries.map((entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: TextFormField(
                        controller: entry.value,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: displayLabels[entry.key] ?? entry.key,
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white54),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                    )),
                    SizedBox(height: 24),
                    Center(
                      child: _isSaving
                          ? CircularProgressIndicator(color: Colors.white)
                          : ElevatedButton.icon(
                              onPressed: _savePayslip,
                              icon: Icon(Icons.save),
                              label: Text('Confirm & Save'),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}