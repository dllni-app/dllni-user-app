import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class SpeechPage extends StatefulWidget {
  const SpeechPage({super.key});

  @override
  State<SpeechPage> createState() => _SpeechPageState();
}

class _SpeechPageState extends State<SpeechPage> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = 'اضغط على الزر وابدأ التحدث';
  double _confidence = 1.0;
  String _lastResult = '';
  final TextEditingController _fileNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    if (!await Permission.microphone.request().isGranted) {
      setState(() {
        _text = 'تم رفض إذن الميكروفون.';
      });
    }
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (val) => _handleStatus(val),
      onError: (val) => print('onError: $val'),
    );

    if (available) {
      setState(() {
        _isListening = true;
        _text = _text == 'اضغط على الزر وابدأ التحدث' ? '' : _text;
        _lastResult = '';
      });

      _speech.listen(
        localeId: 'ar',
        listenMode: stt.ListenMode.dictation,
        onResult: (val) {
          if (val.recognizedWords != _lastResult) {
            setState(() {
              // Only append new text (prevent repeated interim results)
              String newWords = val.recognizedWords
                  .replaceFirst(_lastResult, '')
                  .trim();

              if (newWords.isNotEmpty) {
                // Replace "انزل سطر" with a newline
                newWords = newWords.replaceAll('انزل سطر', '\n');
                _text += ' $newWords';
              }

              _lastResult = val.recognizedWords;

              if (val.hasConfidenceRating && val.confidence > 0) {
                _confidence = val.confidence;
              }
            });
          }
        },
      );
    } else {
      setState(() => _text = 'خدمة التعرف على الكلام غير متاحة حالياً.');
    }
  }

  void _handleStatus(String status) {
    if (status == 'done' && _isListening) {
      // Restart listening automatically if still active
      Future.delayed(const Duration(milliseconds: 400), () {
        if (_isListening) _startListening();
      });
    }
  }

  void _cancelListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  Future<void> _saveTextToFile() async {
    if (_text.isEmpty || _text == 'اضغط على الزر وابدأ التحدث') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('الرجاء التحدث أولاً.')));
      return;
    }

    String fileName = _fileNameController.text.trim();
    if (fileName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('الرجاء إدخال اسم الملف.')));
      return;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName.txt');
      await file.writeAsString(_text);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تم الحفظ في ${file.path}')));

      setState(() {
        _text = 'اضغط على الزر وابدأ التحدث';
        _fileNameController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في حفظ الملف: $e')));
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _fileNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الكلام إلى ملف'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () => Navigator.pushNamed(context, '/files'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        reverse: true,
        padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
        child: Column(
          children: <Widget>[
            Text(
              _text,
              style: const TextStyle(
                fontSize: 28.0,
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _fileNameController,
              decoration: const InputDecoration(
                labelText: 'اسم الملف (مثال: ملاحظاتي)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _saveTextToFile,
              icon: const Icon(Icons.save),
              label: const Text('حفظ في ملف'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton.extended(
            heroTag: 'startBtn',
            onPressed: _isListening ? null : _startListening,
            label: const Text('ابدأ'),
            icon: const Icon(Icons.mic),
            backgroundColor: _isListening ? Colors.grey : Colors.blue,
          ),
          const SizedBox(width: 20),
          FloatingActionButton.extended(
            heroTag: 'cancelBtn',
            onPressed: _isListening ? _cancelListening : null,
            label: const Text('إلغاء'),
            icon: const Icon(Icons.stop),
            backgroundColor: _isListening ? Colors.red : Colors.grey,
          ),
        ],
      ),
    );
  }
}
