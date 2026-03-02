import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sprint_controller.dart';

class SprintActiveScreen extends ConsumerStatefulWidget {
  const SprintActiveScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SprintActiveScreen> createState() => _SprintActiveScreenState();
}

class _SprintActiveScreenState extends ConsumerState<SprintActiveScreen> {
  @override
  void initState() {
    super.initState();
    // Start calibration as soon as we enter the screen
    Future.microtask(() => ref.read(sprintControllerProvider.notifier).startCalibration());
  }

  @override
  void dispose() {
    // IMPORTANT: Make sure to stop run/sensors when leaving screen
    Future.microtask(() => ref.read(sprintControllerProvider.notifier).stopRunning());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sprintData = ref.watch(sprintControllerProvider);
    final sprintNotifier = ref.read(sprintControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('100m Sprint'),
        backgroundColor: Colors.redAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStateDisplay(
              sprintData.state,
              sprintData.countdown,
            ),
            const SizedBox(height: 50),
            
            // Distance Metric
            _buildMetricDisplay(
              label: 'DISTANCE',
              value: '${sprintData.distanceRun.toStringAsFixed(1)} m',
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 20),

            // Speed Metrics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMetricDisplay(
                  label: 'CURRENT SPEED',
                  value: '${(sprintData.currentSpeed * 3.6).toStringAsFixed(1)} km/h',
                  color: Colors.green,
                ),
                _buildMetricDisplay(
                  label: 'TOP SPEED',
                  value: '${(sprintData.maxSpeed * 3.6).toStringAsFixed(1)} km/h',
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Time Metric
            _buildMetricDisplay(
              label: 'TIME',
              value: _formatDuration(sprintData.elapsed),
              color: Colors.orange,
              size: 48,
            ),
            
            const SizedBox(height: 50),
            _buildActionButtons(sprintData.state, sprintNotifier),
            
            const SizedBox(height: 30),
            // On-Screen Debug Logger
            if (sprintData.debugLog.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  sprintData.debugLog,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Colors.greenAccent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStateDisplay(SprintState state, int countdown) {
    String text = '';
    Color color = Colors.black;

    switch (state) {
      case SprintState.calibrating:
        text = 'CALIBRATING GPS... STAND STILL';
        color = Colors.orange;
        break;
      case SprintState.ready:
        text = 'READY';
        color = Colors.green;
        break;
      case SprintState.countdown:
        text = '$countdown';
        color = Colors.red;
        return Text(text, style: TextStyle(fontSize: 100, fontWeight: FontWeight.bold, color: color));
      case SprintState.running:
        text = 'GO!';
        color = Colors.redAccent;
        break;
      case SprintState.finished:
        text = 'FINISHED!';
        color = Colors.blue;
        break;
    }

    return Text(
      text,
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildMetricDisplay({
    required String label,
    required String value,
    required Color color,
    double size = 32,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        Text(
          value,
          style: TextStyle(fontSize: size, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildActionButtons(SprintState state, SprintController notifier) {
    if (state == SprintState.ready) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        ),
        onPressed: () => notifier.startCountdown(),
        child: const Text('START SPRINT', style: TextStyle(fontSize: 24, color: Colors.white)),
      );
    } else if (state == SprintState.finished || state == SprintState.calibrating) {
       return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        ),
        onPressed: () => notifier.startCalibration(), // Reset essentially
        child: const Text('RESET', style: TextStyle(fontSize: 18, color: Colors.white)),
      );
    }
    return const SizedBox.shrink(); // Hide button while running or in countdown
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    String twoDigitMilliseconds = twoDigits((duration.inMilliseconds.remainder(1000) / 10).floor());
    return "$twoDigitMinutes:$twoDigitSeconds.$twoDigitMilliseconds";
  }
}
