import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

final appLogger = AppLogger._instance;

class AppLogger {
  AppLogger._();

  static final AppLogger _instance = AppLogger._();

  final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    level: kDebugMode ? Level.trace : Level.off,
  );

  static const _prefix = '[ADMITLY]';

  void d(dynamic message, {Object? error, StackTrace? stackTrace}) =>
      _logger.d('$_prefix $message', error: error, stackTrace: stackTrace);

  void i(dynamic message, {Object? error, StackTrace? stackTrace}) =>
      _logger.i('$_prefix $message', error: error, stackTrace: stackTrace);

  void w(dynamic message, {Object? error, StackTrace? stackTrace}) =>
      _logger.w('$_prefix $message', error: error, stackTrace: stackTrace);

  void e(dynamic message, {Object? error, StackTrace? stackTrace}) =>
      _logger.e('$_prefix $message', error: error, stackTrace: stackTrace);

  void t(dynamic message) => _logger.t('$_prefix $message');
}
