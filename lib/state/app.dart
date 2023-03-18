import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';

class AppProvider extends ChangeNotifier {
  Map _apps = {};
  List appInstalados = [];
  Map get apps => _apps;

  increment(nome, nomeInstalado) {
    _apps[nome] = {"cor": Colors.red, "instalado": false};
    var cor = getInstalledApps(nome, nomeInstalado);
    notifyListeners();
  }

  Future getInstalledApps(nome, nomeInstalado) async {
    List<Application> apps = await DeviceApps.getInstalledApplications();
    
      for (var e in apps) {
        String nomeAppInstalado = e.appName.toString().toLowerCase();
        if (nomeAppInstalado.length == 0) {
          nomeAppInstalado = "bet loteria";
        } else {
          if (nomeAppInstalado.contains('whatsapp')) {
            nomeAppInstalado = 'whatsapp';
          }
        }
        appInstalados.add(nomeAppInstalado);
      }
    
    // print(appInstalados);
    // print(
    //     "aqui caraio: ${appInstalados.contains(nomeInstalado.toString().toLowerCase())} ${nomeInstalado}");
    if (appInstalados.contains(nomeInstalado.toString().toLowerCase())) {
        _apps[nome] = {"cor": Colors.green, "instalado": true};
    } 
  }
}
