import 'package:angular2/core.dart';
import 'package:angular2/router.dart';
import '../../auth_service.dart';
import 'dart:html';

@Component(selector: 'activation', templateUrl: 'activation_component.html')
class ActivationComponent  implements OnInit {

  final AuthenticationService _authenticationService;
  final Router _router;
  String actHash;
  String errors;
  String login;
  String password;
  String password2;


  ActivationComponent(this._authenticationService, RouteParams params, this._router) {
    actHash = params.get('actHash');
    login = params.get('login');
  }

  @override
  void ngOnInit() {

  }

  onSubmit() async {
    errors = null;

    if (actHash == '' || actHash == null || login == '' || login == null) {
      errors = "Некорректная ссылка активации";
    }
    else if (password != password2) {
      errors = "Пароли не совпадают";
    }

    if (errors == null) {
      bool secured = false;
      try {
        secured = await this._authenticationService.checkPassSecurity(
            password);
      }
      catch(e) {
        errors = 'Произошла непредвиденная ошибка';
      }

      if (!secured && errors == null) {
        errors = 'Пароль не удовлетворяет требованиям безопасности';
      }
    }

    if (errors == null) {
      _authenticationService.activate(login, password, actHash).then((result) {
        if (result == true) {
          window.alert(
              'Активация произошла успешно!\nВы будете перенаправлены на страницу входа');
          _router.navigateByUrl(_authenticationService.authPath);
        } else {
          errors = 'Ошибка активации';
        }
      }).catchError((e) {
        errors = 'Ошибка при активации';
      });
    }

    if (errors != null) {
      password = null;
      password2 = null;
    }
  }
}
