import 'dart:html' hide Client;
import 'dart:core';

import 'package:angular2/angular2.dart';
import '../consts.dart';
import '../role.dart';
import 'package:dart_jwt/dart_jwt.dart';
import '../cmas_jwt_claim_set.dart';

@Injectable()
class AuthorizationService {

  JsonWebToken _jwt;

  AuthorizationService() {
    _cacheUserData();
  }

  void _cacheUserData() {
    var token =  window.localStorage[jwtKey];

    if (token == null)
      return;

    _jwt = new JsonWebToken.decode(token, claimSetParser: cmasClaimSetParser);
  }

  /**
   * Получить роли текущего пользователя
   */
  List<Role> getRoles() {
    if (_jwt == null) return new List<Role>();

    return _jwt.payload.roles;
  }

  bool isInRole(Role role) {
    List<Role> roles = getRoles();

    if (roles == null)
      return false;

    return roles.contains(role);
  }


}
