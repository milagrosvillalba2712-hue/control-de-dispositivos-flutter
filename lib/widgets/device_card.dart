import 'package:flutter/material.dart';
import '../models/device.dart';

class DeviceCard extends StatelessWidget {
  final Device device;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback? onPressStart; // only used for garage
  final VoidCallback? onPressEnd;   // only used for garage
  final bool isLoading;

  const DeviceCard({
    Key? key,
    required this.device,
    required this.onToggle,
    required this.onEdit,
    this.onPressStart,
    this.onPressEnd,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: device.l1 == 1
              ? [
                  device.deviceColor.withOpacity(0.1),
                  device.deviceColor.withOpacity(0.05),
                ]
              : [
                  Colors.grey[800]!.withOpacity(0.8),
                  Colors.grey[900]!.withOpacity(0.9),
                ],
        ),
        border: Border.all(
          color: device.l1 == 1 
              ? device.deviceColor.withOpacity(0.5)
              : Colors.grey[700]!.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: device.l1 == 1 
                ? device.deviceColor.withOpacity(0.2)
                : Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con icono y nombre
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: device.deviceColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: device.deviceColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        device.icon,
                        color: device.l1 == 1 ? device.deviceColor : Colors.grey,
                        size: 32,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            device.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              if (device.room != null && device.room!.isNotEmpty) ...[
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    device.room!,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[400],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                              ],
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: device.statusColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: device.statusColor.withOpacity(0.4),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  device.statusText,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: device.statusColor,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Botón de edición
                    Container(
                      margin: EdgeInsets.only(right: 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onEdit,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.edit_rounded,
                              color: Colors.white.withOpacity(0.8),
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Indicador de estado animado
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: device.statusColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: device.statusColor.withOpacity(0.6),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                
                // Información adicional para garaje
                if (device.type == DeviceType.garage) ...[
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.settings,
                          color: Colors.grey[400],
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Control: ${device.l1 == 1 ? 'ACTIVO' : 'INACTIVO'}',
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                ],

                // Botón de control moderno
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: device.l1 == 1
                          ? [
                              device.statusColor,
                              device.statusColor.withOpacity(0.8),
                            ]
                          : [
                              Colors.grey[700]!,
                              Colors.grey[800]!,
                            ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: device.l1 == 1 
                            ? device.statusColor.withOpacity(0.4)
                            : Colors.black.withOpacity(0.3),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Builder(
                      builder: (context) {
                        // Para garaje usamos press-and-hold (onPressStart/onPressEnd)
                        if (device.type == DeviceType.garage) {
                          return GestureDetector(
                            onTapDown: isLoading ? null : (_) => onPressStart?.call(),
                            onTapUp: isLoading ? null : (_) => onPressEnd?.call(),
                            onTapCancel: isLoading ? null : () => onPressEnd?.call(),
                            child: _buildButtonInner(),
                          );
                        }
                        // Para otros dispositivos usamos onTap normal
                        return InkWell(
                          onTap: isLoading ? null : onToggle,
                          borderRadius: BorderRadius.circular(16),
                          child: _buildButtonInner(),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Contenido interno del botón (spinner o texto/icono)
  Widget _buildButtonInner() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: isLoading
          ? Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    device.l1 == 1 ? Colors.black : Colors.white,
                  ),
                ),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  device.l1 == 1
                      ? Icons.power_off_rounded
                      : Icons.power_settings_new_rounded,
                  size: 24,
                  color: device.l1 == 1 ? Colors.black : Colors.white,
                ),
                SizedBox(width: 12),
                Text(
                  device.controlButtonText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: device.l1 == 1 ? Colors.black : Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
    );
  }
}
