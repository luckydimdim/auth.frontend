import 'package:angular2/core.dart';
import 'package:angular2/router.dart';

import 'package:alert/alert_service.dart';

import 'loginModel.dart';
import 'auth_service.dart';

@Component(
  selector: 'auth',
  templateUrl: 'auth_component.html')
class AuthComponent implements OnInit {
  LoginModel model;
  final Router _router;
  final AlertService _alertService;
  final AuthenticationService _authenticationService;
  String errors;

  AuthComponent(this._router, this._alertService, this._authenticationService) {
    model = new LoginModel();
  }

  @override
  void ngOnInit() {

  }

  onSubmit() {

    errors = null;

    _authenticationService.login(model.login, model.password).then((result){
      if (result == true) {

        _authenticationService.startRefreshToken();

        var queryUrl = Uri.base.queryParameters['url'];

        if (queryUrl != '' && queryUrl != null)
          _router.navigateByUrl(queryUrl);
        else
          _router.parent.navigate(['Master/Dashboard']);
      }
      else {
        errors = 'Неправильный логин или пароль';
        _alertService.Warning('Ошибка. Неправильный логин или пароль');
      }

    }).catchError((e){
      errors = 'Непредвиденная ошибка';
      _alertService.Danger('Непредвиденная ошибка');
      print('Непредвиденная ошибка: ${e.toString()}');
    });
  }
}