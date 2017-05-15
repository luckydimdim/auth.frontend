import 'package:converters/json_converter.dart';
import 'package:converters/map_converter.dart';
import 'package:converters/reflector.dart';

@reflectable
/**
 * Модель активации
 */
class ActivateModel extends Object with JsonConverter, MapConverter {
  String login;
  String password;
  String hash;

  ActivateModel([this.login, this.password, this.hash]);
}
