import 'package:cliq_api/cliq_api.dart';
import 'package:cliq_api/src/api/entities/cliq_entity_impl.dart';

abstract class const CliqEntityImpl(@override final CliqClient api)
    implements CliqEntity;
