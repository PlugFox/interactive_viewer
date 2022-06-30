import 'dart:async';

/// Prevents the callback from executing until [delayMs] has passed without any new [run] calls
class Debouncer {
  final int delayMs;

  Timer? _timer;

  Debouncer({required this.delayMs});

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: delayMs), action);
  }

  void stop() {
    _timer?.cancel();
  }
}

class Throttler {
  final int delayMs;

  Timer? _timer;
  Timer? _releaseTimer;

  Throttler({required this.delayMs});

  bool _isLocked = false;
  void run(void Function() action) {
    _timer?.cancel();
    if (_isLocked) {
      _timer = Timer(Duration(milliseconds: delayMs), () {
        if (!_isLocked) {
          _runAction(action);
        }
      });
      return;
    }
    _runAction(action);
  }

  void _runAction(void Function() action) {
    _isLocked = true;
    _releaseTimer?.cancel();
    _releaseTimer = Timer(Duration(milliseconds: delayMs), () {
      _isLocked = false;
    });
    action();
  }

  void stop() {
    _timer?.cancel();
  }
}
