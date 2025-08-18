import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Chrome/varsayılan tarayıcı ile URL açma helper
Future<void> openUrl(String url) async {
  try {
    final Uri? uri = Uri.tryParse(Uri.encodeFull(url));

    if (uri == null) {
      debugPrint("❌ Geçersiz URL: $url");
      return;
    }

    // Önce tarayıcıda açmayı dene
    if (await canLaunchUrl(uri)) {
      final success = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!success) {
        // Tarayıcı yoksa uygulama içinde aç
        await launchUrl(uri, mode: LaunchMode.inAppWebView);
      }
    } else {
      debugPrint("❌ URL açılamadı: $url");
    }
  } catch (e) {
    debugPrint("❌ URL açılırken hata: $e");
  }
}
