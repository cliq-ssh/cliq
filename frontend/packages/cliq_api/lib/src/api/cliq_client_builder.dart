import 'dart:convert';
import 'dart:typed_data';

import 'package:cliq_api/cliq_api.dart';
import 'package:cliq_api/src/impl/requests/request_handler.dart';
import 'package:cliq_api/src/impl/responses/login_finish_response.dart';
import 'package:cliq_api/src/impl/responses/login_start_response.dart';
import 'package:cliq_api/src/impl/responses/token_response.dart';
import 'package:logging/logging.dart';
import 'package:dsrp/dsrp.dart' as dsrp;

import '../impl/cliq_client_impl.dart';
import '../impl/utils/encryption_helper.dart';
import '../impl/utils/string_utils.dart';

class CliqClientBuilder {
  static final Logger _log = Logger('CliqClientBuilder');

  final RouteOptions routeOptions;

  CliqClientBuilder({required this.routeOptions});

  CliqClientImpl buildApiImpl() =>
      CliqClientImpl()..routeOptions = routeOptions;

  Future<CliqClient> login({
    required String email,
    required Uint8List password,
    required String sessionName,
    Function(String, String)? onJwtTokenReceived,
    Function(Uint8List)? onDevicePrivateKeyGenerated,
    Function(Uint8List)? onDataEncryptionKeyDecrypted,
  }) async {
    // check if the URI is valid and the API is healthy
    final String status = await CliqClient.retrieveHealthStatus(routeOptions);
    _log.config(
      'Successfully connected to: ${routeOptions.hostUri}, status: $status',
    );

    final apiImpl = buildApiImpl();

    // initialize the login process by requesting the server for a challenge
    final startResponse = await RequestHandler.request<LoginStartResponse>(
      route: AuthenticationRoutes.postLoginStart.compile(),
      routeOptions: routeOptions,
      mapper: (data) => LoginStartResponse.fromJson(data),
      body: {'email': email},
    );

    if (startResponse.hasError) {
      throw startResponse.error!;
    }
    final start = startResponse.data!;

    final challenge = dsrp.Challenge.fromServer(
      generator: BigInt.two,
      safePrime: srpSafePrime2048,
      ephemeralServerPublicKey: StringUtils.hexToArray(start.publicB),
      verifierKeySalt: StringUtils.hexToArray(start.salt),
      hashFunctionChoice: dsrp.HashFunctionChoice.sha512,
    );

    // create a new SRP user with the provided credentials and the challenge received from the server
    final srpUser = await dsrp.User.fromUserCredsBytesAndChallenge(
      userIdBytes: utf8.encode(email),
      passwordBytes: password,
      challenge: challenge,
      useUserIdInPrivateKey: true,
    );

    // get the verifiers needed to complete the login process
    final verifiers = srpUser.getUserSessionVerifiers();

    // send the verifiers to the server to complete the login process and receive the final response
    final finishResponse = await RequestHandler.request<LoginFinishResponse>(
      route: AuthenticationRoutes.postLoginFinish.compile(),
      routeOptions: routeOptions,
      mapper: (data) => LoginFinishResponse.fromJson(data),
      body: {
        'authenticationSessionToken': start.authenticationSessionToken,
        'publicA': StringUtils.arrayToHex(verifiers.ephemeralUserPublicKey),
        'publicM1': StringUtils.arrayToHex(verifiers.sessionKeyVerifier),
      },
    );
    if (finishResponse.hasError) {
      throw finishResponse.error!;
    }
    final finish = finishResponse.data!;

    // verify the session with the server using the final response received
    await srpUser.verifySession(StringUtils.hexToArray(finish.publicM2));

    final umk = await apiImpl.encryptionHelper.generateUserMasterKey(
      password,
      StringUtils.hexToArray(start.salt),
    );

    // get the Data Encryption Key (DEK) by decrypting the wrapped DEK received from the server using our
    // User Master Key (UMK)
    final dek = await apiImpl.encryptionHelper.decryptDataWithKey(
      base64Decode(finish.dataEncryptionKeyUmkWrapped),
      umk,
    );
    onDataEncryptionKeyDecrypted?.call(dek);
    umk.overwriteWithZeros();

    final (devicePublicKey, devicePrivateKey) = await apiImpl.encryptionHelper
        .generateX25519KeyPair();
    onDevicePrivateKeyGenerated?.call(devicePrivateKey);

    // Encrypt the DEK with the device's public key to securely store it on the server
    final encryptedDekWithDeviceKeyPair = await apiImpl.encryptionHelper
        .encryptDataEncryptionKeyWithDeviceEncryptionKeyPair(dek, (
          devicePublicKey,
          devicePrivateKey,
        ));

    final deviceRegistrationResponse =
        await RequestHandler.request<TokenResponse>(
          route: AuthenticationRoutes.postDeviceRegister.compile(),
          routeOptions: routeOptions,
          mapper: (data) => .fromJson(data),
          body: {
            'exchangeCode': finish.authExchangeCode,
            'devicePublicKey': base64Encode(devicePublicKey),
            'dataEncryptionKey': base64Encode(encryptedDekWithDeviceKeyPair),
            'sessionName': sessionName,
          },
        );
    if (deviceRegistrationResponse.hasError) {
      throw deviceRegistrationResponse.error!;
    }
    final tokens = deviceRegistrationResponse.data!;
    onJwtTokenReceived?.call(tokens.accessToken, tokens.refreshToken);

    apiImpl.selfUser =
        await RequestHandler.request(
          route: UserRoutes.getMe.compile(),
          bearerToken: tokens.accessToken,
          routeOptions: routeOptions,
          mapper: (data) => apiImpl.entityBuilder.buildUser(data),
        ).then((response) {
          if (response.hasError) {
            throw response.error!;
          }
          return response.data!;
        });

    return apiImpl;
  }

  Future<User> createUser({
    required String email,
    required String username,
    required Uint8List password,
    String locale = 'en',
  }) async {
    final apiImpl = buildApiImpl();
    final salt = apiImpl.encryptionHelper.generateSalt(16);

    final verificationKey =
        await dsrp.User.createSaltedVerificationKeyFromBytes(
          userIdBytes: utf8.encode(email),
          passwordBytes: password,
          salt: salt,
          generator: .two,
          safePrime: srpSafePrime2048,
        );

    final umk = await apiImpl.encryptionHelper.generateUserMasterKey(
      password,
      salt,
    );
    final dek = apiImpl.encryptionHelper.generateDataEncryptionKey();

    final encryptedDek = await apiImpl.encryptionHelper.encryptDataWithKey(
      dek,
      umk,
    );
    umk.overwriteWithZeros();

    return RequestHandler.request(
      route: AuthenticationRoutes.postRegister.compile(),
      routeOptions: routeOptions,
      body: {
        'email': email,
        'username': username,
        'dataEncryptionKey': base64Encode(encryptedDek),
        'srpSalt': StringUtils.arrayToHex(verificationKey.salt),
        'srpVerifier': StringUtils.arrayToHex(verificationKey.key),
        'locale': locale,
      },
      mapper: (data) => apiImpl.entityBuilder.buildUser(data),
    ).then((response) {
      if (response.hasError) {
        print('Error creating user: ${response.error}');
        throw response.error!;
      }
      return response.data!;
    });
  }

  Future<User> verifyEmail({
    required String email,
    required String verificationToken,
  }) {
    return RequestHandler.request(
      route: UserRoutes.postVerification.compile(),
      routeOptions: routeOptions,
      body: {'email': email, 'verificationToken': verificationToken},
      mapper: (data) => buildApiImpl().entityBuilder.buildUser(data),
    ).then((response) {
      if (response.hasError) {
        throw response.error!;
      }
      return response.data!;
    });
  }

  Future<bool> resendVerificationEmail({required String email}) {
    return RequestHandler.noResponseRequest(
      route: UserRoutes.postResendEmail.compile(),
      routeOptions: routeOptions,
      body: {'email': email},
    ).then((response) {
      if (response.hasError) {
        throw response.error!;
      }
      return response.data!;
    });
  }
}
