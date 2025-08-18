import 'package:flutter/material.dart';
import '../models/event.dart';
import '../widgets/event_card.dart';

class FavoritesPage extends StatelessWidget {
  final List<Event> favoriteEvents;
  final Function(Event) onToggleFavorite;

  const FavoritesPage({
    super.key,
    required this.favoriteEvents,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Favoriler', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: favoriteEvents.isEmpty
          ? const Center(
              child: Text(
                'Henüz favorilere eklenmiş etkinlik yok.',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: favoriteEvents.length,
              itemBuilder: (context, index) {
                final event = favoriteEvents[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: EventCard(
                    key: ValueKey(event.id),
                    event: event,
                    isFavorite: true,
                    onToggleFavorite: onToggleFavorite,
                  ),
                );
              },
            ),
    );
  }
}
