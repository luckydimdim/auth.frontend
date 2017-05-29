import 'package:converters/json_converter.dart';
import 'package:converters/map_converter.dart';
import 'package:converters/reflector.dart';

@reflectable
/**
 * Модель активации
 */
class SendActLinkModel extends Object with JsonConverter, MapConverter {
  String login;
  String email;

  SendActLinkModel([this.login, this.email]);
}
