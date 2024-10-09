class DayNoFileSelectedException implements Exception {}

class RemoteErrorException implements Exception {
  final Error error;

  RemoteErrorException({required this.error});
}
