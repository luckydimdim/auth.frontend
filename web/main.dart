import 'dart:core';

import 'package:angular2/platform/browser.dart';
import 'package:angular2/core.dart';
import 'package:angular2/router.dart';
import 'package:angular2/platform/common.dart';

import 'package:auth/auth_component.dart';
import 'package:auth/auth_service.dart';
import 'package:alert/alert_service.dart';
import 'package:config/config_service.dart';
import 'package:http/browser_client.dart';
import 'package:http/http.dart';

bool get isDebug =>
    (const String.fromEnvironment('PRODUCTION', defaultValue: 'false')) !=
    'true';

main() async {
  ComponentRef ref = await bootstrap(AuthComponent, [
    ROUTER_PROVIDERS,
    const Provider(LocationStrategy, useClass: HashLocationStrategy),
    const Provider(AuthenticationService),
    const Provider(AlertService),
    const Provider(ConfigService),
    provide(Client, useFactory: () => new BrowserClient(), deps: [])
  ]);

  if (isDebug) {
    print('Application in DebugMode');
    enableDebugTools(ref);
  }
}
