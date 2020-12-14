class Localization {
  String code;
  String name;

  Localization(
    String code,
    String name,
  ) {
    this.code = code;
    this.name = name;
  }

  @override
  String toString() {
    return 'Localization{' + 'code: $code, ' + 'name: $name' + '}';
  }
}
