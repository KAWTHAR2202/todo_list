import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../service/notification_service.dart';
import '../controller/achievement_controller.dart';

class PomodoroPage extends StatefulWidget {
  const PomodoroPage({super.key});

  @override
  State<PomodoroPage> createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage> with TickerProviderStateMixin {
  // Timer settings (in minutes)
  int workDuration = 25;
  int shortBreakDuration = 5;
  int longBreakDuration = 15;
  int sessionsBeforeLongBreak = 4;

  // State
  int _remainingSeconds = 25 * 60;
  int _completedSessions = 0;
  bool _isRunning = false;
  bool _isWorkSession = true;
  Timer? _timer;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = workDuration * 60;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() => _isRunning = true);
    _pulseController.repeat(reverse: true);
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _onTimerComplete();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _pulseController.stop();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    _pulseController.stop();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _isWorkSession ? workDuration * 60 : _getBreakDuration() * 60;
    });
  }

  int _getBreakDuration() {
    if (_completedSessions > 0 && _completedSessions % sessionsBeforeLongBreak == 0) {
      return longBreakDuration;
    }
    return shortBreakDuration;
  }

  void _onTimerComplete() {
    _timer?.cancel();
    _pulseController.stop();
    
    if (_isWorkSession) {
      _completedSessions++;
      
      // Track achievement for Pomodoro
      if (Get.isRegistered<AchievementController>()) {
        AchievementController.to.onPomodoroCompleted();
      }
      
      NotificationService.showInstantNotification(
        '🍅 Pomodoro Complete!',
        'Great job! Take a ${_getBreakDuration()} minute break.',
      );
      setState(() {
        _isWorkSession = false;
        _remainingSeconds = _getBreakDuration() * 60;
        _isRunning = false;
      });
    } else {
      NotificationService.showInstantNotification(
        '⏰ Break Over!',
        'Time to get back to work!',
      );
      setState(() {
        _isWorkSession = true;
        _remainingSeconds = workDuration * 60;
        _isRunning = false;
      });
    }
  }

  void _skipSession() {
    _timer?.cancel();
    _pulseController.stop();
    setState(() {
      if (_isWorkSession) {
        _isWorkSession = false;
        _remainingSeconds = _getBreakDuration() * 60;
      } else {
        _isWorkSession = true;
        _remainingSeconds = workDuration * 60;
      }
      _isRunning = false;
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  double get _progress {
    int totalSeconds = _isWorkSession ? workDuration * 60 : _getBreakDuration() * 60;
    return 1 - (_remainingSeconds / totalSeconds);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = _isWorkSession ? Colors.red.shade400 : Colors.green.shade400;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🍅 Pomodoro Timer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Session indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _isWorkSession ? '💼 Work Session' : '☕ Break Time',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Timer circle
              ScaleTransition(
                scale: _pulseAnimation,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 280,
                      height: 280,
                      child: CircularProgressIndicator(
                        value: _progress,
                        strokeWidth: 12,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(_remainingSeconds),
                          style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isWorkSession ? 'Focus Time' : 'Relax',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Control buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Reset button
                  IconButton.filled(
                    onPressed: _resetTimer,
                    icon: const Icon(Icons.refresh),
                    iconSize: 32,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.grey.shade700,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(width: 24),
                  
                  // Play/Pause button
                  IconButton.filled(
                    onPressed: _isRunning ? _pauseTimer : _startTimer,
                    icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                    iconSize: 48,
                    style: IconButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(24),
                    ),
                  ),
                  const SizedBox(width: 24),
                  
                  // Skip button
                  IconButton.filled(
                    onPressed: _skipSession,
                    icon: const Icon(Icons.skip_next),
                    iconSize: 32,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.grey.shade700,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // Sessions completed
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Sessions', '$_completedSessions', Icons.check_circle, Colors.green),
                    Container(width: 1, height: 40, color: Colors.grey.shade300),
                    _buildStatItem('Focus Time', '${_completedSessions * workDuration}m', Icons.timer, primaryColor),
                    Container(width: 1, height: 40, color: Colors.grey.shade300),
                    _buildStatItem('Goal', '$sessionsBeforeLongBreak', Icons.flag, Colors.blue),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  void _showSettingsDialog() {
    // Local copies for the dialog
    int tempWorkDuration = workDuration;
    int tempShortBreak = shortBreakDuration;
    int tempLongBreak = longBreakDuration;
    int tempSessions = sessionsBeforeLongBreak;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('⚙️ Timer Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSettingSliderInDialog(
                'Work Duration',
                tempWorkDuration,
                5,
                60,
                (value) {
                  setDialogState(() => tempWorkDuration = value.round());
                },
              ),
              _buildSettingSliderInDialog(
                'Short Break',
                tempShortBreak,
                1,
                15,
                (value) {
                  setDialogState(() => tempShortBreak = value.round());
                },
              ),
              _buildSettingSliderInDialog(
                'Long Break',
                tempLongBreak,
                10,
                30,
                (value) {
                  setDialogState(() => tempLongBreak = value.round());
                },
              ),
              _buildSettingSliderInDialog(
                'Sessions before long break',
                tempSessions,
                2,
                8,
                (value) {
                  setDialogState(() => tempSessions = value.round());
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  workDuration = tempWorkDuration;
                  shortBreakDuration = tempShortBreak;
                  longBreakDuration = tempLongBreak;
                  sessionsBeforeLongBreak = tempSessions;
                  if (_isWorkSession && !_isRunning) {
                    _remainingSeconds = workDuration * 60;
                  } else if (!_isWorkSession && !_isRunning) {
                    _remainingSeconds = _getBreakDuration() * 60;
                  }
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingSliderInDialog(String label, int value, int min, int max, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text('$value min', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: max - min,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
