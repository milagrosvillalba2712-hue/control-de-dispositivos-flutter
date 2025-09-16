import 'package:flutter/material.dart';

class Device {
  final String id;
  String name;
  final DeviceType type;
  String iconName;
  String colorHex;
  String? room;
  int l1; // Control state (0 = OFF, 1 = ON)
  int l2; // Device state (0 = OFF/CLOSED, 1 = ON/OPEN)
  DateTime? createdAt;
  DateTime? lastUpdated;
  String? createdBy;
  String? updatedBy;

  Device({
    required this.id,
    required this.name,
    required this.type,
    this.iconName = 'device_hub',
    this.colorHex = '#FF9800',
    this.room,
    this.l1 = 0,
    this.l2 = 0,
    this.createdAt,
    this.lastUpdated,
    this.createdBy,
    this.updatedBy,
  });

  // Crear Device desde datos de Firebase
  factory Device.fromMap(Map<dynamic, dynamic> map, String deviceId) {
    return Device(
      id: deviceId,
      name: map['name'] ?? deviceId,
      type: _getDeviceType(map['type'] ?? deviceId),
      iconName: map['icon'] ?? _getDefaultIcon(map['type'] ?? deviceId),
      colorHex: map['color'] ?? _getDefaultColor(map['type'] ?? deviceId),
      room: map['room'],
      l1: map['L1'] ?? 0,
      l2: map['L2'] ?? 0,
      createdAt: map['createdAt'] != null ? _parseDateTime(map['createdAt']) : null,
      lastUpdated: map['lastUpdated'] != null ? _parseDateTime(map['lastUpdated']) : null,
      createdBy: map['createdBy'],
      updatedBy: map['updatedBy'],
    );
  }

  // Convertir Device a Map para Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'icon': iconName,
      'color': colorHex,
      'room': room,
      'L1': l1,
      'L2': l2,
      'createdAt': createdAt?.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }


  // Determinar tipo de dispositivo basado en ID o tipo
  static DeviceType _getDeviceType(String input) {
    final lowerInput = input.toLowerCase();
    if (lowerInput == 'light' || lowerInput.contains('luz') || lowerInput.contains('led')) {
      return DeviceType.light;
    } else if (lowerInput == 'air_conditioner' || lowerInput.contains('aire') || lowerInput.contains('acondicionador')) {
      return DeviceType.airConditioner;
    } else if (lowerInput == 'garage' || lowerInput.contains('garaje') || lowerInput.contains('porton')) {
      return DeviceType.garage;
    } else {
      return DeviceType.generic;
    }
  }

  // Obtener icono por defecto según tipo
  static String _getDefaultIcon(String input) {
    final type = _getDeviceType(input);
    switch (type) {
      case DeviceType.light:
        return 'lightbulb';
      case DeviceType.airConditioner:
        return 'ac_unit';
      case DeviceType.garage:
        return 'garage';
      case DeviceType.generic:
        return 'device_hub';
    }
  }

  // Obtener color por defecto según tipo
  static String _getDefaultColor(String input) {
    final type = _getDeviceType(input);
    switch (type) {
      case DeviceType.light:
        return '#FFC107'; // Amarillo
      case DeviceType.airConditioner:
        return '#2196F3'; // Azul
      case DeviceType.garage:
        return '#4CAF50'; // Verde
      case DeviceType.generic:
        return '#FF9800'; // Naranja
    }
  }

  // Obtener icono personalizado o por defecto
  IconData get icon {
    return getIconFromName(iconName);
  }

  // Convertir nombre de icono a IconData
  static IconData getIconFromName(String iconName) {
    switch (iconName) {
      case 'lightbulb':
        return Icons.lightbulb;
      case 'ac_unit':
        return Icons.ac_unit;
      case 'garage':
        return Icons.garage;
      case 'device_hub':
        return Icons.device_hub;
      case 'wifi':
        return Icons.wifi;
      case 'tv':
        return Icons.tv;
      case 'speaker':
        return Icons.speaker;
      case 'camera':
        return Icons.camera_alt;
      case 'security':
        return Icons.security;
      case 'thermostat':
        return Icons.thermostat;
      case 'fan':
        return Icons.toys;
      case 'lock':
        return Icons.lock;
      case 'power':
        return Icons.power;
      case 'home':
        return Icons.home;
      default:
        return Icons.device_hub;
    }
  }

  // Obtener color personalizado
  Color get statusColor {
    if (l1 == 1) {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    }
    return Colors.grey;
  }

  // Obtener color base del dispositivo
  Color get deviceColor {
    return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
  }

  // Método auxiliar para parsear fechas con manejo de errores
  static DateTime? _parseDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    
    try {
      // Limpiar espacios extra que pueden causar errores
      final cleanDateString = dateString.replaceAll(RegExp(r'\s+'), ' ').trim();
      // Remover espacios dentro de la fecha
      final normalizedDate = cleanDateString.replaceAll(' ', '');
      return DateTime.parse(normalizedDate);
    } catch (e) {
      print('Error parsing date "$dateString": $e');
      return null;
    }
  }

  // Obtener texto de estado
  String get statusText {
    switch (type) {
      case DeviceType.garage:
        return l2 == 1 ? 'ABIERTO' : 'CERRADO';
      default:
        return l1 == 1 ? 'ENCENDIDO' : 'APAGADO';
    }
  }

  // Obtener texto del botón de control
  String get controlButtonText {
    switch (type) {
      case DeviceType.garage:
        return l2 == 1 ? 'CERRAR' : 'ABRIR';
      default:
        return l1 == 1 ? 'APAGAR' : 'ENCENDER';
    }
  }
}

enum DeviceType {
  light,
  airConditioner,
  garage,
  generic,
}
