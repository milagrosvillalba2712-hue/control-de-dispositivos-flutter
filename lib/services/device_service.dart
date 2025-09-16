import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/device.dart';

class DeviceService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtener email del usuario actual
  String? get currentUserEmail => _auth.currentUser?.email;

  // Stream para escuchar cambios en todos los dispositivos
  Stream<List<Device>> getDevicesStream() {
    return _database.onValue.map((event) {
      final data = event.snapshot.value;
      
      print('Stream - Firebase data: $data');
      print('Stream - Data type: ${data.runtimeType}');
      
      if (data == null) return <Device>[];

      List<Device> devices = [];
      
      if (data is List) {
        // Si los datos son una lista (como en tu estructura actual)
        print('Stream - Data is List with ${data.length} items');
        for (int i = 0; i < data.length; i++) {
          if (data[i] != null && data[i] is Map) {
            final deviceData = Map<String, dynamic>.from(data[i]);
            final deviceId = deviceData['id'] ?? 'device_$i';
            print('Stream - Device $i: $deviceData, ID: $deviceId');
            devices.add(Device.fromMap(deviceData, deviceId));
          }
        }
      } else if (data is Map) {
        // Si los datos son un mapa (estructura alternativa)
        print('Stream - Data is Map: $data');
        final dataMap = Map<String, dynamic>.from(data);
        dataMap.forEach((key, value) {
          if (value is Map) {
            final deviceData = Map<String, dynamic>.from(value);
            print('Stream - Device $key: $deviceData');
            devices.add(Device.fromMap(deviceData, key));
          }
        });
      }

      print('Stream - Found ${devices.length} devices');
      return devices;
    });
  }

  // Obtener lista de dispositivos una sola vez
  Future<List<Device>> getDevices() async {
    try {
      final snapshot = await _database.get();
      final data = snapshot.value;
      
      print('Firebase data: $data');
      print('Data type: ${data.runtimeType}');
      
      if (data == null) {
        print('No data found in Firebase');
        return <Device>[];
      }

      List<Device> devices = [];
      
      if (data is List) {
        print('Data is List with ${data.length} items');
        for (int i = 0; i < data.length; i++) {
          if (data[i] != null && data[i] is Map) {
            final deviceData = Map<String, dynamic>.from(data[i]);
            final deviceId = deviceData['id'] ?? 'device_$i';
            print('Device $i: $deviceData, ID: $deviceId');
            devices.add(Device.fromMap(deviceData, deviceId));
          }
        }
      } else if (data is Map) {
        print('Data is Map: $data');
        final dataMap = Map<String, dynamic>.from(data);
        dataMap.forEach((key, value) {
          if (value is Map) {
            final deviceData = Map<String, dynamic>.from(value);
            print('Device $key: $deviceData');
            devices.add(Device.fromMap(deviceData, key));
          }
        });
      }

      print('Found ${devices.length} devices');
      return devices;
    } catch (e) {
      print('Error getting devices: $e');
      return <Device>[];
    }
  }

  // Actualizar L1 (control) de un dispositivo específico
  Future<void> updateDeviceL1(String deviceId, int value) async {
    try {
      final devices = await getDevices();
      final deviceIndex = devices.indexWhere((device) => device.id == deviceId);
      
      if (deviceIndex == -1) {
        throw Exception('Dispositivo con ID $deviceId no encontrado');
      }
      
      await _database.child('$deviceIndex/L1').set(value);
    } catch (e) {
      print('Error updating device L1: $e');
      throw e;
    }
  }

  // Actualizar L2 (estado) de un dispositivo específico
  Future<void> updateDeviceL2(String deviceId, int newL2) async {
    try {
      final devices = await getDevices();
      final deviceIndex = devices.indexWhere((device) => device.id == deviceId);
      
      if (deviceIndex == -1) {
        print('Device with ID $deviceId not found');
        return;
      }

      await _database.child('$deviceIndex/L2').set(newL2);
      print('Device L2 updated successfully for $deviceId');
    } catch (e) {
      print('Error updating device L2: $e');
    }
  }

  // Alternar estado L1 de un dispositivo
  Future<void> toggleDeviceL1(String deviceId) async {
    try {
      final devices = await getDevices();
      final deviceIndex = devices.indexWhere((d) => d.id == deviceId);
      
      if (deviceIndex == -1) {
        throw Exception('Dispositivo con ID $deviceId no encontrado');
      }
      
      final device = devices[deviceIndex];
      final newValue = device.l1 == 1 ? 0 : 1;
      
      // Actualizar con información del usuario
      final updateData = {
        'L1': newValue,
        'lastUpdated': DateTime.now().toIso8601String(),
        'updatedBy': currentUserEmail,
      };
      
      await _database.child('$deviceIndex').update(updateData);
      print('Device L1 toggled successfully for $deviceId by ${currentUserEmail}');
    } catch (e) {
      print('Error toggling device L1: $e');
      throw e;
    }
  }

  // Obtener referencia específica de un dispositivo
  DatabaseReference getDeviceReference(String deviceId) {
    // Esta función asume que conoces el índice del dispositivo
    // En una implementación más robusta, podrías usar una estructura de mapa
    return _database.child('devices/$deviceId');
  }

  // Escuchar cambios de un dispositivo específico
  Stream<Device?> getDeviceStream(String deviceId) {
    return _database.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return null;

      if (data is List) {
        for (int i = 0; i < data.length; i++) {
          if (data[i] != null && data[i] is Map) {
            final deviceData = Map<String, dynamic>.from(data[i]);
            if (deviceData['id'] == deviceId) {
              return Device.fromMap(deviceData, deviceId);
            }
          }
        }
      }
      return null;
    });
  }

  // Actualizar información completa del dispositivo
  Future<void> updateDevice(Device device) async {
    try {
      final devices = await getDevices();
      final deviceIndex = devices.indexWhere((d) => d.id == device.id);
      
      if (deviceIndex == -1) {
        print('Device with ID ${device.id} not found');
        return;
      }

      // Actualizar timestamps y usuario
      device.lastUpdated = DateTime.now();
      device.updatedBy = currentUserEmail;

      // Actualizar el dispositivo completo en Firebase
      await _database.child('$deviceIndex').update(device.toMap());
      print('Device updated successfully: ${device.id} by ${currentUserEmail}');
    } catch (e) {
      print('Error updating device: $e');
      throw e;
    }
  }

  // Actualizar solo campos específicos del dispositivo
  Future<void> updateDeviceFields(String deviceId, Map<String, dynamic> fields) async {
    try {
      final devices = await getDevices();
      final deviceIndex = devices.indexWhere((device) => device.id == deviceId);
      
      if (deviceIndex == -1) {
        print('Device with ID $deviceId not found');
        return;
      }

      // Agregar timestamp de última actualización y usuario
      fields['lastUpdated'] = DateTime.now().toIso8601String();
      fields['updatedBy'] = currentUserEmail;

      await _database.child('$deviceIndex').update(fields);
      print('Device fields updated successfully for $deviceId by ${currentUserEmail}: $fields');
    } catch (e) {
      print('Error updating device fields: $e');
      throw e;
    }
  }

  // Crear nuevo dispositivo
  Future<void> addDevice(Device device) async {
    try {
      final devices = await getDevices();
      final newIndex = devices.length;
      
      // Establecer timestamps y usuario creador
      final now = DateTime.now();
      device.createdAt = now;
      device.lastUpdated = now;
      device.createdBy = currentUserEmail;
      device.updatedBy = currentUserEmail;
      
      await _database.child('$newIndex').set(device.toMap());
      print('Device added successfully: ${device.id} by ${currentUserEmail}');
    } catch (e) {
      print('Error adding device: $e');
      throw e;
    }
  }

  // Eliminar dispositivo
  Future<void> deleteDevice(String deviceId) async {
    try {
      final devices = await getDevices();
      final deviceIndex = devices.indexWhere((device) => device.id == deviceId);
      
      if (deviceIndex == -1) {
        print('Device with ID $deviceId not found');
        return;
      }

      await _database.child('$deviceIndex').remove();
      print('Device deleted successfully: $deviceId');
    } catch (e) {
      print('Error deleting device: $e');
      throw e;
    }
  }
}
