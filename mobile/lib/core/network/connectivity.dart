import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

bool _online(List<ConnectivityResult> results) =>
    results.any((r) => r != ConnectivityResult.none);

/// True while the phone has a connection. Version 1 reads from the last loaded
/// data when this is false and needs a connection to edit (spec 5.1).
final isOnlineProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  yield _online(await connectivity.checkConnectivity());
  yield* connectivity.onConnectivityChanged.map(_online);
});
