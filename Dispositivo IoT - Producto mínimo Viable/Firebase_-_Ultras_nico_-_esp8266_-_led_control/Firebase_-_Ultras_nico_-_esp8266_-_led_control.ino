#include <Arduino.h>
#if defined(ESP32)
#include <WiFi.h>
#elif defined(ESP8266)
#include <ESP8266WiFi.h>
#endif
#include <Firebase_ESP_Client.h>

// Provide the token generation process info.
#include "addons/TokenHelper.h"
// Provide the RTDB payload printing info and other helper functions.
#include "addons/RTDBHelper.h"

// Insert your network credentials
#define WIFI_SSID "****"
#define WIFI_PASSWORD "***************"

// Insert Firebase project API Key
#define API_KEY "******************************************"

// Insert RTDB URL
#define DATABASE_URL "*********************.firebaseio.com"

#define NomDispositivo "Garaje-IoT-1"

// Define Firebase Data object
FirebaseData fbdo;

FirebaseAuth auth;
FirebaseConfig config;

// Some important variables
int sValue;
bool signupOK = false;
int sdata = 0; // El valor del pulsador se almacenará en sdata.

// Ultrasonic sensor pins
const int trigPin = D5;
const int echoPin = D7;

// Define la velocidad del sonido en cm/us
#define SOUND_VELOCITY 0.034

long duration;
int distanceCm;
int estadoActual = 0;
int estadoAnterior = -1; // Valor inicial diferente para forzar primera impresión

void connectToWiFi() {
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    digitalWrite(D0, HIGH);
    delay(300);
    digitalWrite(D0, LOW);
  }
}

void setup() {
  Serial.begin(115200);
  pinMode(D4, OUTPUT);
  pinMode(D0, OUTPUT);
  pinMode(trigPin, OUTPUT); // Configura trigPin como salida
  pinMode(echoPin, INPUT);  // Configura echoPin como entrada
  connectToWiFi();

  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();

  /* Assign the api key (required) */
  config.api_key = API_KEY;

  /* Assign the RTDB URL (required) */
  config.database_url = DATABASE_URL;

  /* Sign up */
  if (Firebase.signUp(&config, &auth, "", "")) {
    Serial.println("ok");
    signupOK = true;
  }
  else {
    Serial.printf("%s\n", config.signer.signupError.message.c_str());
  }

  /* Assign the callback function for the long running token generation task */
  config.token_status_callback = tokenStatusCallback; // see addons/TokenHelper.h

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
}

void loop() {
  if (WiFi.status() != WL_CONNECTED) {
    connectToWiFi();
    Firebase.begin(&config, &auth); // Reinitialize Firebase connection
    Firebase.reconnectWiFi(true);
  }

  if (Firebase.ready() && signupOK) {
    if (Firebase.RTDB.getString(&fbdo, "/2/L1")) {
      if (fbdo.dataType() == "int") {
        sValue = fbdo.intData();
        Serial.println(sValue);
        if (sValue) {
          digitalWrite(D4, HIGH);
        } else {
          digitalWrite(D4, LOW);
        }
      }
    }
    else {
      Serial.println(fbdo.errorReason());
    }
    
    // Almacenar el nombre del dispositivo
    Firebase.RTDB.setString(&fbdo, "/2/id",NomDispositivo);
    Serial.println(NomDispositivo);
    
    // Lectura del sensor ultrasónico
    digitalWrite(trigPin, LOW);
    delayMicroseconds(2);
    digitalWrite(trigPin, HIGH);
    delayMicroseconds(10);
    digitalWrite(trigPin, LOW);

    // Lee el tiempo de viaje del sonido
    duration = pulseIn(echoPin, HIGH);
    distanceCm = duration * SOUND_VELOCITY / 2;

    Serial.print("Estado del sensor: ");
    Serial.println(estadoActual);
    Serial.print("cm: ");
    Serial.println(distanceCm);
    
    // Determina el estado actual
    if (distanceCm > 20) { // si la distancia medida es mayor a 20 centímetros
      estadoActual = 1;
    } else {
      estadoActual = 0;
    }

    // Almacenar el estado de L2
    Firebase.RTDB.setInt(&fbdo, "/2/L2", estadoActual);
    
  }
}
