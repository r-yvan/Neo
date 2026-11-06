import 'package:eventneo/data/models/map_models.dart';
import 'package:eventneo/data/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses the /map/nearby payload', () {
    final MapNearby d = MapNearby.fromJson(<String, dynamic>{
      'radiusKm': 15,
      'lenders': <dynamic>[
        <String, dynamic>{
          'id': 'o1',
          'pinId': 'o1:-1.95,30.08',
          'fullName': 'Eric Events Ltd',
          'isVerified': true,
          'latitude': -1.953,
          'longitude': 30.08,
          'distanceKm': 2.2,
          'listingCount': 2,
          'categories': <dynamic>['SPEAKERS', 'LIGHTS'],
          'minPricePerDay': 12000,
          'listings': <dynamic>[
            <String, dynamic>{'id': 'e1', 'title': 'PA', 'category': 'SPEAKERS', 'pricePerDay': 35000},
          ],
        },
      ],
      'borrowers': <dynamic>[
        <String, dynamic>{
          'id': 'u2',
          'fullName': 'Grace Uwase',
          'latitude': -1.94,
          'longitude': 30.06,
          'distanceKm': 0.5,
          'note': 'Need tables',
          'activeAt': '2026-11-06T13:00:00.000Z',
        },
      ],
    });
    expect(d.lenders.single.categories,
        <EquipmentCategory>[EquipmentCategory.speakers, EquipmentCategory.lights]);
    expect(d.lenders.single.listings.single.pricePerDay, 35000);
    expect(d.lenders.single.initials, 'EL');
    expect(d.lenders.single.key, 'o1:-1.95,30.08');
    expect(d.lenders.single.id, 'o1');
    expect(d.borrowers.single.key, 'u2');
    expect(d.borrowers.single.note, 'Need tables');
    expect(d.borrowers.single.toUserRef().fullName, 'Grace Uwase');
  });

  test('presence knows whether a location is stored', () {
    expect(const MapPresence().hasLocation, isFalse);
    final MapPresence p = MapPresence.fromJson(<String, dynamic>{
      'latitude': -1.95,
      'longitude': 30.09,
      'showOnMap': true,
      'mapNote': 'Tent',
    });
    expect(p.hasLocation, isTrue);
    expect(p.showOnMap, isTrue);
    expect(p.note, 'Tent');
  });
}
