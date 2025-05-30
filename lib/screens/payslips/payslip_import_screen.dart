import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path/path.dart';
import 'package:shiftsmart/models/payslip.dart';
import 'package:shiftsmart/store/actions/payslip_actions.dart';
import 'package:shiftsmart/store/app_state.dart';
import 'package:shiftsmart/store/store.dart';
import 'package:redux/redux.dart';
import 'package:shiftsmart/screens/home/home_screen.dart';

class PayslipImportScreen extends StatefulWidget {
  const PayslipImportScreen({Key? key}) : super(key: key);
  
  @override
  _PayslipImportScreenState createState() => _PayslipImportScreenState();
}

class _PayslipImportScreenState extends State<PayslipImportScreen> {
  File? _imageFile;
  String? _recognizedText;
  Map<String, String> _parsedFields = {};

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setState(() => _imageFile = file);
      await _performOCR(file);
    }
  }

  Future<void> _performOCR(File imageFile) async {
    final uri = Uri.parse("http://192.168.10.118:5000/scan_payslip"); // Replace with your Mac's IP if testing on device
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path, filename: basename(imageFile.path)));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final body = await response.stream.bytesToString();
        final data = json.decode(body);

        setState(() {
          _recognizedText = null;
          _parsedFields = Map<String, String>.from(data['fields']);
        });
      } else {
        final errorBody = await response.stream.bytesToString();
        setState(() {
          _recognizedText = "Server error: ${response.statusCode} - $errorBody";
          _parsedFields = {};
        });
      }
    } catch (e) {
      setState(() {
        _recognizedText = "Error connecting to server: $e";
        _parsedFields = {};
      });
    }
  }

  String _extractTextAfterColon(String line) {
    if (line.contains(':')) {
      return line.split(':').last.trim();
    } else {
      // Handle cases like "Net Pay   12,250 kr" or "Gross Pay    17,500"
      final parts = line.split(RegExp(r'\s{2,}|\t')); // split on 2+ spaces or tab
      if (parts.length >= 2) {
        return parts.last.trim();
      }
    }
    return line.trim();
  }

  String _extractTextAfterLabel(String line) {
    // Try colon split
    if (line.contains(':')) {
      return line.split(':').last.trim();
    }

    // Try splitting on multiple spaces or tabs
    final parts = line.split(RegExp(r'\s{2,}|\t'));
    if (parts.length >= 2) {
      return parts.last.trim();
    }

    return line.trim();
  }

  String _extractNumber(String line) {
    final match = RegExp(r'[\d\s,.]+').firstMatch(line);
    return match?.group(0)?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Payslip'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Photo'),
            ),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload from Gallery'),
            ),
            const SizedBox(height: 20),
            if (_imageFile != null) ...[
              Image.file(_imageFile!, height: 200),
              const SizedBox(height: 20),
            ],
            Expanded(
              child: _parsedFields.isNotEmpty
                  ? Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: _parsedFields.length,
                            itemBuilder: (context, index) {
                              final key = _parsedFields.keys.elementAt(index);
                              final value = _parsedFields[key] ?? '';
                              return ListTile(
                                title: Text(
                                  "$key:",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                subtitle: TextFormField(
                                  initialValue: value,
                                  style: TextStyle(color: Colors.white),
                                  onChanged: (val) {
                                    _parsedFields[key] = val;
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Enter $key',
                                    hintStyle: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            final payslip = {
                              'employer': _parsedFields['Employer'] ?? '',
                              'period': _parsedFields['Period'] ?? '',
                              'hoursWorked': double.tryParse((_parsedFields['Hours Worked'] ?? '0').replaceAll(',', '.')) ?? 0,
                              'grossPay': double.tryParse((_parsedFields['Gross Pay'] ?? '0').replaceAll(RegExp(r'[^0-9.]'), '').replaceAll(',', '.')) ?? 0,
                              'netPay': double.tryParse((_parsedFields['Net Pay'] ?? '0').replaceAll(RegExp(r'[^0-9.]'), '').replaceAll(',', '.')) ?? 0,
                              'paymentDate': _parsedFields['Payment Date'] ?? '',
                            };
                            // TODO: Save to store
                            Navigator.pop(context, payslip);
                          },
                          icon: Icon(Icons.save),
                          label: Text('Save Payslip'),
                        ),
                      ],
                    )
                  : Center(
                      child: Text(
                        _recognizedText ?? 'No text recognized yet.',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
