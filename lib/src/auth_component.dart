import 'package:angular2/core.dart';
import 'package:angular2/router.dart';


import 'loginModel.dart';
import 'auth_service.dart';

import 'package:alert/alert_service.dart';

@Component(
    selector: 'auth',
    templateUrl: 'auth_component.html',
    styleUrls: const <String>['auth_component.css'])
class AuthComponent implements OnInit {

  static const String route_name = "Auth";
  static const String route_path = "auth";
  static const Route route = const Route(
      path: AuthComponent.route_path,
      component: AuthComponent,
      name: AuthComponent.route_name
  );

  LoginModel model;
  final Router _router;
  final AlertService _alertService;
  final AuthenticationService _authenticationService;

  AuthComponent(this._router, this._alertService, this._authenticationService) {
    model = new LoginModel();
  }

  @Output()
  final onAuth = new EventEmitter<bool>();

  @override
  void ngOnInit() {

  }

  onSubmit() {

    _authenticationService.login(model.login, model.password).then((result){
      if (result == true) {


        var queryUrl = Uri.base.queryParameters['url'];

        if (queryUrl != '' && queryUrl != null)
          _router.navigate([queryUrl]);
        else
          _router.navigate(['Master/Dashboard']);
      }
      else {
        _alertService.Warning('Ошибка при входе. Логин или пароль не существуют');
      }

      onAuth.emit(result);

    }).catchError((e){
      _alertService.Danger('Непредвиденная ошибка');
      print('Непредвиденная ошибка: ${e.toString()}');
    });


  }

}