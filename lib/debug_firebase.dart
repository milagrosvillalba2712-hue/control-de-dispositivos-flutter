import 'package:firebase_database/firebase_database.dart';

class FirebaseDebugger {
  static final DatabaseReference _database = FirebaseDatabase.instance.ref();

  static Future<void> debugFirebaseStructure() async {
    try {
      print('=== DEBUGGING FIREBASE STRUCTURE ===');
      
      // Obtener datos de la raíz
      final snapshot = await _database.get();
      final data = snapshot.value;
      
      print('Root data: $data');
      print('Root data type: ${data.runtimeType}');
      
      if (data == null) {
        print('❌ No data found in Firebase root');
        return;
      }
      
      if (data is List) {
        print('✅ Data is a List with ${data.length} items');
        for (int i = 0; i < data.length; i++) {
          print('  [$i]: ${data[i]} (${data[i].runtimeType})');
        }
      } else if (data is Map) {
        print('✅ Data is a Map with ${data.length} keys');
        final dataMap = Map<String, dynamic>.from(data);
        dataMap.forEach((key, value) {
          print('  [$key]: $value (${value.runtimeType})');
        });
      } else {
        print('❌ Unexpected data type: ${data.runtimeType}');
      }
      
      print('=== END DEBUG ===');
    } catch (e) {
      print('❌ Error debugging Firebase: $e');
    }
  }

  static Future<void> createTestData() async {
    try {
      print('=== CREATING TEST DATA ===');
      
      final testDevices = [
        {
          "L1": 0,
          "L2": 0,
          "id": "Luz Sala",
          "name": "Luz Sala",
          "icon": "lightbulb",
          "color": "#FFC107",
          "type": "light",
          "room": "Sala",
          "createdAt": DateTime.now().toIso8601String(),
          "lastUpdated": DateTime.now().toIso8601String(),
          "createdBy": "fabianfleitas55@gmail.com",
          "updatedBy": "fabianfleitas55@gmail.com"
        },
        {
          "L1": 0,
          "L2": 0,
          "id": "Aire",
          "name": "Aire Acondicionado",
          "icon": "ac_unit",
          "color": "#2196F3",
          "type": "air_conditioner",
          "room": "Dormitorio",
          "createdAt": DateTime.now().toIso8601String(),
          "lastUpdated": DateTime.now().toIso8601String(),
          "createdBy": "fabianfleitas55@gmail.com",
          "updatedBy": "fabianfleitas55@gmail.com"
        },
        {
          "L1": 0,
          "L2": 0,
          "id": "Portón Garaje",
          "name": "Portón del Garaje",
          "icon": "garage",
          "color": "#4CAF50",
          "type": "garage",
          "room": "Garaje",
          "createdAt": DateTime.now().toIso8601String(),
          "lastUpdated": DateTime.now().toIso8601String(),
          "createdBy": "fabianfleitas55@gmail.com",
          "updatedBy": "fabianfleitas55@gmail.com"
        },
      ];

      await _database.set(testDevices);
      print('✅ Nueva estructura de datos creada exitosamente');
      print('📱 Dispositivos creados con estructura completa:');
      for (int i = 0; i < testDevices.length; i++) {
        final device = testDevices[i];
        print('   ${i + 1}. ${device['name']} (${device['type']}) - ${device['room']}');
      }
      await debugFirebaseStructure();
    } catch (e) {
      print('❌ Error creating test data: $e');
    }
  }
}
