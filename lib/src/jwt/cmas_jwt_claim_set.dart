import 'dart:convert';
import '../role.dart';
import 'jose.dart';

CmasJwtClaimSet cmasClaimSetParser(String str) =>
    new CmasJwtClaimSet.fromString(str);

List<Role> _convertStrToRoles(String rolesString) {
  List<Role> result = new List<Role>();

  var strRolesArray = rolesString.split(',');

  // FIXME: сделать парсер перечислений
  strRolesArray.forEach((r) {
    if (r.toUpperCase().trim() == 'CUSTOMER')
      result.add(Role.Customer);
    else if (r.toUpperCase().trim() == 'CONTRACTOR')
      result.add(Role.Contractor);
    else if (r.toUpperCase().trim() == 'ADMINISTRATOR')
      result.add(Role.Administrator);
    else
      result.add(Role.Unknown);
  });

  return result;
}

class CmasJwtClaimSet {
  String login;
  String name;
  List<Role> roles;

  CmasJwtClaimSet.fromString(String token) {
    final base64Segs = token.split('.');
    if (base64Segs.length != 3)
      throw new ArgumentError(
          "JWS tokens must be in form '<header>.<payload>.<signature>'.\n"
          "Value: '$token' is invalid");

    var json = Base64EncodedJson.decodeToJson(base64Segs.elementAt(1));

    login = json['sub'];
    name = json['snm'];
    roles = _convertStrToRoles(json['roles']);
  }

  Map toJson() => {'sub': login, 'snm': name, 'roles': roles};

  String toString() => JSON.encode(this);
}
