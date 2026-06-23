#include <WiFi.h>
#include <HTTPClient.h>
#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <math.h>

#define LCD_ADDRESS 0x27
LiquidCrystal_I2C lcd(LCD_ADDRESS, 16, 2);

// ===== Pins =====
const int sensorPin = 35;
const int pumpPin   = 26;

// ===== Relay Logic =====
const int RELAY_ON  = HIGH;
const int RELAY_OFF = LOW;

// ===== Farm Name =====
const char* farmName = "HSB Smart Farm";

// ===== WiFi =====
const char* ssid = "$$$$$";
const char* password = "$$$$$$";

// ===== Backend =====
const char* baseUrl = "http://192.168.1.19:3000";
const char* apiPath = "/api/sensor/soil-moisture/readings";

// ===== Device Auth =====
const char* deviceId = "ESP32_01";
const char* deviceToken = "$$$$$$";

// ===== Calibration =====
int dryValue = 4095;
int wetValue = 1170;

// ===== Thresholds =====
const int DRY_TH = 25;
const int WET_TH = 70;

// ===== Safety =====
const unsigned long PUMP_MAX_ON_TIME = 30000;

// ===== Timers =====
unsigned long lastSendTime  = 0;
unsigned long lastReadTime  = 0;
unsigned long pumpStartTime = 0;

const unsigned long sendInterval = 10000;
const unsigned long readInterval = 2000;

// ===== Current Values =====
int currentRaw = 0;
int currentMoisture = 0;
const char* currentStatus = "OK";
bool pumpRunning = false;

// ===== Build URL =====
String buildFinalUrl() {
  String url  = String(baseUrl);
  String path = String(apiPath);
  while (url.endsWith("/")) url.remove(url.length() - 1);
  while (path.startsWith("/")) path.remove(0, 1);
  return url + "/" + path;
}

// ===== Read Sensor Average =====
int readSettledAverage(int samples = 20) {
  long sum = 0;
  for (int i = 0; i < samples; i++) {
    sum += analogRead(sensorPin);
    delay(5);
  }
  return sum / samples;
}

// ===== Convert Raw to Percent =====
int calcMoisturePercent(int raw) {
  long denom = (long)wetValue - (long)dryValue;
  if (denom == 0) return 0;
  float percent = ((raw - dryValue) * 100.0f) / denom;
  if (percent < 0) percent = 0;
  if (percent > 100) percent = 100;
  return round(percent);
}

// ===== Get Soil Status =====
const char* getStatus(int moisture) {
  if (moisture < DRY_TH) return "DRY";
  if (moisture >= WET_TH) return "WET";
  return "Normal";
}

// ===== Pump ON =====
void startPump() {
  if (!pumpRunning) {
    digitalWrite(pumpPin, RELAY_ON);
    pumpRunning = true;
    pumpStartTime = millis();
    Serial.println(">>> PUMP ON <<<");
  }
}

// ===== Pump OFF =====
void stopPump(const char* reason) {
  if (pumpRunning) {
    digitalWrite(pumpPin, RELAY_OFF);
    pumpRunning = false;
    Serial.print(">>> PUMP OFF - reason: ");
    Serial.println(reason);
  }
}

// ===== Pump Control =====
void controlPump() {
  unsigned long now = millis();
  if (pumpRunning && (now - pumpStartTime >= PUMP_MAX_ON_TIME)) {
    stopPump("SAFETY TIMEOUT");
    return;
  }
  if (!pumpRunning && currentMoisture < DRY_TH) startPump();
  if (pumpRunning && currentMoisture >= WET_TH) stopPump("WET THRESHOLD REACHED");
}

// ===== WiFi Connection =====
bool connectWiFi() {
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Connecting WiFi");
  WiFi.begin(ssid, password);
  Serial.print("Connecting WiFi");
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 12) {
    delay(250);
    Serial.print(".");
    attempts++;
  }
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\nWiFi Connected");
    Serial.println(WiFi.localIP());
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("WiFi Connected!");
    lcd.setCursor(0, 1);
    lcd.print(farmName);
    delay(800);
    return true;
  }
  Serial.println("\nWiFi FAILED");
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("WiFi Failed!");
  lcd.setCursor(0, 1);
  lcd.print(farmName);
  delay(800);
  return false;
}

// ===== Send to Backend =====
bool sendToBackend(int rawValue, int moisturePercent) {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi disconnected, reconnecting...");
    WiFi.reconnect();
    delay(3000);
    if (WiFi.status() != WL_CONNECTED) {
      Serial.println("Cannot send: WiFi not connected");
      return false;
    }
  }
  String finalUrl = buildFinalUrl();
  HTTPClient http;
  http.begin(finalUrl);
  http.addHeader("Content-Type", "application/json");
  http.addHeader("x-device-id", deviceId);
  http.addHeader("x-device-token", deviceToken);
  String jsonBody = "{";
  jsonBody += "\"moisturePercent\":" + String(moisturePercent);
  jsonBody += ",\"rawValue\":" + String(rawValue);
  jsonBody += "}";
  int code = http.POST(jsonBody);
  Serial.print("Response Code: ");
  Serial.println(code);
  Serial.println("Response: " + http.getString());
  http.end();
  return code >= 200 && code < 300;
}

// ===== LCD Update =====
void updateLCD() {
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Moist:");
  lcd.print(currentMoisture);
  lcd.print("% ");
  lcd.print(currentStatus);
  lcd.setCursor(0, 1);
  if (pumpRunning) lcd.print("PUMP: ON");
  else lcd.print("PUMP: OFF");
}

// ===== Setup =====
void setup() {
  Serial.begin(115200);
  pinMode(sensorPin, INPUT);
  pinMode(pumpPin, OUTPUT);
  digitalWrite(pumpPin, RELAY_OFF);
  pumpRunning = false;
  analogReadResolution(12);
  Wire.begin(21, 22);
  lcd.init();
  lcd.backlight();
  lcd.setCursor(0, 0);
  lcd.print(farmName);
  lcd.setCursor(0, 1);
  lcd.print("Starting...");
  delay(800);
  connectWiFi();
}

// ===== Loop =====
void loop() {
  unsigned long now = millis();
  if (now - lastReadTime >= readInterval) {
    lastReadTime = now;
    currentRaw = readSettledAverage();
    currentMoisture = calcMoisturePercent(currentRaw);
    currentStatus = getStatus(currentMoisture);
    Serial.println("\n===== Sensor Reading =====");
    Serial.print("Raw: ");
    Serial.println(currentRaw);
    Serial.print("Moisture: ");
    Serial.print(currentMoisture);
    Serial.println("%");
    Serial.print("Status: ");
    Serial.println(currentStatus);
    Serial.print("Pump: ");
    Serial.println(pumpRunning ? "ON" : "OFF");
    controlPump();
    updateLCD();
  }
  if (now - lastSendTime >= sendInterval) {
    lastSendTime = now;
    sendToBackend(currentRaw, currentMoisture);
  }
}
