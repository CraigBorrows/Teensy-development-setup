#include "Arduino.h"

// Test some Teensy-specific types
void setup() {
  Serial.begin(115200);
  pinMode(LED_BUILTIN, OUTPUT);

  // Test if CLion recognizes these Teensy types/functions
  digitalWriteFast(LED_BUILTIN, HIGH);  // Teensy-specific function
}

void loop() {
  digitalWrite(LED_BUILTIN, HIGH);
  delay(100);
  digitalWrite(LED_BUILTIN, LOW);
  delay(100);
  Serial.println("Hello from Teensy!");
}