import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OTPInputPage extends StatefulWidget {
  const OTPInputPage({Key? key}) : super(key: key);

  @override
  _OTPInputPageState createState() => _OTPInputPageState();
}

class _OTPInputPageState extends State<OTPInputPage> {
  final TextEditingController _otpController = TextEditingController();
  String? _clipboardContent;
  bool _showPasteButton = false;

  @override
  void initState() {
    super.initState();
    _focusTextField();
    _initializeClipboard();
    _startClipboardListener();
  }

  void _focusTextField() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  Future<void> _initializeClipboard() async {
    await _checkClipboard();
  }

  Future<void> _checkClipboard() async {
    ClipboardData? clipboardData =
        await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null) {
      _updateClipboardContent(clipboardData.text);
    }
  }

  void _startClipboardListener() {
    // Check clipboard every second
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      await _checkClipboard();
      return true;
    });
  }

  void _updateClipboardContent(String? content) {
    if (content != _clipboardContent) {
      setState(() {
        _clipboardContent = content;
        _showPasteButton = _clipboardContent != null &&
            _clipboardContent!.length == 6 &&
            int.tryParse(_clipboardContent!) != null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OTP Input')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Enter OTP',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle OTP submission
                print('Submitted OTP: ${_otpController.text}');
              },
              child: const Text('Submit OTP'),
            ),
          ],
        ),
      ),
      floatingActionButton: _showPasteButton
    ? FloatingActionButton.extended(
        onPressed: () {
          _otpController.text = _clipboardContent!;
        },
        icon: const Icon(Icons.paste),
        label: Text(
          _clipboardContent!,
          style: const TextStyle(fontSize: 14),
        ),
        backgroundColor: Colors.blue,
      )
    : null,
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
}
