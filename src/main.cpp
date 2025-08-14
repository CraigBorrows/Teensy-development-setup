#include "Arduino.h"
#include "pins_arduino.h"  // Let's test another Teensy header
#include "HardwareSerial.h"  // And another one

#include "SPI.h"



// Test some Teensy-specific types
void setup() {
  Serial.begin(9600);
  pinMode(LED_BUILTIN, OUTPUT);

  // Test if CLion recognizes these Teensy types/functions
  digitalWriteFast(13, HIGH);  // Teensy-specific function
  uint32_t freq = F_CPU;       // Teensy-specific macro
}

void loop() {
  digitalWrite(LED_BUILTIN, HIGH);
  delay(100);
  digitalWrite(LED_BUILTIN, LOW);
  delay(100);
  Serial.println("Hello from Teensy!");
}