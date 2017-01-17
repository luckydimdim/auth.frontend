import 'dart:html';
import 'dart:async';
import 'dart:core';

import 'package:http/browser_client.dart';

import 'package:angular2/angular2.dart';


@Injectable()
class AuthenticationService {

  bool isAuth() {
    return window.localStorage.containsKey('currentUser');
  }

  Future<bool> login(String login, String password) async {

    var url = "http://localhost:5000/api/authentication/login";

    var client = new BrowserClient();

    var response = await client.post(url, body: {
      'login': login,
      'password': password
    });

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (200== response.statusCode){
      return true;
    }
    else
      return false;
  }

  void logout() {
    window.localStorage.remove('currentUser');
  }

}