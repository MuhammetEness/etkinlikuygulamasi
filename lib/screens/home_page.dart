import 'package:flutter/material.dart';
import '../models/event.dart';
import '../utils/filter_utils.dart';
import '../widgets/event_card.dart';
import '../utils/category_style_utils.dart';
import '../utils/city_style_utils.dart';
import '../repository/city_repository.dart';
import '../services/notification/notification_service.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../services/event/event_service.dart'; // Fixed import path

class HomePage extends StatefulWidget {
  final List<Event> events;
  final List<String> cities;
  final List<String> categories;
  final Set<Event> favoriteEvents;
  final Function(Event) onToggleFavorite;
  final String? selectedCity;
  final Function(String) onCityChanged;
  final VoidCallback? onLoadMore; // Pagination için
  final VoidCallback? onRefresh; // Pull-to-refresh için
  final bool hasMoreData; // Daha fazla veri var mı
  final bool isLoadingMore; // Yükleme durumu

  const HomePage({
    super.key,
    required this.events,
    required this.cities,
    required this.categories,
    required this.favoriteEvents,
    required this.onToggleFavorite,
    required this.selectedCity,
    required this.onCityChanged,
    this.onLoadMore,
    this.onRefresh,
    this.hasMoreData = false,
    this.isLoadingMore = false,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _selectedCategory;
  String _citySearchQuery = '';
  List<String> _filteredCities = [];

  @override
  void initState() {
    super.initState();
    _loadCities();
    _filteredCities = widget.cities;
  }

  Future<void> _loadCities() async {
    try {
      final repo = CityRepository();
      final allCities = await repo.getCities();

      setState(() {
        widget.cities
          ..clear()
          ..addAll(allCities);
        // _selectedCity = widget.cities.isNotEmpty ? widget.cities.first : null; // This line is removed as per the new_code
      });
    } catch (e) {
      debugPrint('Şehirler yüklenemedi: $e');
    }
  }

  void _filterCities(String query) {
    setState(() {
      _citySearchQuery = query;
      _filteredCities = widget.cities
          .where((city) => city.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  List<Event> _filterByCityAndCategory(List<Event> events) {
    var filtered = widget.selectedCity != null && widget.selectedCity != "Tümü"
        ? filterByCity(events, widget.selectedCity!)
        : events;

    if (_selectedCategory == "Bu Hafta") {
      filtered = filterThisWeek(filtered);
    } else if (_selectedCategory != null) {
      filtered = filtered.where((event) {
        final catName = '${event.category?.name ?? ''} ${event.title}';
        final style = getCategoryStyle(catName);
        return style["title"] == _selectedCategory;
      }).toList();
    }
    return filtered;
  }

  List<String> _getMainCategoriesForCity() {
    final filteredByCity = widget.selectedCity != null && widget.selectedCity != "Tümü"
        ? filterByCity(widget.events, widget.selectedCity!)
        : widget.events;

    final Set<String> mainCats = {};
    for (var event in filteredByCity) {
      final style = getCategoryStyle('${event.category?.name ?? ''} ${event.title}');
      mainCats.add(style["title"]);
    }

    List<String> sortedList = mainCats.toList();
    if (sortedList.contains("Diğer")) {
      sortedList.remove("Diğer");
      sortedList.add("Diğer");
    }

    return sortedList;
  }

    Map<String, int> _getCategoryEventCounts() {
    final filteredByCity = widget.selectedCity != null && widget.selectedCity != "Tümü"
        ? filterByCity(widget.events, widget.selectedCity!)
        : widget.events;

    final Map<String, int> categoryCounts = {};
    
    for (var event in filteredByCity) {
      final originalCategory = '${event.category?.name ?? ''} ${event.title}';
      final style = getCategoryStyle(originalCategory);
      final categoryTitle = style["title"];
      categoryCounts[categoryTitle] = (categoryCounts[categoryTitle] ?? 0) + 1;
    }

    return categoryCounts;
  }

  @override
  Widget build(BuildContext context) {
    final filteredEvents = _filterByCityAndCategory(widget.events);
    final mainCategories = _getMainCategoriesForCity();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCategoryButtons(mainCategories),
            Expanded(
              child: _selectedCategory == null
                  ? _buildAllCategorySections(mainCategories, filteredEvents)
                  : _buildSingleCategoryList(filteredEvents),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final cityStyle = widget.selectedCity != null ? getCityStyle(widget.selectedCity!) : null;
    final cityIcon = cityStyle != null ? cityStyle["icon"] as IconData : Icons.location_city;

    return Container(
      color: const Color(0xFFF7F9FC),
      padding: const EdgeInsets.only(
        left: 16, 
        right: 16, 
        top: 8, // Üst padding'i azalttım
        bottom: 16, // Alt padding'i de azalttım
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Şehir seçme DropdownSearch - üstteki yazıyla çakışmaması için padding ayarlandı
          Center(
            child: SizedBox(
              width: 260,
              child: DropdownSearch<String>(
                items: widget.cities,
                selectedItem: widget.selectedCity,
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Şehir seç...",
                    labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Padding'i azalttım
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      hintText: "Şehir ara...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey[100],
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    ),
                  ),
                  itemBuilder: (context, city, isSelected) {
                    return ListTile(
                      title: Text(city),
                      leading: isSelected
                        ? Icon(getCityStyle(city)["icon"] as IconData, color: Colors.black)
                        : null,
                    );
                  },
                ),
                onChanged: (value) {
                  if (value != null) widget.onCityChanged(value);
                },
                dropdownBuilder: (context, selectedItem) {
                  if (selectedItem == null) return const Text('Şehir seç...', style: TextStyle(color: Colors.grey));
                  return Row(
                    children: [
                      Icon(getCityStyle(selectedItem)["icon"] as IconData, color: Colors.black),
                      const SizedBox(width: 8),
                      Text(selectedItem, style: const TextStyle(fontSize: 16)),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButtons(List<String> mainCategories) {
    final categoryCounts = _getCategoryEventCounts();
    
    return Container(
      color: const Color(0xFFF7F9FC), // Ton farkını düzeltmek için aynı renk
      child: SizedBox(
        height: 65,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: mainCategories.length,
          itemBuilder: (ctx, i) {
            final cat = mainCategories[i];
            final sel = _selectedCategory == cat;
            final style = getCategoryStyle(cat);
            final color = style["color"] as Color;
            final icon = style["icon"] as IconData;
            final eventCount = categoryCounts[cat] ?? 0;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (_selectedCategory == cat) {
                      _selectedCategory = null;
                    } else {
                      _selectedCategory = cat;
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? color : color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Icon(icon, color: sel ? Colors.white : color, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        '$cat (${eventCount})',
                        style: TextStyle(
                          color: sel ? Colors.white : color,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAllCategorySections(
      List<String> mainCategories, List<Event> allEvents) {
    return RefreshIndicator(
      onRefresh: () async {
        // Pull-to-refresh için sayfa yenileme
        if (widget.onRefresh != null) {
          widget.onRefresh!();
        }
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          final bool atEnd = scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 50;
          final bool isPullUp = scrollInfo is OverscrollNotification && scrollInfo.overscroll > 0;
          if ((atEnd || isPullUp) && widget.hasMoreData && !widget.isLoadingMore && widget.onLoadMore != null) {
            widget.onLoadMore!();
          }
          return false;
        },
        child: ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 80),
          children: [
            ...mainCategories.map((mainCat) {
            final style = getCategoryStyle(mainCat);
            final color = style["color"] as Color;

            final eventsForMainCat = allEvents.where((event) {
              final mappedCat =
                  getCategoryStyle('${event.category?.name ?? ''} ${event.title}')["title"];
              return mappedCat == mainCat;
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(mainCat,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: color,
                          )),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => _CategoryAllEventsPage(
                                category: mainCat,
                                events: allEvents,
                                favoriteEvents: widget.favoriteEvents,
                                onToggleFavorite: widget.onToggleFavorite,
                                selectedCity: widget.selectedCity,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          "Tümünü Gör",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 180,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      final bool atEnd = scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 24;
                      final bool isPullForward = scrollInfo is OverscrollNotification && scrollInfo.overscroll > 0;
                      if ((atEnd || isPullForward) && widget.hasMoreData && !widget.isLoadingMore && widget.onLoadMore != null) {
                        widget.onLoadMore!();
                      }
                      return false;
                    },
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      itemCount: eventsForMainCat.length + (widget.isLoadingMore ? 1 : 0),
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        if (index == eventsForMainCat.length && widget.isLoadingMore) {
                          return Container(
                            width: 100,
                            height: 160,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        final e = eventsForMainCat[index];
                        return EventCard(
                          key: ValueKey(e.id),
                          event: e,
                          isFavorite: widget.favoriteEvents.contains(e),
                          onToggleFavorite: widget.onToggleFavorite,
                        );
                      },
                    ),
                  ),
                )
              ],
            );
          }),
          // Pagination loading indicator
          if (widget.isLoadingMore)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),

        ],
      ),
      ),
    );
  }

  Widget _buildSingleCategoryList(List<Event> events) {
    if (events.isEmpty) {
      return const Center(child: Text("Etkinlik bulunamadı"));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final e = events[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: EventCard(
            event: e,
            isFavorite: widget.favoriteEvents.contains(e),
            onToggleFavorite: widget.onToggleFavorite,
          ),
        );
      },
    );
  }

  void _showCitySelector() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        String modalQuery = '';
        List<String> modalFilteredCities = widget.cities;
        return StatefulBuilder(
          builder: (context, setModalState) {
            final showList = modalFilteredCities.isNotEmpty ? modalFilteredCities : widget.cities;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Şehir ara...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey[100],
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    ),
                    onChanged: (value) {
                      setModalState(() {
                        modalQuery = value;
                        modalFilteredCities = widget.cities
                            .where((city) => city.toLowerCase().contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: showList.map((city) {
                      return ListTile(
                        title: Text(city),
                        onTap: () {
                          widget.onCityChanged(city);
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// Yeni sayfa: Tümünü Gör ile açılan kategoriye ait etkinliklerin alt alta listelendiği, beyaz AppBar ve siyah yazı/ikonlar
class _CategoryAllEventsPage extends StatefulWidget {
  final String category;
  final List<Event> events;
  final Set<Event> favoriteEvents;
  final Function(Event) onToggleFavorite;
  final String? selectedCity;

  const _CategoryAllEventsPage({
    required this.category,
    required this.events,
    required this.favoriteEvents,
    required this.onToggleFavorite,
    this.selectedCity,
  });

  @override
  State<_CategoryAllEventsPage> createState() => _CategoryAllEventsPageState();
}

class _CategoryAllEventsPageState extends State<_CategoryAllEventsPage> {
  final List<Event> _events = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  int _page = 0;
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    if (_loadingMore || !_hasMore) return;
    setState(() {
      if (_page == 0) {
        _loading = true;
      } else {
        _loadingMore = true;
      }
    });

    // Mevcut yüklenmiş event listesinden kategori + şehir filtresi uygula
    final List<Event> base = widget.events.where((e) {
      final mapped = getCategoryStyle('${e.category?.name ?? ''} ${e.title}')['title'];
      return mapped == widget.category;
    }).toList();

    final List<Event> cityFiltered = (widget.selectedCity != null && widget.selectedCity != 'Tümü')
        ? base.where((e) => (e.venue?.city?.name ?? '') == widget.selectedCity).toList()
        : base;

    final int start = _page * _pageSize;
    final List<Event> pageSlice = start >= cityFiltered.length
        ? []
        : cityFiltered.sublist(start, (start + _pageSize).clamp(0, cityFiltered.length));

    await Future<void>.delayed(const Duration(milliseconds: 150)); // küçük bir UI nefesi

    setState(() {
      _events.addAll(pageSlice);
      _hasMore = start + _pageSize < cityFiltered.length;
      _loading = false;
      _loadingMore = false;
      if (pageSlice.isNotEmpty) _page++;
    });
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 100) {
      if (_hasMore && !_loadingMore) {
        _fetchEvents();
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.category, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Test bildirimi gönder
              final notificationService = NotificationService();
              notificationService.sendTestNotification();
              
              // Kullanıcıya bilgi ver
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Test bildirimi gönderildi!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'Test Bildirimi Gönder',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : NotificationListener<ScrollNotification>(
              onNotification: _onScrollNotification,
              child: _events.isEmpty
                  ? const Center(
                      child: Text(
                        'Bu kategoriye ait etkinlik bulunamadı.',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _events.length + 1,
                      itemBuilder: (context, index) {
                        if (index < _events.length) {
                          final event = _events[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: EventCard(
                              event: event,
                              isFavorite: widget.favoriteEvents.contains(event),
                              onToggleFavorite: widget.onToggleFavorite,
                            ),
                          );
                        } else if (_loadingMore) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
            ),
    );
  }
}
