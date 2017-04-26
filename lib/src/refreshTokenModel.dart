import 'package:converters/json_converter.dart';
import 'package:converters/map_converter.dart';
import 'package:converters/reflector.dart';
import 'package:angular2/core.dart';

@reflectable
/**
 * Модель обновления токена
 */
class RefreshTokenModel extends Object with JsonConverter, MapConverter {

  String token;

  RefreshTokenModel([this.token]);
}