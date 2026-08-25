// مؤشر العد التنازلي المباشر — يتحدث كل ثانية
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/match.dart';
import '../utils/arabic_helpers.dart';
import '../utils/constants.dart';

class CountdownWidget extends StatefulWidget {
  final MatchModel match;

  const CountdownWidget({super.key, required this.match});

  @override
  State<CountdownWidget> createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget> {
  Timer? _timer;
  String _text = '';

  @override
  void initState() {
    super.initState();
    _update();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _update());
  }

  @override
  void didUpdateWidget(CountdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.match.id != widget.match.id ||
        oldWidget.match.matchDate != widget.match.matchDate ||
        oldWidget.match.matchTime != widget.match.matchTime) {
      _update();
    }
  }

  void _update() {
    final phase = widget.match.phase;
    final start = widget.match.startDateTime;
    final remaining = start.difference(DateTime.now());

    setState(() {
      _text = fmtCountdown(remaining, started: phase != 'before');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.timer_outlined, size: 18, color: AppColors.amber),
        const SizedBox(width: 6),
        Text(
          _text,
          style: const TextStyle(
            fontFamily: 'Changa',
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: AppColors.amber,
          ),
        ),
      ],
    );
  }
}
