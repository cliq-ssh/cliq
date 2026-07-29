import '../../impl/requests/model/route.dart';

class VaultRoutes {
  const VaultRoutes._();

  static const get = Route(.get, '/api/vault');
  static const put = Route(.put, '/api/vault');
  static const getLastUpdated = Route(.get, '/api/vault/last-updated');
}

class UserRoutes {
  const UserRoutes._();

  static const postVerification = Route(.post, '/api/user/verification');
  static const postResendEmail = Route(
    .post,
    '/api/user/verification/resend-email',
  );
  static const postKeyRotationVerify = Route(
    .post,
    '/api/user/key-rotation/verify',
  );
  static const postKeyRotationStart = Route(
    .post,
    '/api/user/key-rotation/start',
  );
  static const getMe = Route(.get, '/api/user/me');
}

class AuthenticationRoutes {
  const AuthenticationRoutes._();

  // TODO: implement OIDC + routes

  static const postRegister = Route(.post, '/api/auth/register');
  static const postRefresh = Route(.post, '/api/auth/refresh');
  static const postLogout = Route(.post, '/api/auth/logout');
  static const postLoginStart = Route(.post, '/api/auth/login/start');
  static const postLoginFinish = Route(.post, '/api/auth/login/finish');
  static const postDeviceRegister = Route(.post, '/api/auth/device/register');
}

class ServerConfigurationRoutes {
  const ServerConfigurationRoutes._();

  static const get = Route(.get, '/api/server/configuration');
}

class SessionRoutes {
  const SessionRoutes._();

  static const getCurrent = Route(.get, '/api/session/current');
}

class ActuatorRoutes {
  const ActuatorRoutes._();

  static const get = Route(.get, '/actuator');
  static const getHealth = Route(.get, '/actuator/health');
}
