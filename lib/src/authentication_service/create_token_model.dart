import 'package:converters/json_converter.dart';
import 'package:converters/map_converter.dart';
import 'package:converters/reflector.dart';

@reflectable
/**
 * Модель аутентификации
 */
class CreateTokenModel extends Object with JsonConverter, MapConverter {
  String login;
  String password;

  CreateTokenModel([this.login, this.password]);
}
