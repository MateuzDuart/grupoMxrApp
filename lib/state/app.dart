import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';

class AppProvider extends ChangeNotifier {
  Map _apps = {};
  List appInstalados = [];
  Map get apps => _apps;

  void increment(nome) {
    _apps[nome] = {"cor": Colors.red, "instalado": false};
    notifyListeners();
    getInstalledApps(nome);
  }

  Future<void> getInstalledApps(nome) async {
    List<Application> apps = await DeviceApps.getInstalledApplications();
    if (apps.length != appInstalados.length) {
      apps.forEach((e) {
        appInstalados.add(e.toString().toLowerCase());
      });
    }

    apps.forEach((e) {
      print("${e.appName} ${nome}");
      if (nome
          .toString()
          .toLowerCase()
          .contains(e.appName.toString().toLowerCase())) {
        _apps[nome] = {"cor": Colors.green, "instalado": true};
      }
      ;
    });
  }
}
