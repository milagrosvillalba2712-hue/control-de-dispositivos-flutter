import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Script para actualizar la estructura de Firebase con los nuevos datos
Future<void> updateFirebaseStructure() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final database = FirebaseDatabase.instance.ref();

  // Nueva estructura de datos según especificación
  final newDevicesData = [
    {
      "L1": 0,
      "L2": 0,
      "id": "Luz Sala",
      "name": "Luz Sala",
      "icon": "lightbulb",
      "color": "#FFC107",
      "type": "light",
      "room": "Sala",
      "createdAt": "2024-01-15T10:30:00Z",
      "lastUpdated": "2024-01-15T15:45:00Z",
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
      "createdAt": "2024-01-15T10:30:00Z",
      "lastUpdated": "2024-01-15T15:45:00Z",
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
      "createdAt": "2024-01-15T10:30:00Z",
      "lastUpdated": "2024-01-15T15:45:00Z",
      "createdBy": "fabianfleitas55@gmail.com",
      "updatedBy": "fabianfleitas55@gmail.com"
    }
  ];

  try {
    // Limpiar datos existentes y establecer la nueva estructura
    await database.set(newDevicesData);
    print('✅ Estructura de Firebase actualizada exitosamente');
    print('📱 Dispositivos creados:');
    for (int i = 0; i < newDevicesData.length; i++) {
      final device = newDevicesData[i];
      print('   ${i + 1}. ${device['name']} (${device['type']}) - ${device['room']}');
    }
  } catch (e) {
    print('❌ Error actualizando Firebase: $e');
  }
}

void main() async {
  await updateFirebaseStructure();
}
