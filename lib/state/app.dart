import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';

class AppProvider extends ChangeNotifier {
  Map _apps = {};
  List appInstalados = [];
  Map get apps => _apps;

  increment(nome, nomeInstalado) async {
    var cor = await getInstalledApps(nome, nomeInstalado);
    _apps[nome] = {"cor": cor, "instalado": true};
    notifyListeners();
  }

  Future getInstalledApps(nome, nomeInstalado) async {
    List<Application> apps = await DeviceApps.getInstalledApplications();
    if (apps.length != appInstalados.length) {
      apps.forEach((e) {
        appInstalados.add(e.appName.toString().toLowerCase().length == 0
            ? "bet loteria"
            : e.appName.toString().toLowerCase());
      });
    }
    print(appInstalados);
    print(
        "aqui caraio: ${appInstalados.contains(nomeInstalado.toString().toLowerCase())} ${nomeInstalado}");
    if (appInstalados.contains(nomeInstalado.toString().toLowerCase())) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }
}
