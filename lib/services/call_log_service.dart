import 'package:permission_handler/permission_handler.dart';
import 'package:call_log/call_log.dart';

class CallLogService {
  Future<bool> requestCallLogPermission() async {
    final status = await Permission.phone.request();
    return status.isGranted;
  }

  Future<bool> hasCallLogPermission() async {
    return await Permission.phone.isGranted;
  }

  Future<List<CallLogEntry>> getRecentCalls({ int limit = 20 }) async {
    if (!await hasCallLogPermission()) {
      final granted = await requestCallLogPermission();
      if (!granted) return [];
    }

    // example: query last 60 days
    final now = DateTime.now().millisecondsSinceEpoch;
    final thirtyDaysAgo = DateTime.now()
        .subtract(Duration(days: 30))
        .millisecondsSinceEpoch;

    final Iterable<CallLogEntry> filtered = await CallLog.query(
      dateFrom: thirtyDaysAgo,
      dateTo: now,
      // other params: durationFrom, name, number, type...
    );  // :contentReference[oaicite:1]{index=1}

    return filtered.take(limit).toList();
  }

}
