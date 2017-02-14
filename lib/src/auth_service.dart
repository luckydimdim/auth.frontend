import 'dart:html';
import 'dart:async';
import 'dart:core';

import 'package:angular2/angular2.dart';

@Injectable()
class AuthenticationService {

  bool isAuth() {
    return window.localStorage.containsKey('currentUser');
  }

  Future<bool> login(String login, String password) async {
    if (login == "1" && password == "1" ){
        window.localStorage['currentUser'] = 'blah';
        return true;
    } else {
      return false;
    }
  }

  void logout() {
    window.localStorage.remove('currentUser');
  }
}