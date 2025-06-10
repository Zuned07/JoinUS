import 'package:flutter/material.dart';

class RecommendedEvents extends StatelessWidget {
  final List<String> userInterests;
  final Map<String, Map<String, dynamic>> mockEventsByTag;

  const RecommendedEvents({
    super.key,
    required this.userInterests,
    required this.mockEventsByTag,
  });

  @override
  Widget build(BuildContext context) {
    if (userInterests.isEmpty) {
      return const Text('No hay recomendaciones o eventos disponibles.');
    }

    final recommendedEvents = userInterests
        .where((tag) => mockEventsByTag.containsKey(tag))
        .map((tag) => mockEventsByTag[tag]!)
        .toList();

    if (recommendedEvents.isEmpty) {
      return const Text('No se encontraron eventos recomendados.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 20.0, bottom: 10.0),
          child: Text(
            'Eventos recomendados:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...recommendedEvents.map((event) => Card(
              child: ListTile(
                leading: Icon(event['icon'], color: Theme.of(context).colorScheme.primary),
                title: Text(event['title']),
                subtitle: Text(event['description']),
              ),
            )),
      ],
    );
  }
}
