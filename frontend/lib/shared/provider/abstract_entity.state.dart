class AbstractEntityState<E, S extends AbstractEntityState<E, S>> {
  final List<E> entities;

  new initial() : entities = [];

  const new({required this.entities});
}
