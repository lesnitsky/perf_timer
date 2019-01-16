# Perf Timer

Perf timer for dart and flutter

> Works only in dev mode

![iTerm Screenshot](https://s3.eu-west-2.amazonaws.com/screenshots-lesnitsky/perf_timer.png)

## Example

```dart
import 'package:perf_timer/perf_timer.dart';

void main() {
    PerfTimer.start('computation 1');
    someLongComputation();
    PerfTimer.pause('computation 1');

    PerfTimer.start('computation 2');
    someOtherLongComputation();
    PerfTimer.pause('computation 2');

    print(PerfTimer.report());
    PerfTimer.stop();
}
```

## Author

[Andrei Lesnitsky](https://twitter.com/lesnitsky_a)

## License

MIT
