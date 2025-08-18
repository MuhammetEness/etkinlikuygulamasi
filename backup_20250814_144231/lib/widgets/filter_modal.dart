import 'package:flutter/material.dart';
import '../services/district/district_service.dart';
import '../services/neighborhood/neighborhood_service.dart';

class FilterModal extends StatefulWidget {
  final List<String> cities;
  final String? selectedCity;
  final String? selectedDistrict;
  final String? selectedNeighborhood;
  final Function(String) onCityChanged;
  final Function(String) onDistrictChanged;
  final Function(String) onNeighborhoodChanged;

  const FilterModal({
    super.key,
    required this.cities,
    required this.selectedCity,
    required this.selectedDistrict,
    required this.selectedNeighborhood,
    required this.onCityChanged,
    required this.onDistrictChanged,
    required this.onNeighborhoodChanged,
  });

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  List<String> _availableDistricts = [];
  List<String> _availableNeighborhoods = [];

  String? _selectedCity;
  String? _selectedDistrict;
  String? _selectedNeighborhood;
  
  // Loading state'leri
  bool _loadingDistricts = false;
  bool _loadingNeighborhoods = false;

  @override
  void initState() {
    super.initState();
    _selectedCity = widget.selectedCity;
    _selectedDistrict = widget.selectedDistrict;
    _selectedNeighborhood = widget.selectedNeighborhood;
    
    // Başlangıçta ilçe ve semtleri yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDistricts();
      _loadNeighborhoods();
    });
  }

  @override
  void didUpdateWidget(covariant FilterModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCity != widget.selectedCity) {
      setState(() {
        _selectedCity = widget.selectedCity;
        _selectedDistrict = null;
        _selectedNeighborhood = null;
      });
      _loadDistricts();
    }
    if (oldWidget.selectedDistrict != widget.selectedDistrict) {
      setState(() {
        _selectedDistrict = widget.selectedDistrict;
        _selectedNeighborhood = null;
      });
      _loadNeighborhoods();
    }
    if (oldWidget.selectedNeighborhood != widget.selectedNeighborhood) {
      setState(() {
        _selectedNeighborhood = widget.selectedNeighborhood;
      });
    }
  }

  void _loadDistricts() async {
    if (_selectedCity != null && _selectedCity != "Tümü") {
      setState(() {
        _loadingDistricts = true;
      });
      
      final districtService = DistrictService();
      final districts = await districtService.fetchDistrictsByCity(_selectedCity!);
      
      setState(() {
        // Duplicate'ları temizle
        _availableDistricts = districts.toSet().toList()..sort();
        _availableNeighborhoods = [];
        // Eğer seçili ilçe yeni listede yoksa temizle
        if (!_availableDistricts.contains(_selectedDistrict)) {
          _selectedDistrict = null;
        }
        _loadingDistricts = false;
      });
    } else {
      setState(() {
        _availableDistricts = [];
        _availableNeighborhoods = [];
        _selectedDistrict = null;
        _selectedNeighborhood = null;
        _loadingDistricts = false;
      });
    }
  }

  void _loadNeighborhoods() async {
    debugPrint("=== SEMT YÜKLEME BAŞLADI ===");
    debugPrint("Seçili ilçe: $_selectedDistrict");
    
    if (_selectedDistrict != null && _selectedDistrict != "Tümü") {
      setState(() {
        _loadingNeighborhoods = true;
      });
      
      debugPrint("Semtler yükleniyor... İlçe: $_selectedDistrict");
      try {
        final neighborhoods = await NeighborhoodService().fetchNeighborhoodsByDistrict(_selectedDistrict!);
        debugPrint("API'den gelen semtler: $neighborhoods");
        debugPrint("Semt sayısı: ${neighborhoods.length}");
        
        if (neighborhoods.isNotEmpty) {
          setState(() {
            // Duplicate'ları temizle
            _availableNeighborhoods = neighborhoods.toSet().toList()..sort();
            // Eğer seçili semt yeni listede yoksa temizle
            if (!_availableNeighborhoods.contains(_selectedNeighborhood)) {
              _selectedNeighborhood = null;
            }
            _loadingNeighborhoods = false;
          });
          
          debugPrint("Semtler state'e kaydedildi. Mevcut semtler: $_availableNeighborhoods");
          debugPrint("✅ Semt yükleme tamamlandı");
        } else {
          debugPrint("❌ API'den boş liste geldi");
          setState(() {
            _availableNeighborhoods = [];
            _selectedNeighborhood = null;
            _loadingNeighborhoods = false;
          });
        }
      } catch (e) {
        debugPrint("❌ Semt yükleme hatası: $e");
        setState(() {
          _availableNeighborhoods = [];
          _selectedNeighborhood = null;
          _loadingNeighborhoods = false;
        });
      }
    } else {
      debugPrint("❌ İlçe seçili değil veya 'Tümü' seçili");
      setState(() {
        _availableNeighborhoods = [];
        _selectedNeighborhood = null;
        _loadingNeighborhoods = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.98,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık - Row ile çarpı işaretini sağa hizala
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Filtreler",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Şehir seçimi - Ayrı Container
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Şehir:",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedCity,
                        isExpanded: true,
                        underline: Container(),
                        hint: const Text("Şehir seçin", style: TextStyle(fontSize: 14)),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text("Tümü", style: TextStyle(fontSize: 14)),
                          ),
                          ...widget.cities.where((city) => city != "Tümü").map((city) => DropdownMenuItem(
                            value: city,
                            child: Text(city, style: const TextStyle(fontSize: 14)),
                          )),
                        ],
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCity = newValue;
                            _selectedDistrict = null;
                            _selectedNeighborhood = null;
                          });
                          if (newValue != null) {
                            widget.onCityChanged(newValue);
                            _loadDistricts();
                          } else {
                            setState(() {
                              _availableDistricts = [];
                              _availableNeighborhoods = [];
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              // İlçe seçimi - Ayrı Container
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "İlçe:",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _loadingDistricts 
                        ? SizedBox(
                            height: 50,
                            child: Row(
                              children: [
                                SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                                SizedBox(width: 12),
                                Text("İlçeler yükleniyor...", style: TextStyle(fontSize: 14, color: Colors.grey)),
                              ],
                            ),
                          )
                        : DropdownButton<String>(
                            value: _availableDistricts.contains(_selectedDistrict) ? _selectedDistrict : null,
                            isExpanded: true,
                            underline: Container(),
                            hint: const Text("İlçe seçin", style: TextStyle(fontSize: 14)),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text("Tümü", style: TextStyle(fontSize: 14)),
                              ),
                              ..._availableDistricts.toSet().toList().map((district) => DropdownMenuItem(
                                value: district,
                                child: Text(district, style: const TextStyle(fontSize: 14)),
                              )),
                            ],
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedDistrict = newValue;
                            _selectedNeighborhood = null;
                          });
                          if (newValue != null) {
                            widget.onDistrictChanged(newValue);
                            _loadNeighborhoods();
                          } else {
                            setState(() {
                              _availableNeighborhoods = [];
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              // Semt seçimi - Ayrı Container
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Semt:",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _loadingNeighborhoods 
                        ? SizedBox(
                            height: 50,
                            child: Row(
                              children: [
                                SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                                SizedBox(width: 12),
                                Text("Semtler yükleniyor...", style: TextStyle(fontSize: 14, color: Colors.grey)),
                              ],
                            ),
                          )
                        : DropdownButton<String>(
                            value: _availableNeighborhoods.contains(_selectedNeighborhood) ? _selectedNeighborhood : null,
                            isExpanded: true,
                            underline: Container(),
                            hint: const Text("Semt seçin", style: TextStyle(fontSize: 14)),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text("Tümü", style: TextStyle(fontSize: 14)),
                              ),
                              ..._availableNeighborhoods.toSet().toList().map((neighborhood) => DropdownMenuItem(
                                value: neighborhood,
                                child: Text(neighborhood, style: const TextStyle(fontSize: 14)),
                              )),
                            ],
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedNeighborhood = newValue;
                          });
                          if (newValue != null) {
                            widget.onNeighborhoodChanged(newValue);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              // Uygula butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C58F2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Filtreleri Uygula",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 