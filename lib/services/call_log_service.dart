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

  Future<List<CallLogEntry>> getRecentCalls({int limit = 20}) async {
    if (!await hasCallLogPermission()) {
      final granted = await requestCallLogPermission();
      if (!granted) return [];
    }
    final Iterable<CallLogEntry> entries = await CallLog.get(limit: limit);
    return entries.toList();
  }
}
