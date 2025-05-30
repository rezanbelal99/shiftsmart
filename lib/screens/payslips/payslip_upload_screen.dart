import 'package:flutter/material.dart';
import '../../services/payslip_api_service.dart';
import 'payslip_review_screen.dart';

class PayslipUploadScreen extends StatelessWidget {
  final PayslipApiService apiService = PayslipApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Payslip')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            var result = await apiService.uploadPayslip();
            if (result != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PayslipReviewScreen(payslipData: Map<String, String>.from(result['fields'])),
                ),
              );
            }
          },
          child: Text('Select and Scan Payslip'),
        ),
      ),
    );
  }
}