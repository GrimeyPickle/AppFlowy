import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flowy_sdk/log.dart';
import 'package:flowy_sdk/dispatch/dispatch.dart';
import 'package:flowy_sdk/protobuf/flowy-net/network_state.pb.dart';
import 'package:flutter/services.dart';

class NetworkListener {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  NetworkListener() {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> start() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      Log.error('Couldn\'t check connectivity status. $e');
      return;
    }
    return _updateConnectionStatus(result);
  }

  void stop() {
    _connectivitySubscription.cancel();
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    final networkType = () {
      switch (result) {
        case ConnectivityResult.wifi:
          return NetworkType.Wifi;
        case ConnectivityResult.ethernet:
          return NetworkType.Ethernet;
        case ConnectivityResult.mobile:
          return NetworkType.Cell;
        case ConnectivityResult.bluetooth:
          return NetworkType.Bluetooth;
        case ConnectivityResult.vpn:
          return NetworkType.VPN;
        case ConnectivityResult.none:
          return NetworkType.UnknownNetworkType;
      }
    }();
    Log.info("Network type: $networkType");
    final state = NetworkState.create()..ty = networkType;
    NetworkEventUpdateNetworkType(state).send().then((result) {
      result.fold(
        (l) {},
        (e) => Log.error(e),
      );
    });
  }
}
