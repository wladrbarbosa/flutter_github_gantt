import 'package:let_log/let_log.dart';
import 'package:flutter/foundation.dart';

class Log {
  static show(String level, String msg) {
    if (!kReleaseMode) {
      switch (level) {
        case 'e':
          Logger.error(DateTime.now(), msg);
        break;
        case 'w':
          Logger.warn(DateTime.now(), msg);
        break;
        case 'd':
          Logger.debug(DateTime.now(), msg);
        break;
        default:
          Logger.log(DateTime.now(), msg);
      }
    }
  }

  static showLogColors() {
    for (int i = 0; i < 11; i++) {
      for (int j = 0; j < 10; j++) {
        int n = 10*i + j;
        if (n > 108) break;
        debugPrint("\x1B[${n}m $n\x1B[[m");
      }
      debugPrint("\n");
    }
  }

  static netStartShow(String endPoint, {String type = 'Http', Object? data, int status = 100}) {
    if (!kReleaseMode) {
      Logger.net(endPoint, type: '\x1B[37m(${DateTime.now()})\x1B[0m $type', status: status, data: '\x1B[32m$data\x1B[0m');
    }
  }

  static netEndShow(String endPoint, {String? type, Object? headers, Object? data, int status = 200}) {
    if (!kReleaseMode) {
      Logger.endNet(endPoint, type: '\x1B[37m(${DateTime.now()})\x1B[0m $type', status: status, data: '\x1B[32m$data\x1B[0m', headers: headers);
    }
  }
}