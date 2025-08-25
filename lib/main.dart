
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:marbot_2/Token/firebase_api.dart';
import 'firebase_options.dart';
import 'package:marbot_2/services/notification_services.dart';
import 'package:marbot_2/services/auth_service.dart';
import 'package:marbot_2/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
//import 'package:background_fetch/background_fetch.dart';

@pragma('vm:entry-point')
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      print('Firebase already initialized');
    } else {
      print('Firebase initialization error: $e');
    }
  }

  await initNotifications();
  await FirebaseApi().iniNotifications();

  runApp(MyApp());

}


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Manejar la notificación recibida mientras la aplicación está apagada
  print('Background message received: ${message.notification?.title}');

  print("Handling a background message: ${message.messageId}");
  // Aquí puedes agregar la lógica para mostrar la notificación en segundo plano si lo deseas
  // Puedes llamar a las funciones del archivo notification_services.dart para mostrar las notificaciones

  // Lógica para mostrar la notificación en segundo plano
  if (message.data.isNotEmpty) {
    // Obtén los datos de la notificación
    final notificationTitle = message.data['title'];
    final notificationBody = message.data['body'];

    // Llama a la función correspondiente en notification_services.dart para mostrar la notificación
    if (notificationTitle == 'Estado del portón') {
      if (notificationBody == 'El Portón está ABIERTO.') {
        await mostrarNotificacion();
      } else if (notificationBody == 'El Portón está CERRADO.') {
        await mostrarNotificacion2();
      }
    }
  }

}



class MyApp extends StatelessWidget {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control de dispositivos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: StreamBuilder<User?>(
        stream: _auth.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: Colors.grey[900],
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          if (snapshot.hasData) {
            // Usuario autenticado - mostrar app principal
            return MyWidget();
          } else {
            // Usuario no autenticado - mostrar login
            return LoginScreen();
          }
        },
      ),
    );
  }
}

class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final DatabaseReference _ledRef = FirebaseDatabase.instance.reference().child('L1');
  final DatabaseReference _led2Ref = FirebaseDatabase.instance.reference().child('L2');
  final AuthService _auth = AuthService();
  //bool _ledState = false;
  String _ledState = "0";
  int _led2State = 0;

  bool hasChanged = false; //cambios en la notificación al ingresar

  @override
  void initState() {
    super.initState();
    //Para mostrar la notificación después de ingresar a la app
    _led2Ref.onValue.listen((event) {
      setState(() {
        _led2State = event.snapshot.value == 1 ? 1 : 0;
        if (_led2State == 1) {
          if (hasChanged) {
            mostrarNotificacion();
          }
        } else {
          if (hasChanged) {
            mostrarNotificacion2();
          }
        }
        hasChanged = true; // Establecer la bandera en true cuando haya un cambio
      });
    });
    //Para mostrar la notificación al ingresar a la app

    /*_led2Ref.onValue.listen((event) {
      setState(() {
        _led2State = event.snapshot.value == 1 ? 1 : 0;
        if (_led2State == 1) {
          mostrarNotificacion();

        }else{
          mostrarNotificacion2();
        }
      });
    });*/
  }

  void _toggleLed() {
    setState(() {
      /*_ledState = !_ledState;
      _ledRef.set(_ledState ? 1 : 0);*/
      _ledState = _ledState == "1" ? "0" : "1";
      _ledRef.set(_ledState == "1" ? 1 : 0);
    });
  }

  void _toggleLed2() {
    setState(() {
      _led2State = _led2State == 1 ? 0 : 1;
      _led2Ref.set(_led2State);
    });
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error al cerrar sesión: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Control de dispositivos'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Cerrar Sesión'),
                  content: Text('¿Estás seguro que quieres cerrar sesión?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _logout();
                      },
                      child: Text('Cerrar Sesión'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 2),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'PORTÓN : ${_led2State == 1 ? 'ABIERTO' : 'CERRADO'}',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            SizedBox(height: 22),
            Image.asset(
              //'assets/images/movil_2.png',
              _ledState == "1"? 'assets/images/movil_2.png' : 'assets/images/movil_3.png',
              width: 250,
              height: 220,
            ),

            SizedBox(height: 42), // Espacio vertical entre el estado y el botón
            Text(
              'CONTROL : ${_ledState == "1" ? 'ON' : 'OFF'}',
              style: TextStyle(fontSize: 18), //Tamaño de letra estado
            ),
            SizedBox(height: 32), // Espacio vertical entre el estado y el botón
            Container(
              width: 200,
              height: 200,
              child: ElevatedButton(
                onPressed: _toggleLed,
                child: Image.asset(
                  'assets/images/btn.png',
                  width: 300,
                  height: 300,
                ),
                /*
                //Para darle texto al boton
                child: Text(
                  _ledState ? 'APAGAR' : 'ENCENDER',
                  style: TextStyle(fontSize: 16),
                ),*/
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(35),
              ),
            ),
            //Botón salir
            // SizedBox(height: 25), // Espacio vertical entre el botón y el botón "Salir"
            // TextButton(
            //   child: Text(
            //     'SALIR',
            //     style: TextStyle(
            //       fontSize: 20,
            //       color: Colors.red, 
            //     ),
            //   ),
              // onPressed: () {
                // Navigator.of(context).pop();
                //style: TextStyle(fontSize: 35);

                // Aquí puedes agregar cualquier lógica adicional antes de cerrar la aplicación
                // Por ejemplo, guardar datos, cerrar sesiones, etc.
                // Luego, puedes utilizar el método `SystemNavigator.pop()` para cerrar la aplicación.
                // Es importante importar el paquete `package:flutter/services.dart`.
                // import 'package:flutter/services.dart';
                // SystemNavigator.pop();
              // },
            // ),
          ],
        ),
      ),
    );
  }
}
/*
class FirebaseApi {
  final DatabaseReference _tokensRef = FirebaseDatabase.instance.reference().child('tokens');

  Future<void> registrarToken(String token) async {
    await _tokensRef.push().set({'token': token});
  }
}*/
