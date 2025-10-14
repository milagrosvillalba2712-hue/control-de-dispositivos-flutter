# Smart Home - Control de Dispositivos

Un sistema integral para la gestión y control de dispositivos inteligentes en el hogar, utilizando una aplicación móvil y servicios en la nube.

---

## Visión General del Proyecto

El proyecto **Smart Home** tiene como objetivo proporcionar una solución eficiente y accesible para el control de dispositivos inteligentes en el hogar. A través de una aplicación móvil, los usuarios pueden gestionar dispositivos como luces, puertas y sensores, con notificaciones en tiempo real y almacenamiento seguro en la nube.

### Metas del Proyecto
- Facilitar la automatización y el control remoto de dispositivos inteligentes.
- Proveer una experiencia de usuario intuitiva y confiable.
- Garantizar la seguridad y privacidad de los datos mediante el uso de Firebase.

---

## Arquitectura del Proyecto

El sistema está compuesto por los siguientes componentes principales:
1. **Aplicación Móvil**: Desarrollada en Flutter, permite a los usuarios interactuar con los dispositivos inteligentes.
2. **Servicios en la Nube (Firebase)**: Utilizados para autenticación, base de datos en tiempo real, mensajería y almacenamiento.
3. **Microcontrolador**: Dispositivo físico que interactúa con los dispositivos inteligentes y se comunica con Firebase.

### Tecnologías Utilizadas
- **Flutter**: Framework para el desarrollo de la aplicación móvil.
- **Firebase**: Servicios en la nube, incluyendo Firestore, Firebase Authentication, Firebase Messaging y Firebase Realtime Database.
- **C++**: Lenguaje utilizado en el microcontrolador para la comunicación con Firebase.
- **Flutter Local Notifications**: Para notificaciones locales en la aplicación.

> **Nota**: Para más detalles sobre la arquitectura, consulta el diagrama de componentes en el [HU9](path/to/hu9).

---

## Instrucciones de Instalación y Configuración del Entorno

### Paso 1: Clonar el Repositorio
```bash
git clone https://github.com/tu-usuario/smart-home.git
cd smart-home
```

### Paso 2: Instalar Dependencias
Asegúrate de tener Flutter instalado. Luego, ejecuta:
```bash
flutter pub get
```

### Paso 3: Configurar Firebase
1. Ve a la consola de Firebase y crea un nuevo proyecto.
2. Descarga los archivos de configuración:
- google-services.json para Android.
- GoogleService-Info.plist para iOS.
3. Coloca los archivos en las carpetas correspondientes:
- Android: android/app/
- iOS: ios/Runner/
- Configura las opciones de Firebase en el archivo lib/firebase_options.dart.
