import 'dart:html' hide Client;
import 'dart:async';
import 'dart:core';

import 'createTokenModel.dart';
import 'refreshTokenModel.dart';
import 'package:http/http.dart';
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

  String getToken() {
    if (isAuth())
      return window.localStorage[jwtKey];
    else
      return null;
  }

  List<String> getRoles() {
    var result = new List<String>();

    if (!isAuth())
      return result;

    return result;
  }

  Future<bool> _createToken(CreateTokenModel model) async {
    _logger.trace('login. Url: ${ _config.helper.authUrl }/create-token');

    Response response = null;

    try {
      response = await
      _http.post('${ _config.helper.authUrl }/create-token',
          body: model.toJsonString(),
          headers: {'Content-Type': 'application/json'});
    } catch (e) {
      _logger.error('Failed to login: $e');

      return false;
    }

    _logger.trace('login response: $response.');

    window.localStorage[jwtKey] = response.body;

    return true;
  }

  Future<bool> _refreshToken() async {
    _logger.trace(
        'refresh token. Url: ${ _config.helper.authUrl }/refresh-token');

    Response response = null;

    var currentToken = getToken();

    if (currentToken == null)
      return false;

    RefreshTokenModel model = new RefreshTokenModel(currentToken);

    try {
      response = await _http.post('${ _config.helper.authUrl }/refresh-token',
          body: model.toJsonString(),
          headers: {'Content-Type': 'application/json'});
    } catch (e) {
      _logger.error('Failed to login: $e');

      return false;
    }

    _logger.trace('refresh token response: $response.');

    window.localStorage[jwtKey] = response.body;

    return true;
  }

  Future<bool> login(String login, String password) async {
    var createTokenModel = new CreateTokenModel()
      ..login = login
      ..password = password;

    return await
    _createToken(createTokenModel);
  }

  void logout() {
    window.localStorage.remove(jwtKey);
  }
}