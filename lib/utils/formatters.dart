import 'package:intl/intl.dart';

/// "1250000" -> "₩1,250,000" 형태로 변환하는 공용 포맷터.
class Formatters {
  Formatters._();

  static final NumberFormat _krwFormat = NumberFormat.decimalPattern('ko_KR');

  static String price(int amount) => '₩${_krwFormat.format(amount)}';

  /// AR 체험 시간 "3:45" (분:초) 형태로 변환.
  static String duration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(1, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
