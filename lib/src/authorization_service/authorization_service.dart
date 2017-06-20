import 'dart:html' hide Client;
import 'dart:core';

import 'package:angular2/angular2.dart';
import '../consts.dart';
import '../role.dart';
import '../jwt/cmas_jwt_claim_set.dart';

@Injectable()
class AuthorizationService {
  CmasJwtClaimSet _claimSet;
  String _token;

  AuthorizationService() {
    _cacheUserData();
  }

  void _cacheUserData() {
    var token = window.localStorage[jwtKey];

    if (token == null) return;

    _token = token;
    _claimSet = cmasClaimSetParser(token);
  }

  /**
   * Получить роли текущего пользователя
   */
  List<Role> getRoles() {
    if (_token != window.localStorage[jwtKey])
      _cacheUserData(); // перелогинились

    if (_claimSet == null) return new List<Role>();

    return _claimSet.roles;
  }

  bool isInRole(Role role) {
    List<Role> roles = getRoles();

    if (roles == null) return false;

    return roles.contains(role);
  }

  bool isOneRole(Role role) {
    List<Role> roles = getRoles();

    if (roles == null) return false;

    return (roles.contains(role) && roles.length == 1);
  }
}
