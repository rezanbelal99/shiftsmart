import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
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
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final textRecognizer = TextRecognizer();
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      setState(() {
        _recognizedText = recognizedText.text;
        _parsedFields = _parsePayslipData(recognizedText.text);
      });
    } catch (e) {
      setState(() {
        _recognizedText = 'Failed to recognize text: $e';
      });
    }
  }

  Map<String, String> _parsePayslipData(String text) {
    final Map<String, String> data = {};
    final lines = text.split('\n').map((l) => l.trim()).toList();

    final fields = {
      'Employer': RegExp(r'employer', caseSensitive: false),
      'Period': RegExp(r'pay period|period', caseSensitive: false),
      'Hours Worked': RegExp(r'hours worked', caseSensitive: false),
      'Gross Pay': RegExp(r'gross pay', caseSensitive: false),
      'Net Pay': RegExp(r'net pay', caseSensitive: false),
      'Payment Date': RegExp(r'payment date', caseSensitive: false),
    };

    for (var line in lines) {
      for (var entry in fields.entries) {
        if (entry.value.hasMatch(line) && !data.containsKey(entry.key)) {
          final extracted = _extractTextAfterLabel(line);
          final normalizedExtracted = extracted.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
          final normalizedKey = entry.key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

          // Only save if extracted text is meaningfully different from label
          if (!normalizedExtracted.contains(normalizedKey)) {
            data[entry.key] = extracted;
          }
        }
      }
    }
    return data;
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
              child: Column(
                children: [
                  if (_parsedFields.isNotEmpty)
                    Expanded(
                      child: ListView(
                        children: _parsedFields.keys.map((key) {
                          return GestureDetector(
                            onDoubleTap: () {
                              final controller = TextEditingController(text: _parsedFields[key]);
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("Edit $key"),
                                  content: TextField(
                                    controller: controller,
                                    autofocus: true,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("Cancel"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _parsedFields[key] = controller.text;
                                        });
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("Save"),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  Text(
                                    "$key: ",
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  Expanded(
                                    child: Text(
                                      _parsedFields[key] ?? '',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  if (_parsedFields.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final payslip = {
                            'employer': _parsedFields['Employer'] ?? '',
                            'period': _parsedFields['Period'] ?? '',
                            'hoursWorked': double.tryParse((_parsedFields['Hours Worked'] ?? '0').replaceAll(',', '.')) ?? 0,
                            'grossPay': double.tryParse((_parsedFields['Gross Pay'] ?? '0').replaceAll(RegExp(r'[^0-9.]'), '').replaceAll(',', '.')) ?? 0,
                            'netPay': double.tryParse((_parsedFields['Net Pay'] ?? '0').replaceAll(RegExp(r'[^0-9.]'), '').replaceAll(',', '.')) ?? 0,
                            'paymentDate': _parsedFields['Payment Date'] ?? '',
                          };
                          // TODO: Save logic
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Save Payslip'),
                      ),
                    ),
                  if (_parsedFields.isEmpty)
                    Center(
                      child: Text(
                        _recognizedText ?? 'No text recognized yet.',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
