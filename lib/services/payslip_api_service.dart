import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class PayslipApiService {
  Future<Map<String, dynamic>?> uploadPayslip() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);

      var uri = Uri.parse("http://192.168.10.118:5000/scan_payslip");
      var request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = json.decode(responseBody);
        return data;
      } else {
        final error = await response.stream.bytesToString();
        print("❌ Server error: ${response.statusCode} - $error");
        return null;
      }
    } else {
      print("⚠️ No file selected.");
      return null;
    }
  }
}