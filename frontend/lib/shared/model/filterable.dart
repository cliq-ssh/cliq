interface class Filterable {
  /// Gets all the fields that can be filtered on for this entity.
  /// Defaults to an empty list.
  List<String> getFilterableFields() {
    return const [];
  }
}
