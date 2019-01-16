library perf_timer;

class TimerNotFoundException implements Exception {
  String message;
  TimerNotFoundException(this.message);
}

// Perf timer
class Perf {
  static bool devOnly = true;
  static bool isDev = (() {
    bool isDev = false;

    assert(() {
      isDev = true;
      return isDev;
    }());

    return isDev;
  })();

  static Map<String, List<int>> _time;
  static Map<String, Stopwatch> _timers;

  /// Starts timer for specific [label]
  /// Call [pause] to pause a timer
  /// Next call of [start] will resume the timer
  static start(String label) {
    if (devOnly && !isDev) {
      return;
    }

    if (_timers.containsKey(label)) {
      _timers[label].reset();
      _timers[label].start();
    } else {
      _timers[label] = new Stopwatch();
      _time[label] = [];
    }
  }

  /// Stops timer for specific [label]
  /// Call [start] to resume a timer
  /// Throws [TimerNotFoundException] if called for timer which doesn't exist
  static pause(String label) {
    if (devOnly && !isDev) {
      return;
    }

    if (_timers[label] == null) {
      throw new TimerNotFoundException('Timer $label does not exist');
    }

    _timers[label].stop();
    _time[label].add(_timers[label].elapsedMicroseconds);
  }

  toString() {
    if (devOnly && !isDev) {
      return '';
    }

    final keys = [];
    final values = [];

    final totalLabel = 'Total';
    int longestLabelLength = totalLabel.length;

    _time.forEach((String label, List<int> _values) {
      keys.add(label);
      values.add(_values.fold(0, (a, b) => a + b));
      longestLabelLength =
          longestLabelLength < label.length ? label.length : longestLabelLength;
    });

    final entries = _time.entries.map((entry) {
      return {
        'key': entry.key,
        'value': entry.value.fold(0, (a, b) => a + b),
      };
    });

    final totalTime = entries.fold(0, (total, entry) => total + entry['value']);

    final mappedEntries = entries.map((entry) {
      final percents = entry['value'] / totalTime * 100;
      entry['percents'] = percents;
      return entry;
    }).toList();

    final sortedEntries = mappedEntries
      ..sort((a, b) {
        return (b['percents'] - a['percents']) ~/ 1;
      });

    String result = sortedEntries.fold('', (str, entry) {
      String percentsString = '';

      final key = entry['key'];
      final value = entry['value'];
      final percents = entry['percents'];

      final dotsCount = longestLabelLength - key.length + 3;
      final dots = '.' * dotsCount;

      final label = '$key$dots';

      if (percents < 10) {
        percentsString = ' ${percents.toStringAsFixed(2)}';
      } else {
        percentsString = percents.toStringAsFixed(2);
      }

      str += '\n$percentsString% $label$value';
      return str;
    });

    final dotsCount = longestLabelLength - totalLabel.length + 3;
    final dots = '.' * dotsCount;

    result += '\n\n${' ' * 7}$totalLabel$dots$totalTime';

    return result;
  }

  /// Stops all timers
  static stop() {
    _time = _time.map((String key, List<int> value) {
      return MapEntry(key, []);
    });
  }
}
