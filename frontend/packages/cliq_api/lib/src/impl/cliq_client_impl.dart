import 'package:cliq_api/cliq_api.dart';
import 'package:cliq_api/src/impl/requests/request_handler.dart';
import 'package:cliq_api/src/impl/utils/encryption_helper.dart';

import 'entity_builder.dart';

class CliqClientImpl implements CliqClient {
  @override
  RouteOptions routeOptions = RouteOptions();

  late final RequestHandler requestHandler = RequestHandler(this);
  late final EntityBuilder entityBuilder = EntityBuilder(api: this);

  @override
  late final User selfUser;

  final EncryptionHelper encryptionHelper = EncryptionHelper();
}
