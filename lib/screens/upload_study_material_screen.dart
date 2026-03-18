import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../services/data_service.dart';
import '../widgets/app_back_button.dart';

class UploadStudyMaterialScreen extends StatefulWidget {
  const UploadStudyMaterialScreen({super.key});

  @override
  State<UploadStudyMaterialScreen> createState() =>
      _UploadStudyMaterialScreenState();
}

class _UploadStudyMaterialScreenState extends State<UploadStudyMaterialScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _resourceType = 'PDF';
  String _pickedPdfName = '';
  Uint8List? _pickedPdfBytes;

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    _linkController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickPdfFromComputer() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      setState(() {
        _pickedPdfName = file.name;
        _pickedPdfBytes = file.bytes;
      });
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected PDF: ${file.name}')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not pick PDF file.')),
      );
    }
  }

  void _uploadMaterial() {
    final title = _titleController.text.trim();
    final subject = _subjectController.text.trim();
    final link = _linkController.text.trim();
    final description = _descriptionController.text.trim();

    final needsUrl = _resourceType != 'PDF';

    if (title.isEmpty || subject.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields.')),
      );
      return;
    }

    if (needsUrl && link.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add the resource URL link.')),
      );
      return;
    }

    if (!needsUrl && _pickedPdfName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a PDF from computer.')),
      );
      return;
    }

    DataService.addStudyMaterial({
      'title': title,
      'subject': subject,
      'resourceType': _resourceType,
      'link': link,
      'description': description,
      'pdfName': _pickedPdfName,
      'pdfBytes': _pickedPdfBytes,
    });

    _titleController.clear();
    _subjectController.clear();
    _linkController.clear();
    _descriptionController.clear();

    setState(() {
      _resourceType = 'PDF';
      _pickedPdfName = '';
      _pickedPdfBytes = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Study material uploaded successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showPdfUpload = _resourceType == 'PDF';

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Upload Study Material'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Upload Study Material',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _subjectController,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _resourceType,
                    decoration: const InputDecoration(
                      labelText: 'Resource Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'PDF', child: Text('PDF')),
                      DropdownMenuItem(value: 'Blog', child: Text('Blog')),
                      DropdownMenuItem(value: 'Video', child: Text('Video')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _resourceType = value;
                        _pickedPdfName = '';
                        _pickedPdfBytes = null;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  if (showPdfUpload) ...[
                    ElevatedButton(
                      onPressed: _pickPdfFromComputer,
                      child: const Text('Choose PDF From Computer'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _pickedPdfName.isEmpty
                          ? 'No PDF selected'
                          : _pickedPdfName,
                    ),
                  ] else
                    TextField(
                      controller: _linkController,
                      decoration: const InputDecoration(
                        labelText: 'File or URL Link',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Short Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: _uploadMaterial,
                    child: const Text('Upload'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
