import 'package:flutter/material.dart';

// Score-based single-category classifier
// We compute scores per category from include/strong/exclude keyword sets
// on the provided text (category name + title). Highest score wins.
Map<String, dynamic> getCategoryStyle(String categoryNameAndTitle) {
  final String text = categoryNameAndTitle.toLowerCase();

  int score(List<String> inc, List<String> strong, List<String> exc) {
    int s = 0;
    for (final k in inc) {
      if (text.contains(k)) s += 1;
    }
    for (final k in strong) {
      if (text.contains(k)) s += 3;
    }
    for (final k in exc) {
      if (text.contains(k)) s -= 2;
    }
    return s;
  }

  final int sCocuk = score(
    [
      'çocuk', 'bebek', 'genç', 'aile',
      'çocuk atölyesi', 'çocuk etkinliği', 'çocuk oyunu', 'çocuk tiyatrosu', 'çocuk konseri',
      'yaş', '5-7', '6-8', '7-9', '8-10', '9-11', '10-12', '12-14', '14-16', '16-18'
    ],
    ['çocuk tiyatrosu', 'çocuk atölyesi', 'çocuk konseri', 'yaş', 'çocuk'],
    [],
  );

  final int sMuzik = score(
    [
      'müzik', 'konser', 'şarkı', 'caz', 'rock', 'pop', 'festival', 'orkestra', 'dj',
      'müzik grubu', 'şarkıcı', 'türk sanat', 'halk müziği', 'live', 'canlı', 'performans',
      'şarkıcı', 'solist', 'vokal', 'gitar', 'piyano', 'keman', 'flüt', 'saksafon',
      'jazz', 'blues', 'folk', 'klasik', 'elektronik', 'hip hop', 'rap', 'reggae'
    ],
    ['türk sanat', 'halk müziği', 'müzik', 'konser', 'live', 'canlı'],
    ['çocuk'],
  );

  final int sTiyatro = score(
    ['tiyatro', 'gösteri', 'drama', 'oyun', 'piyes', 'sahne', 'oyuncu'],
    ['tiyatro', 'gösteri'],
    ['çocuk'],
  );

  final int sSinema = score(
    ['sinema', 'film', 'belgesel', 'vizyon', 'gala', 'premiyer'],
    ['sinema', 'film'],
    ['çocuk'],
  );

  final int sSpor = score(
    ['spor', 'futbol', 'basketbol', 'koşu', 'voleybol', 'tenis', 'yüzme', 'maraton'],
    ['spor'],
    ['çocuk'],
  );

  final int sSanat = score(
    ['sanat', 'resim', 'fotoğraf', 'heykel', 'sergi', 'galeri', 'illüstrasyon', 'çizim', 'seramik', 'karikatür'],
    ['sanat', 'sergi'],
    ['türk sanat', 'çocuk'],
  );

  final int sEgitim = score(
    [
      'atölye', 'workshop', 'eğitim', 'kurs', 'seminer', 'konferans', 'panel', 'sertifika', 'buluşma',
      'masterclass', 'ustalık', 'aşçılık', 'mutfak', 'yemek', 'aşçılık ve mutfak'
    ],
    ['workshop', 'masterclass', 'atölye', 'eğitim', 'kurs'],
    ['çocuk'],
  );

  final int sAcikHava = score(
    ['açık hava', 'doğa', 'kamp', 'yürüyüş', 'outdoor', 'dağcılık', 'trekking', 'piknik', 'bisiklet'],
    ['açık hava', 'doğa'],
    ['çocuk'],
  );

  final Map<String, int> scores = {
    'Çocuk': sCocuk,
    'Müzik': sMuzik,
    'Tiyatro': sTiyatro,
    'Sinema': sSinema,
    'Spor': sSpor,
    'Sanat': sSanat,
    'Eğitim': sEgitim,
    'Açık Hava': sAcikHava,
  };

  // Pick the category with max score; if all <= 0, return Diğer
  String best = 'Diğer';
  int bestScore = 0;
  scores.forEach((k, v) {
    if (v > bestScore) {
      best = k;
      bestScore = v;
    }
  });

  switch (best) {
    case 'Çocuk':
      return {
        'title': 'Çocuk',
        'color': Colors.purple,
        'icon': Icons.child_care,
        'image': 'assets/images/categories/kids.jpg',
      };
    case 'Müzik':
      return {
        'title': 'Müzik',
        'color': Colors.pink,
        'icon': Icons.music_note,
        'image': 'assets/images/categories/music.jpg',
      };
    case 'Tiyatro':
      return {
        'title': 'Tiyatro',
        'color': Colors.orange,
        'icon': Icons.theater_comedy,
        'image': 'assets/images/categories/tiyatro.jpg',
      };
    case 'Sinema':
      return {
        'title': 'Sinema',
        'color': Colors.blue,
        'icon': Icons.movie,
        'image': 'assets/images/categories/cinema.jpg',
      };
    case 'Spor':
      return {
        'title': 'Spor',
        'color': Colors.green,
        'icon': Icons.sports_soccer,
        'image': 'assets/images/categories/spor.jpg',
      };
    case 'Sanat':
      return {
        'title': 'Sanat',
        'color': Colors.deepPurple,
        'icon': Icons.brush,
        'image': 'assets/images/categories/sanat.png',
      };
    case 'Eğitim':
      return {
        'title': 'Eğitim',
        'color': Colors.teal,
        'icon': Icons.school,
        'image': 'assets/images/categories/egitim.png',
      };
    case 'Açık Hava':
      return {
        'title': 'Açık Hava',
        'color': Colors.lightBlue,
        'icon': Icons.park,
        'image': 'assets/images/categories/acikhava.jpg',
      };
    default:
      return {
        'title': 'Diğer',
        'color': Colors.grey,
        'icon': Icons.category,
        'image': 'assets/images/categories/diger.png',
      };
  }
}
