import 'dart:io';
import 'package:ai_tut/chat_screen.dart';
import 'package:ai_tut/gguf_downloader.dart';
import 'package:ai_tut/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

Future<File> getModelFile(String modelName) async {
  final dir = await getApplicationDocumentsDirectory();
  final filePath = '${dir.path}/$modelName';
  return File(filePath);
}

class SplashScreen extends ConsumerStatefulWidget {
  final String modelName;
  final String modelUrl;

  const SplashScreen({
    super.key,
    required this.modelName,
    required this.modelUrl,
  });

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  double _progressValue = 0.0;
  String _statusMessage = "Checking for AI model...";
  bool _hasError = false;
  String _errorMessage = "";
  bool _isDownloading = false;
  bool _modelExists = false;

  // For animation
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _checkModel();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkModel() async {
    try {
      // Check if model exists
      final modelFile = await getModelFile(widget.modelName);
      final exists = await modelFile.exists();

      setState(() {
        _modelExists = exists;
        _statusMessage = exists
            ? "AI model found! Preparing to launch..."
            : "AI model not found. Download required.";
      });

      if (exists) {
        // Small delay for user to see the success message
        await Future.delayed(const Duration(seconds: 1));
        _navigateToChatScreen(modelFile);
      }

    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = "Error checking for model: $e";
      });
    }
  }

  Future<void> _downloadModel() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
      _hasError = false;
      _progressValue = 0.0;
      _statusMessage = "Starting download...";
    });

    try {
      final File modelFile = await downloadGGUFModel(
        modelName: widget.modelName,
        url: widget.modelUrl,
        onProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            setState(() {
              _progressValue = progress;
              _statusMessage = "Downloading AI model: ${(progress * 100).toStringAsFixed(0)}%";
            });
          }
        },
      );

      // Small delay to show 100% progress
      await Future.delayed(const Duration(milliseconds: 300));

      setState(() {
        _isDownloading = false;
        _statusMessage = "Download complete! Launching app...";
      });

      _navigateToChatScreen(modelFile);
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  void _navigateToChatScreen(File modelFile) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ChatScreen(modelPath: modelFile.path),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryTeal.withOpacity(0.8),
              primaryTeal,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeInAnimation,
            child: Center(
              child: _modelExists
                ? _buildModelFoundState(theme)
                : (_hasError
                    ? _buildErrorState(theme)
                    : _buildDownloadState(theme)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModelFoundState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Colors.white,
          ),
          const SizedBox(height: 24),
          Text(
            "AI Tutor",
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Model found and ready to use!",
            style: GoogleFonts.inter(
              fontSize: 18,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _statusMessage,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 32),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_rounded,
            size: 80,
            color: Colors.white,
          ),
          const SizedBox(height: 24),
          Text(
            "Offline AI Tutor",
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Your personal learning assistant",
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 48),

          // Only show progress when downloading
          if (_isDownloading) ...[
            LinearProgressIndicator(
              value: _progressValue,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(accentLime),
              borderRadius: BorderRadius.circular(8),
              minHeight: 10,
            ),
            const SizedBox(height: 16),
            Text(
              _statusMessage,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Show download button when not downloading
          if (!_isDownloading)
            ElevatedButton.icon(
              onPressed: _downloadModel,
              icon: const Icon(Icons.download_rounded),
              label: const Text("Download AI Model"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: primaryTeal,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Note text
          Text(
            _isDownloading
                ? "The app will start automatically when the model is ready"
                : "This model enables offline AI tutoring without internet",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),

          // Spacer for bottom version info
          const Spacer(),

          // Version info
          Text(
            "v1.0.0",
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: Colors.white.withOpacity(0.9),
          ),
          const SizedBox(height: 24),

          Text(
            "Download Failed",
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          Card(
            color: Colors.white.withOpacity(0.1),
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _errorMessage,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 32),

          ElevatedButton.icon(
            onPressed: _downloadModel,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text("Try Again"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: primaryTeal,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),

          TextButton(
            onPressed: () {
              // Reset the error state and go back to the initial state
              setState(() {
                _hasError = false;
                _progressValue = 0.0;
                _statusMessage = "AI model required for offline tutoring";
              });
            },
            child: Text(
              "Cancel",
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
