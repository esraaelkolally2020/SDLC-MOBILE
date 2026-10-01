/// Web stand-ins. Real network errors on web are surfaced as [DioException]s,
/// never these types, so these patterns simply never match on web.
class SocketException implements Exception {
  const SocketException();
}

class HandshakeException implements Exception {
  const HandshakeException();
}
