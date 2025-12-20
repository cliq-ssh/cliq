import 'package:cliq_api/cliq_api.dart';
import 'package:cliq_api/src/api/entities/cliq_entity_impl.dart';

abstract class CliqEntityImpl implements CliqEntity {
  @override
  final CliqClient api;

  const CliqEntityImpl(this.api);
}
