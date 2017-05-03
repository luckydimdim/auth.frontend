import 'package:dart_jwt/dart_jwt.dart';
@TestOn('dartium')
import 'package:test/test.dart';

main() {
  group('test group', () {
    setUp(() {});

    test('some test', () {
      var token =
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiZXhwIjo2MzYyOTMyMzIyMjc1MTQ4NzQsImlhdCI6NjM2MjkzMTk2MjI3NTE0ODc0LCJzcGgiOiI2MDI4MGQwNWMzIiwic25tIjoi0JfQsNC60LDQt9GH0LjQuiIsInJvbGVzIjoiQ09OVFJBQ1RPUixDVVNUT01FUiJ9.kaqdhpWE5fQ-RG2ZfcngPcrzDdf8ORcZhBvMphNPvNc';
      JsonWebToken jwt =
          new JsonWebToken.decode(token, claimSetParser: mapClaimSetParser);

      expect(jwt.payload.json['snm'], 'Подрядчик');
    });
  });
}
