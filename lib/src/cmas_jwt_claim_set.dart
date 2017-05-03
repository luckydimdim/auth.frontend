import 'dart:convert';
import 'package:dart_jwt/dart_jwt.dart';
import 'role.dart';

JwtClaimSet cmasClaimSetParser(Map json) => new CmasJwtClaimSet.fromJson(json);

List<Role> _convertStrToRoles(String rolesString) {
  List<Role> result = new List<Role>();

  var strRolesArray = rolesString.split(',');

  strRolesArray.forEach((r) {
    if (r.toUpperCase().trim() == 'CUSTOMER')
      result.add(Role.Customer);
    else if (r.toUpperCase().trim() == 'CONTRACTOR')
      result.add(Role.Contractor);
    else
      result.add(Role.Unknown);
  });

  return result;
}

class CmasJwtClaimSet extends JwtClaimSet {
  final String login;
  final String name;
  final List<Role> roles;

  CmasJwtClaimSet(this.login, this.name, this.roles);

  CmasJwtClaimSet.fromJson(Map json): login = json['sub'], name = json['snm'],roles = _convertStrToRoles(json['roles']) ;

  Map toJson() => {
    'sub': login,
    'snm': name,
    'roles': roles
  };

  String toString() => JSON.encode(this);

  Set<ConstraintViolation> validate(JwtClaimSetValidationContext validationContext){
    return new Set();
  }

}