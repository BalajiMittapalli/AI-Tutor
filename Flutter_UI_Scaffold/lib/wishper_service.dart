import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:wav/wav.dart';
import 'dart:typed_data';

class WhisperService {
  final String _tfliteModelName = "whisper.tflite"; // Change to your model name
  Interpreter? _interpreter;
  final AudioRecorder _audioRecorder = AudioRecorder();
  String? _audioPath;

  Future<void> loadModel() async {
    try {
      final modelPath = await _getModelPath();
      _interpreter = await Interpreter.fromFile(File(modelPath));
      print('Whisper TFLite model loaded.');
    } catch (e) {
      print("Error loading Whisper model: $e");
      rethrow;
    }
  }

  Future<String> _getModelPath() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final modelPath = '${appDocDir.path}/$_tfliteModelName';

    if (!await File(modelPath).exists()) {
      print('Whisper model not found, copying from assets...');
      final byteData = await rootBundle.load('assets/$_tfliteModelName');
      final buffer = byteData.buffer;
      await File(modelPath).writeAsBytes(
          buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
      print('Whisper model copied to $modelPath');
    }
    return modelPath;
  }

  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      final appDocDir = await getApplicationDocumentsDirectory();
      _audioPath = '${appDocDir.path}/recording.wav';
      await _audioRecorder.start(const RecordConfig(encoder: AudioEncoder.wav), path: _audioPath!);
      print("Recording started...");
    } else {
      throw Exception("Microphone permission not granted");
    }
  }

  Future<String?> stopRecording() async {
    final path = await _audioRecorder.stop();
    print("Recording stopped, file saved at: $path");
    return path;
  }

  Future<String> transcribe() async {
    if (_interpreter == null) throw Exception("Whisper model not loaded.");
    if (_audioPath == null || !await File(_audioPath!).exists()) {
      throw Exception("Audio file not found at $_audioPath");
    }

    print("Starting transcription for: $_audioPath");

    try {
      // 1. Read the audio file
      final wav = await Wav.readFile(_audioPath!);

      // 2. Get audio samples as Float32List
      // The Whisper model expects 16kHz mono audio.
      // The `record` package should already be configured for this.
      // The model expects a 30-second audio input, which is 16000 * 30 = 480000 samples.
      final audioSamples = wav.toMono();

      // 3. Pad or truncate the audio to the required length
      const requiredSamples = 480000;
      Float32List processedSamples = Float32List(requiredSamples);

      if (audioSamples.length > requiredSamples) {
        // Truncate
        processedSamples.setRange(0, requiredSamples, audioSamples);
      } else {
        // Pad with zeros
        processedSamples.setRange(0, audioSamples.length, audioSamples);
      }

      // 4. Run inference
      // The input tensor shape for Whisper is typically [1, 480000]
      final input = processedSamples.reshape([1, requiredSamples]);

      final outputShape = _interpreter!.getOutputTensor(0).shape; // e.g., [1, 224]
      final output = List.filled(outputShape[0] * outputShape[1], 0).reshape(outputShape);

      Map<int, Object> outputs = {0: output};

      _interpreter!.runForMultipleInputs([input], outputs);

      // 5. Decode the output tokens to text (This is a complex step)
      
      print("Inference successful. Output tensor: ${output.toString()}");

      return "Inference complete. Decoding not yet implemented.";

    } catch (e) {
      print("Error during transcription: $e");
      rethrow;
    }
  }

  void dispose() {
    _interpreter?.close();
    _audioRecorder.dispose();
  }
}
