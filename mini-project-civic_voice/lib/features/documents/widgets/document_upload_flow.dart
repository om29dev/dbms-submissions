import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:confetti/confetti.dart';
import '../../../core/constants/app_colors.dart';

class DocumentUploadFlow extends StatefulWidget {
  const DocumentUploadFlow({super.key});

  @override
  State<DocumentUploadFlow> createState() => _DocumentUploadFlowState();
}

class _DocumentUploadFlowState extends State<DocumentUploadFlow> {
  late ConfettiController _confettiController;
  bool _isUploading = false;
  double _progress = 0.0;
  bool _success = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _startUpload() {
    setState(() {
      _isUploading = true;
      _progress = 0.0;
    });

    // Simulate upload
    Future.forEach(List.generate(10, (index) => index), (index) async {
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        _progress = (index + 1) / 10;
      });
    }).then((_) {
      setState(() {
        _isUploading = false;
        _success = true;
      });
      _confettiController.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            children: [
              const Text(
                'Upload Aadhaar Card',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              if (!_isUploading && !_success)
                _buildUploadButton()
              else if (_isUploading)
                _buildProgressIndicator()
              else
                _buildSuccessState(),
            ],
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            colors: const [Colors.green, Color(0xFFD4930A), Colors.pink, Colors.orange, Colors.purple],
          ),
        ),
      ],
    );
  }

  Widget _buildUploadButton() {
    return FadeIn(
      child: GestureDetector(
        onTap: _startUpload,
        child: Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.secondary, style: BorderStyle.none),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_upload_outlined, size: 50, color: AppColors.secondary),
              SizedBox(height: 10),
              Text('Tap to upload or drag & drop'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        const SizedBox(height: 40),
        CircularProgressIndicator(
          value: _progress,
          strokeWidth: 8,
          color: AppColors.secondary,
        ),
        const SizedBox(height: 20),
        Text('Uploading... ${(_progress * 100).toInt()}%'),
      ],
    );
  }

  Widget _buildSuccessState() {
    return FadeInDown(
      child: const Column(
        children: [
          Icon(Icons.check_circle, color: AppColors.accent, size: 80),
          SizedBox(height: 20),
          Text(
            'Upload Successful!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
            ),
          ),
          Text('Verification in progress'),
        ],
      ),
    );
  }
}
