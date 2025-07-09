import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Service for managing network connectivity status
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // Current connectivity status
  bool _isOnline = true;

  /// Get current connectivity status
  bool get isOnline => _isOnline;

  /// Get current connectivity status (alias)
  bool get isConnected => _isOnline;

  /// Get current offline status
  bool get isOffline => !_isOnline;

  /// Stream controller for connectivity status changes
  final StreamController<bool> _connectivityController = StreamController<bool>.broadcast();

  /// Stream of connectivity status changes
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Initialize the connectivity service
  Future<void> initialize() async {
    try {
      // Check initial connectivity status
      await _updateConnectivityStatus();

      // Listen to connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _onConnectivityChanged,
        onError: (error) {
          // On error, assume offline to be safe
          _updateStatus(false);
        },
      );
    } catch (e) {
      // If there's an error initializing, assume offline
      _updateStatus(false);
    }
  }

  /// Handle connectivity changes
  void _onConnectivityChanged(List<ConnectivityResult> results) {
    _updateConnectivityStatus();
  }

  /// Update connectivity status based on current connection
  Future<void> _updateConnectivityStatus() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      final hasConnection = _hasActiveConnection(connectivityResults);
      _updateStatus(hasConnection);
    } catch (e) {
      // On error, assume offline
      _updateStatus(false);
    }
  }

  /// Check if any of the connectivity results indicate an active connection
  bool _hasActiveConnection(List<ConnectivityResult> results) {
    return results.any(
      (result) =>
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet ||
          result == ConnectivityResult.vpn,
    );
  }

  /// Update the connectivity status and notify listeners
  void _updateStatus(bool isOnline) {
    if (_isOnline != isOnline) {
      _isOnline = isOnline;
      _connectivityController.add(_isOnline);
    }
  }

  /// Manually check connectivity status
  Future<bool> checkConnectivity() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      final hasConnection = _hasActiveConnection(connectivityResults);
      _updateStatus(hasConnection);
      return hasConnection;
    } catch (e) {
      _updateStatus(false);
      return false;
    }
  }

  /// Wait for connection to be available
  Future<bool> waitForConnection({Duration timeout = const Duration(seconds: 10)}) async {
    if (_isOnline) {
      return true;
    }

    try {
      final result = await connectivityStream.where((isOnline) => isOnline).timeout(timeout).first;
      return result;
    } catch (e) {
      return false;
    }
  }

  /// Get detailed connectivity information
  Future<Map<String, dynamic>> getConnectivityInfo() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();

      return {
        'isOnline': _isOnline,
        'connectivityResults': connectivityResults.map((e) => e.name).toList(),
        'hasMultipleConnections': connectivityResults.length > 1,
        'primaryConnection': connectivityResults.isNotEmpty ? connectivityResults.first.name : 'none',
      };
    } catch (e) {
      return {'isOnline': false, 'error': e.toString()};
    }
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityController.close();
  }
}
