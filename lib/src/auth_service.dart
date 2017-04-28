import 'dart:convert';
import 'dart:html' hide Client;
import 'dart:async';
import 'dart:core';

import 'createTokenModel.dart';
import 'refreshTokenModel.dart';
import 'package:http/http.dart';
import 'package:angular2/angular2.dart';
import 'package:config/config_service.dart';
import 'package:logger/logger_service.dart';
import 'package:dart_jwt/dart_jwt.dart';

@Injectable()
class AuthenticationService {

  /**
   * Url компонента авторизации
   * Может использоваться  компонентами, чтобы узнать, находится ли пользователь
   * на странице авторизации или нет
   */
  String authPath = 'auth';

  /**
   * Ключ, где хранится токен
   */
  static const String userInfoKey = "cmas-user-info";

  /**
   * Период обновления токена, в минутах
   */
  static const int _refreshTokenDuration = 15;

  final Client _http;
  final ConfigService _config;
  LoggerService _logger;
  Timer _refreshTimer;

  AuthenticationService(this._http, this._config) {
    _logger = new LoggerService(_config);

    startRefreshToken();
  }

  /**
   * Возвращает true, если пользовать аутентифицирован
   */
  bool isAuth() {
    return window.localStorage.containsKey(userInfoKey);
  }

  /**
   * Получить текущий токен
   */
  String getToken() {
    if (isAuth()) {
      dynamic userData = JSON.decode(window.localStorage[userInfoKey]);
      return userData['Token'];
    }
    else
      return null;
  }

  void setToken(String token) {


    JsonWebToken jwt = new JsonWebToken.decode(token, claimSetParser: mapClaimSetParser);

    window.localStorage[userInfoKey] = JSON.encode(
        {"Login": jwt.payload.json['sub'], "Name": jwt.payload.json['snm'], "Roles": jwt.payload.json['roles'], "Token": token});
  }


  /**
   * Получить роли текущего пользователя
   */
  List<String> getRoles() {
    var result = new List<String>();

    if (!isAuth())
      return result;

    dynamic userData = JSON.decode(window.localStorage[userInfoKey]);

    return userData['Roles'];
  }

  /**
   * Получить роли текущего пользователя
   */
  String getUserName() {

    if (!isAuth())
      return null;

    dynamic userData = JSON.decode(window.localStorage[userInfoKey]);

    return userData['Name'];
  }

  /**
   * Создать токен
   * Возвращает токен в случае успеха. null в случае ошибки (неправильный логин/пароль)
   */
  Future<String> _createToken(CreateTokenModel model) async {
    _logger.trace('login. Url: ${ _config.helper.authUrl }/create-token');

    Response response = null;

    try {
      response = await
      _http.post('${ _config.helper.authUrl }/create-token',
          body: model.toJsonString(),
          headers: {'Content-Type': 'application/json'});
    } catch (e) {
      _logger.error('Failed to login: $e');
      throw new Exception(e);
    }

    _logger.trace(
        'login response: Code: ${response.statusCode}  Body: ${response.body}');

    if (response.statusCode == 200) {
      return response.body;
    }
    else if (response.statusCode == 400) {
      return null; // неправильный логин/пароль
    }
    else {
      _logger.error(
          'login response: Code: ${response.statusCode}  Body: ${response
              .body}');
      throw new Exception('Unknown HTTP error');
    }
  }

  /**
   * Обновить токен
   * Возвращает true в случае успеха. False в случае ошибки (некорректный токен)
   */
  Future<String> _refreshToken() async {
    _logger.trace(
        'refresh token. Url: ${ _config.helper.authUrl }/refresh-token');

    Response response = null;

    var currentToken = getToken();

    if (currentToken == null)
      return null;

    RefreshTokenModel model = new RefreshTokenModel(currentToken);

    try {
      response = await
      _http.post('${ _config.helper.authUrl }/refresh-token',
          body: model.toJsonString(),
          headers: {'Content-Type': 'application/json'});
    } catch (e) {
      _logger.error('Failed to login: $e');
      throw new Exception(e);
    }

    _logger.trace(
        'refresh token response: Code: ${response.statusCode}  Body: ${response
            .body}');

    if (response.statusCode == 200) {
      return response.body;
    }
    else if (response.statusCode == 400) {
      return null;
    }
    else {
      _logger.error('refresh token response: Code: ${response
          .statusCode}  Body: ${response.body}');
      throw new Exception('Unknown HTTP error');
    }
  }

  Future<bool> login(String login, String password) async {
    var createTokenModel = new CreateTokenModel()
      ..login = login
      ..password = password;

    String token = await _createToken(createTokenModel);

    if (token == null) {
      return false;
    }

    setToken(token);

    startRefreshToken();

    return true;
  }

  void logout() {
    window.localStorage.remove(userInfoKey);

    stopRefreshToken();
  }

  void startRefreshToken() {
    if (_refreshTimer != null && _refreshTimer.isActive)
      return;

    if (!isAuth())
      return;

    _refreshTimer = new Timer.periodic(
        new Duration(minutes: _refreshTokenDuration), _refreshTimerCallback);
  }

  void _refreshTimerCallback(Timer timer) {
    _refreshToken().then((token) {
      if (token == null) {
        timer.cancel();
        logout();
        return;
      }

      setToken(token);
    });
  }

  void stopRefreshToken() {
    if (_refreshTimer != null) {
      _refreshTimer.cancel();
    }
  }

}