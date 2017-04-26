import 'dart:html';
import 'dart:async';
import 'dart:core';

import 'package:angular2/angular2.dart';
import 'package:config/config_service.dart';
import 'package:logger/logger_service.dart';

@Injectable()
class AuthenticationService {

  /**
   * Url компонента авторизации
   * Может использоваться  компонентами, чтобы узнать, находится ли пользователь
   * на странице авторизации или нет
   */
  String authPath = 'auth';
  static const String jwtKey = "cmas-jwt";

  final Client _http;
  final ConfigService _config;
  LoggerService _logger;

  AuthenticationService(this._http, this._config) {
    _logger = new LoggerService(_config);
  }

  bool isAuth() {
    return window.localStorage.containsKey(jwtKey);
  }

  Future<bool> login(String login, String password) async {

    _logger.trace('login. Url: ${ _config.helper.timeSheetsUrl }');

    if (login == "1" && password == "1" ){
        window.localStorage[jwtKey] = 'blah';
        return true;
    } else {
      return false;
    }
  }

  void logout() {
    window.localStorage.remove(jwtKey);
  }
}