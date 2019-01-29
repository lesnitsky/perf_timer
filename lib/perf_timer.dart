library perf_timer;

class TimerNotFoundException implements Exception {
  String message;
  TimerNotFoundException(this.message);
}

// Perf timer
class PerfTimer {
  static bool devOnly = true;
  static bool useMicroseconds = false;
  static bool isDev = (() {
    bool isDev = false;

    assert(() {
      isDev = true;
      return isDev;
    }());

    return isDev;
  })();

  static Map<String, List<int>> _time = {};
  static Map<String, Stopwatch> _timers = {};

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
      _timers[label] = new Stopwatch()..start();
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

  /// Returns formatted string with all timers results
  static String report() {
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

      String valueStr = value.toString();
      if (useMicroseconds == false) {
        valueStr = (value / 1000).toStringAsFixed(2) + " ms";
      }
      str += '\n$percentsString% $label$valueStr';
      return str;
    });

    final dotsCount = longestLabelLength - totalLabel.length + 3;
    final dots = '.' * dotsCount;

    String totalTimeStr = totalTime.toString();
    if (useMicroseconds == false) {
      totalTimeStr = (totalTime / 1000).toStringAsFixed(2) + " ms";
    }
    result += '\n\n${' ' * 7}$totalLabel$dots$totalTimeStr';

    return result;
  }

  /// Stops all timers
  static stop() {
    _time = _time.map((String key, List<int> value) {
      return MapEntry(key, []);
    });
  }
}
