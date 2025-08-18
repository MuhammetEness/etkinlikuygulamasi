import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/event.dart';
import 'screens/home_page.dart';
import 'screens/search_page.dart';
import 'screens/favorites_page.dart';
import 'screens/notifications_page.dart';
import 'services/event/event_service.dart';
import 'services/category/category_service.dart';
import 'services/notification/notification_service.dart';
import 'utils/cities.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Bildirim servisini başlat
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _loading = true;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;

  List<Event> events = [];
  List<String> cities = [];
  List<String> categories = [];
  Set<Event> favoriteEvents = {};

  int _selectedIndex = 0;
  String? selectedCity;

  /// Sayfaları burada tutuyoruz ki yeniden oluşturulmasın
  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadSelectedCity();
  }

  Future<void> _loadSelectedCity() async {
    final city = await getSelectedCity();
    setState(() {
      selectedCity = city ?? 'Tümü';
    });
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList('favorites') ?? [];
      
      // Favorileri yükle ve günü geçen etkinlikleri temizle
      final currentTime = DateTime.now();
      final validFavorites = <Event>{};
      
      for (final eventId in favoritesJson) {
        try {
          final event = events.firstWhere(
            (e) => e.id.toString() == eventId,
          );
          
          // Etkinlik tarihini kontrol et
          final eventDate = event.date;
          if (eventDate.isAfter(currentTime)) {
            validFavorites.add(event);
          }
        } catch (e) {
          // Event bulunamadı, atla
          continue;
        }
      }
      
      setState(() {
        favoriteEvents.clear();
        favoriteEvents.addAll(validFavorites);
      });
      
      // Temizlenmiş favorileri kaydet
      await _saveFavorites();
    } catch (e) {
      debugPrint('Favoriler yüklenirken hata: $e');
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesList = favoriteEvents.map((e) => e.id.toString()).toList();
      await prefs.setStringList('favorites', favoritesList);
    } catch (e) {
      debugPrint('Favoriler kaydedilirken hata: $e');
    }
  }

  // Etkinlikler yüklendikten sonra favorileri yeniden kur ve geçmiş tarihli olanları sil
  Future<void> _hydrateAndCleanFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesIds = prefs.getStringList('favorites') ?? [];
      final now = DateTime.now();
      final rebuilt = <Event>{};
      for (final id in favoritesIds) {
        final match = events.where((e) => e.id.toString() == id).toList();
        if (match.isNotEmpty && match.first.date.isAfter(now)) {
          rebuilt.add(match.first);
        }
      }
      setState(() {
        favoriteEvents
          ..clear()
          ..addAll(rebuilt);
      });
      await _saveFavorites();
    } catch (e) {
      debugPrint('Favoriler hydrate edilirken hata: $e');
    }
  }

  void _updateSelectedCity(String city) {
    setState(() {
      selectedCity = city;
    });
    saveSelectedCity(city);
  }

  Future<void> _loadData() async {
    try {
      final eventService = EventService();
      final categoryService = CategoryService();

      // API verilerini çek - 200 event çekiyoruz
      final fetchedEvents = await eventService.fetchEvents(take: 200);
      debugPrint('İlk API çağrısından ${fetchedEvents.length} event geldi');
      
      // Eğer 200'den az geldiyse, daha fazla çekmeye çalışalım
      List<Event> allEvents = fetchedEvents;
      if (fetchedEvents.length < 200) {
        debugPrint('200 event gelmedi, daha fazla çekmeye çalışıyoruz...');
        int skip = fetchedEvents.length;
        int attempt = 0;
        while (allEvents.length < 200 && skip < 2000 && attempt < 10) { // Maksimum 10 deneme
          try {
            final moreEvents = await eventService.fetchEvents(take: 100, skip: skip);
            debugPrint('Deneme ${attempt + 1}: ${moreEvents.length} event daha çekildi');
            if (moreEvents.isEmpty) {
              debugPrint('Daha fazla event yok, durduruluyor');
              break;
            }
            allEvents.addAll(moreEvents);
            skip += moreEvents.length;
            attempt++;
          } catch (e) {
            debugPrint('Daha fazla event çekilirken hata: $e');
            break;
          }
        }
      }
      
      debugPrint('Toplam ${allEvents.length} event yüklendi');
      final fetchedCategories = await categoryService.fetchCategories();

      final cityNames = <String>{};
      for (var e in allEvents) {
        final cityName = e.venue?.city?.name ?? '';
        if (cityName.isNotEmpty) {
          cityNames.add(cityName);
        }
      }

      // Sayfaları burada oluşturuyoruz ki bir kere yüklensin
      setState(() {
        events = allEvents;
        categories = ['Bu Hafta', ...fetchedCategories.map((c) => c.name)];
        cities = ['Tümü', ...cityNames];
        _loading = false;
      });

      // Etkinlikler yüklendikten sonra favorileri hydrate et ve geçmişleri temizle
      await _hydrateAndCleanFavorites();
      

    } catch (e) {
      debugPrint('Veri yüklenirken hata oluştu: $e');
      setState(() => _loading = false);
    }
  }

  void toggleFavorite(Event event) {
    setState(() {
      if (favoriteEvents.contains(event)) {
        favoriteEvents.remove(event);
      } else {
        favoriteEvents.add(event);
      }
    });
    
    // Favorileri kaydet
    _saveFavorites();
  }

  Future<void> _loadMoreEvents() async {
    if (_isLoadingMore || !_hasMoreData) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    try {
      final eventService = EventService();
      final moreEvents = await eventService.fetchEvents(take: 50, skip: events.length);
      
      if (moreEvents.isEmpty) {
        setState(() {
          _hasMoreData = false;
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          events.addAll(moreEvents);
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _refreshEvents() async {
    setState(() {
      _loading = true;
    });
    
    await _loadData();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Etkinlik Uygulaması',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: _MainScreen(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        events: events,
        cities: cities,
        categories: categories,
        favoriteEvents: favoriteEvents,
        selectedCity: selectedCity,
        onCityChanged: _updateSelectedCity,
        onToggleFavorite: toggleFavorite,
        onLoadMore: _loadMoreEvents,
        onRefresh: _refreshEvents,
        hasMoreData: _hasMoreData,
        isLoadingMore: _isLoadingMore,
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? badge;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF1C58F2) : Colors.grey;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: selected ? color.withValues(alpha: 0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon, 
                  color: color,
                  size: 20,
                ),
              ),
              if (badge != null && badge! > 0)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      badge.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label, 
            style: TextStyle(
              color: color, 
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _MainScreen extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final List<Event> events;
  final List<String> cities;
  final List<String> categories;
  final Set<Event> favoriteEvents;
  final String? selectedCity;
  final Function(String) onCityChanged;
  final Function(Event) onToggleFavorite;
  final VoidCallback? onLoadMore;
  final VoidCallback? onRefresh;
  final bool hasMoreData;
  final bool isLoadingMore;

  const _MainScreen({
    required this.selectedIndex,
    required this.onItemTapped,
    required this.events,
    required this.cities,
    required this.categories,
    required this.favoriteEvents,
    required this.selectedCity,
    required this.onCityChanged,
    required this.onToggleFavorite,
    this.onLoadMore,
    this.onRefresh,
    this.hasMoreData = false,
    this.isLoadingMore = false,
  });

  @override
  State<_MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<_MainScreen> {
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildCurrentPage(),
          // Yüzen Navigation Bar
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                   color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavBarItem(
                    icon: Icons.home,
                    label: 'Ana Sayfa',
                    selected: widget.selectedIndex == 0,
                    onTap: () => widget.onItemTapped(0),
                  ),
                  _NavBarItem(
                    icon: Icons.search,
                    label: 'Ara',
                    selected: widget.selectedIndex == 1,
                    onTap: () => widget.onItemTapped(1),
                  ),
                  _NavBarItem(
                    icon: Icons.favorite,
                    label: 'Favoriler',
                    selected: widget.selectedIndex == 2,
                    onTap: () => widget.onItemTapped(2),
                  ),
                  StreamBuilder<int>(
                    stream: _notificationService.notificationCountStream,
                    initialData: _notificationService.notificationCount,
                    builder: (context, snapshot) {
                      return _NavBarItem(
                        icon: Icons.notifications,
                        label: 'Bildirimler',
                        selected: widget.selectedIndex == 3,
                        onTap: () => widget.onItemTapped(3),
                        badge: snapshot.data ?? 0,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (widget.selectedIndex) {
      case 0:
        return HomePage(
          events: widget.events,
          cities: widget.cities,
          categories: widget.categories,
          favoriteEvents: widget.favoriteEvents,
          onToggleFavorite: widget.onToggleFavorite,
          selectedCity: widget.selectedCity,
          onCityChanged: widget.onCityChanged,
          onLoadMore: widget.onLoadMore,
          onRefresh: widget.onRefresh,
          hasMoreData: widget.hasMoreData,
          isLoadingMore: widget.isLoadingMore,
        );
      case 1:
        return SearchPage(
          events: widget.events,
          favoriteEvents: widget.favoriteEvents.toList(),
          onToggleFavorite: widget.onToggleFavorite,
          cities: widget.cities,
          selectedCity: widget.selectedCity,
          onCityChanged: widget.onCityChanged,
          onTabChanged: widget.onItemTapped,
        );
      case 2:
        return FavoritesPage(
          favoriteEvents: widget.favoriteEvents.toList(),
          onToggleFavorite: widget.onToggleFavorite,
        );
      case 3:
        return const NotificationsPage();
      default:
        return HomePage(
          events: widget.events,
          cities: widget.cities,
          categories: widget.categories,
          favoriteEvents: widget.favoriteEvents,
          onToggleFavorite: widget.onToggleFavorite,
          selectedCity: widget.selectedCity,
          onCityChanged: widget.onCityChanged,
        );
    }
  }
}
