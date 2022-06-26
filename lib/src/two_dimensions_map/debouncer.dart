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
