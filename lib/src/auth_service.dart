import 'dart:html';
import 'dart:async';
import 'dart:core';

import 'package:angular2/angular2.dart';


@Injectable()
class AuthenticationService {

  bool isAuth() {
    return window.localStorage.containsKey('currentUser');
  }

  Future<bool> login(String username, String password) async {
    var url = "http://localhost:5000/api/authentication/login";
    var request = new HttpRequest();
    request.open("POST", url);

    request.send({
      'content': 'this is a test',
      'email': 'john@doe.com',
      'number': '441276300056'
    })
        .then((response) {
      window.localStorage['currentUser'] = 'fake data';
      return true;
    })
        .catchError((e) {
      logout();
      return false;
    });

    return false;
  }

  void logout() {
    window.localStorage.remove('currentUser');
  }

}