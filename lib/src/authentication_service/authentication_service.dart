import 'dart:convert';
import 'dart:html' hide Client;
import 'dart:async';
import 'dart:core';

import 'create_token_model.dart';
import 'refresh_token_model.dart';
import 'activate_model.dart';
import 'package:http/http.dart';
import 'package:angular2/angular2.dart';
import 'package:config/config_service.dart';
import 'package:logger/logger_service.dart';

import '../jwt/cmas_jwt_claim_set.dart';
import '../consts.dart';

@Injectable()
class AuthenticationService {
  /**
   * Url компонента авторизации
   * Может использоваться  компонентами, чтобы узнать, находится ли пользователь
   * на странице авторизации или нет
   */
  String authPath = 'auth';

  String activationPath = 'activation';

  /**
   * Период обновления токена, в минутах
   */
  static const int _refreshTokenDuration = 15;

  final Client _http;
  final ConfigService _config;
  LoggerService _logger;
  Timer _refreshTimer;
  CmasJwtClaimSet _claimSet;

  AuthenticationService(this._http, this._config) {
    _logger = new LoggerService(_config);

    _cacheUserData();

    startRefreshToken();
  }

  /**
   * Возвращает true, если пользовать аутентифицирован
   */
  bool isAuth() {
    return window.localStorage.containsKey(jwtKey);
  }

  /**
   * Получить текущий токен
   */
  String getToken() {
    if (isAuth()) {
      return window.localStorage[jwtKey];
    } else
      return null;
  }

  void removeToken() {
    window.localStorage.remove(jwtKey);
    _claimSet = null;
  }

  void setToken(String token) {
    window.localStorage[jwtKey] = token;

    _cacheUserData();
  }

  void _cacheUserData() {
    var token = getToken();

    if (token == null)
      return;

    try {
      _claimSet = cmasClaimSetParser(token);
    }
    catch (e) {
      removeToken();
      rethrow;
    }
  }

  /**
   *
   */
  String getUserName() {
    if (!isAuth() || _claimSet == null) return null;

    return _claimSet.name;
  }

  /**
   * Создать токен
   * Возвращает токен в случае успеха. null в случае ошибки (неправильный логин/пароль)
   */
  Future<String> _createToken(CreateTokenModel model) async {
    _logger.trace('login. Url: ${ _config.helper.authUrl }/create-token');

    Response response = null;

    try {
      response = await _http.post('${ _config.helper.authUrl }/create-token',
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
    } else if (response.statusCode == 400) {
      return null; // неправильный логин/пароль
    } else {
      _logger
          .error('login response: Code: ${response.statusCode}  Body: ${response
              .body}');
      throw new Exception('Unknown HTTP error');
    }
  }


  /**
   * Активировать учетку
   */
  Future<bool> activate(String login, String password, String actHash) async {
    _logger.trace('activate. Url: ${ _config.helper.authUrl }/activate');

    ActivateModel model = new ActivateModel()
    ..login = login
    ..password = password
    ..hash = actHash;

    Response response = null;

    try {
      response = await _http.post('${ _config.helper.authUrl }/activate',
          body: model.toJsonString(),
          headers: {'Content-Type': 'application/json'});
    } catch (e) {
      _logger.error('Failed to activate: $e');
      throw new Exception(e);
    }

    _logger.trace(
        'activate response: Code: ${response.statusCode}  Body: ${response.body}');

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 400) {
      return false; // ошибка при активации
    } else {
      _logger
          .error('activate response: Code: ${response.statusCode}  Body: ${response
          .body}');
      throw new Exception('Unknown HTTP error');
    }
  }

  /**
   * Проверить надежность пароля
   */
  Future<bool> checkPassSecurity(String password) async {
    _logger.trace('activate. Url: ${ _config.helper.authUrl }/password-is-secure');

    Response response = null;

    try {
      response = await _http.post('${ _config.helper.authUrl }/password-is-secure',
          body: '{"password":"$password"}',
          headers: {'Content-Type': 'application/json'});
    } catch (e) {
      _logger.error('Failed to activate: $e');
      throw new Exception(e);
    }

    _logger.trace(
        'activate response: Code: ${response.statusCode}  Body: ${response.body}');

    if (response.statusCode == 200) {
      var json = JSON.decode(response.body);

      return json['result'];

    } else if (response.statusCode == 400) {
      return false; //
    } else {
      _logger
          .error('activate response: Code: ${response.statusCode}  Body: ${response
          .body}');
      throw new Exception('Unknown HTTP error');
    }
  }

  /**
   * Обновить токен
   * Возвращает true в случае успеха. False в случае ошибки (некорректный токен)
   */
  Future<String> _refreshToken() async {
    _logger
        .trace('refresh token. Url: ${ _config.helper.authUrl }/refresh-token');

    Response response = null;

    var currentToken = getToken();

    if (currentToken == null) return null;

    RefreshTokenModel model = new RefreshTokenModel(currentToken);

    try {
      response = await _http.post('${ _config.helper.authUrl }/refresh-token',
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
    } else if (response.statusCode == 400) {
      return null;
    } else {
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

    removeToken();

    stopRefreshToken();
  }

  void startRefreshToken() {
    if (_refreshTimer != null && _refreshTimer.isActive) return;

    if (!isAuth()) return;

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
