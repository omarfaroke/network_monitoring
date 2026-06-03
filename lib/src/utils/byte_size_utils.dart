/// Formats byte counts for HTTP payload display (B, KB, MB, GB).
abstract final class ByteSizeUtils {
  ByteSizeUtils._();

  static String format(int bytes) {
    if (bytes < 0) return '0 B';
    if (bytes < 1024) return '$bytes B';

    const units = ['KB', 'MB', 'GB'];
    var value = bytes / 1024;
    var unitIndex = 0;

    while (value >= 1024 && unitIndex < units.length - 1) {
      value /= 1024;
      unitIndex++;
    }

    final decimals = value >= 100 ? 0 : value >= 10 ? 1 : 2;
    return '${value.toStringAsFixed(decimals)} ${units[unitIndex]}';
  }
}
