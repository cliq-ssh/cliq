import '../../impl/requests/model/route.dart';

class ServerRoutes {
  const ServerRoutes._();

  // might change in the future
  static final Route getHealth = Route(
    'GET',
    '/actuator/health',
    isApiRoute: false,
  );
}

class UserRoutes {
  const UserRoutes._();

  static final Route create = Route.post('/user/register');
}

class SessionRoutes {
  const SessionRoutes._();

  static final Route create = Route.post('/session');
}

class UserConfigRoutes {
  const UserConfigRoutes._();

  static final Route get = Route.get('/user/configuration');
  static final Route update = Route.put('/user/configuration');
  static final Route getLastUpdated = Route.get(
    '/user/configuration/last-updated',
  );
}
