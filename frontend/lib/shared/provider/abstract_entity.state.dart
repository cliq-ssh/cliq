class AbstractEntityState<E> {
  final List<E> entities;

  AbstractEntityState.initial() : entities = [];

  const AbstractEntityState({required this.entities});

  AbstractEntityState<E> copyWith({List<E>? entities}) {
    return AbstractEntityState<E>(entities: entities ?? this.entities);
  }
}
