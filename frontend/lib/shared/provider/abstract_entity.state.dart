class AbstractEntityState<E, S extends AbstractEntityState<E, S>> {
  final List<E> entities;

  AbstractEntityState.initial() : entities = [];

  const AbstractEntityState({required this.entities});
}
