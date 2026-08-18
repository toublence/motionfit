import 'dart:async';

import 'package:flutter/material.dart';
import 'package:motionfit_pose/motionfit_pose.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _pose = MotionfitPose();
  StreamSubscription<MotionfitPoseFrame>? _subscription;
  int? _textureId;
  String _status = 'Idle';

  Future<void> _start() async {
    try {
      final textureId = await _pose.start();
      _subscription = _pose.frames.listen((frame) {
        if (mounted) setState(() => _status = frame.trackingState.name);
      });
      if (mounted) setState(() => _textureId = textureId);
    } on MotionfitPoseException catch (error) {
      if (mounted) setState(() => _status = error.code);
    }
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    unawaited(_pose.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: const Text('MotionFit pose example')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_textureId case final textureId?) Texture(textureId: textureId),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: FilledButton(
                  onPressed: _textureId == null ? _start : null,
                  child: Text(_textureId == null ? 'Start camera' : _status),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
