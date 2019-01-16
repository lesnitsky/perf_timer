# Perf Timer

Perf timer for dart and flutter
Works only in dev mode

## Example

```dart
import 'package:perf_timer/perf_timer.dart';

void main() {
    final t = new PerfTimer();

    t.start('computation 1');
    someLongComputation();
    t.pause('computation 1');

    t.start('computation 2');
    someOtherLongComputation();
    t.pause('computation 2');

    print(t);
    t.stop();
}
```

## Author

[Andrei Lesnitsky](https://twitter.com/lesnitsky_a)

## License

MIT
