import 'package:flutter/material.dart';

/// Şehre göre renk ve ikon döndüren dinamik sistem.
/// Anahtar kelime bazlı çalışır, böylece API'den farklı formatta gelse bile eşleşir.
Map<String, dynamic> getCityStyle(String cityName) {
  String name = cityName.toLowerCase();

  if (name.contains("istanbul")) {
    return {"color": Colors.blueGrey, "icon": Icons.location_city};
  } else if (name.contains("ankara")) {
    return {"color": Colors.deepPurple, "icon": Icons.account_balance};
  } else if (name.contains("izmir")) {
    return {"color": Colors.orange, "icon": Icons.beach_access};
  } else if (name.contains("antalya")) {
    return {"color": Colors.cyan, "icon": Icons.beach_access};
  } else if (name.contains("bursa")) {
    return {"color": Colors.green, "icon": Icons.park};
  } else if (name.contains("adana")) {
    return {"color": Colors.red, "icon": Icons.local_fire_department};
  } else if (name.contains("eskişehir")) {
    return {"color": Colors.amber, "icon": Icons.train};
  } else {
    // Default renk ve ikon
    return {"color": Colors.grey, "icon": Icons.location_on};
  }
}
