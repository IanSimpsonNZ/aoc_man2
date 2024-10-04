class OutputList {
  // Make this a singleton
  OutputList._privateContructor();
  static final OutputList _instance = OutputList._privateContructor();
  factory OutputList() {
    return _instance;
  }

  List<String> lines = [];
}
