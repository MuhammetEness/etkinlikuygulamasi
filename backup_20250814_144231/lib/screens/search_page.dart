import 'package:flutter/material.dart';
import '../models/event.dart';
import '../utils/filter_utils.dart';
import '../widgets/event_card.dart';
import '../widgets/filter_modal.dart';
import '../widgets/category_grid.dart';

class SearchPage extends StatefulWidget {
  final List<Event> events;
  final List<Event> favoriteEvents;
  final Function(Event) onToggleFavorite;
  final List<String> cities;
  final String? selectedCity;
  final Function(String) onCityChanged;
  final Function(int) onTabChanged;

  const SearchPage({
    super.key,
    required this.events,
    required this.favoriteEvents,
    required this.onToggleFavorite,
    required this.cities,
    required this.selectedCity,
    required this.onCityChanged,
    required this.onTabChanged,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  
  // SearchPage'e özel filtre state'leri (HomePage'i etkilemez)
  String? _searchSelectedCity;

  @override
  void initState() {
    super.initState();
    // Varsayılan olarak HomePage'deki seçili şehri kullan (UI'da şehir seçimi gösterilmiyor)
    _searchSelectedCity = widget.selectedCity;
    debugPrint("SearchPage initState - selectedCity: ${widget.selectedCity}");
  }

  @override
  void didUpdateWidget(SearchPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // HomePage'de şehir değiştiğinde SearchPage'i güncelle
    if (oldWidget.selectedCity != widget.selectedCity) {
      setState(() {
        _searchSelectedCity = widget.selectedCity;
      });
    }
  }

  /// Şehre + aramaya göre etkinlikleri filtrele
  List<Event> _filterEvents() {
    var filtered = widget.events;
    debugPrint("🔍 _filterEvents başladı - Toplam event: ${widget.events.length}");

    // Şehir filtresi sadece home'dan gelir; sayfa içinde şehir seçimi yok
    if (_searchSelectedCity != null && _searchSelectedCity != "Tümü") {
      filtered = filterByCity(filtered, _searchSelectedCity!);
      debugPrint("🏙️ Şehir filtresi: $_searchSelectedCity - Kalan event: ${filtered.length}");
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((e) =>
              e.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
      debugPrint("🔎 Arama filtresi: $_searchQuery - Kalan event: ${filtered.length}");
    }

    debugPrint("🔍 _filterEvents bitti - Final event: ${filtered.length}");
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filteredEvents = _filterEvents();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildSearchBar(),
            Expanded(
              child: _searchQuery.isEmpty
                  ? CategoryGrid(
                      events: filteredEvents,
                      favoriteEvents: widget.favoriteEvents.toSet(),
                      onToggleFavorite: widget.onToggleFavorite,
                      selectedCity: _searchSelectedCity,
                    )
                  : _buildSearchResults(filteredEvents),
            ),
          ],
        ),
      ),
    );
  }

  /// Üst başlık + ana sayfa butonu
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Ara",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
    );
  }

  /// Arama çubuğu + filtre butonu - Figma'daki gibi yan yana
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // hizalama düzeltildi
        children: [
          // Arama çubuğu
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: const InputDecoration(
                  hintText: "Etkinlik veya mekan ara...",
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  contentPadding: EdgeInsets.symmetric(vertical: 14), // dikey hizalama
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Filtre butonu - Figma'daki gibi arama çubuğunun sağında
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF1C58F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _showFilterModal(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.tune, color: Colors.white, size: 20),
                      const SizedBox(width: 6),
                      const Text(
                        "Filters",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Arama sonuçları
  Widget _buildSearchResults(List<Event> results) {
    if (results.isEmpty) {
      return const Center(child: Text("Etkinlik bulunamadı"));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final e = results[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: EventCard(
            key: ValueKey(e.id),
            event: e,
            isFavorite: widget.favoriteEvents.contains(e),
            onToggleFavorite: widget.onToggleFavorite,
          ),
        );
      },
    );
  }

  /// Filtre modal'ını göster
  void _showFilterModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => FilterModal(
        cities: widget.cities,
        selectedCity: _searchSelectedCity,
        selectedDistrict: null,
        selectedNeighborhood: null,
        onCityChanged: (city) {
          setState(() {
            _searchSelectedCity = city;
          });
        },
        onDistrictChanged: (_) {},
        onNeighborhoodChanged: (_) {},
      ),
    );
  }
}
