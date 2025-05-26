import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:shiftsmart/models/payslip.dart';
import 'package:shiftsmart/store/actions/payslip_actions.dart';
import 'package:shiftsmart/store/app_state.dart';

class PayslipReviewScreen extends StatefulWidget {
  final Map<String, dynamic> payslipData;

  const PayslipReviewScreen({Key? key, required this.payslipData}) : super(key: key);

  @override
  _PayslipReviewScreenState createState() => _PayslipReviewScreenState();
}

class _PayslipReviewScreenState extends State<PayslipReviewScreen> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    widget.payslipData.forEach((key, value) {
      _controllers[key] = TextEditingController(text: value.toString());
    });
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _savePayslip() {
    final updatedPayslip = Payslip(
      employer: _controllers['Employer']?.text ?? '',
      period: _controllers['Period']?.text ?? '',
      hoursWorked: double.tryParse(_controllers['Hours Worked']?.text ?? '') ?? 0.0,
      grossPay: double.tryParse(_controllers['Gross Pay']?.text ?? '') ?? 0.0,
      netPay: double.tryParse(_controllers['Net Pay']?.text ?? '') ?? 0.0,
      paymentDate: _controllers['Payment Date']?.text ?? '',
    );

    final store = StoreProvider.of<AppState>(context);
    store.dispatch(AddPayslipAction(updatedPayslip));

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ..._controllers.entries.map((entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: TextFormField(
                  controller: entry.value,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: entry.key,
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
                child: ElevatedButton.icon(
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
  }
}