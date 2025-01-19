
//  This script lets an LED shine when a trigger level is reached.
//  It also displays the current value on an LCD. We are using the
//  LiquidCrystal_I2C.h lib for this.
//        Made by Lasse Saalmann on the 19th of Jan 2025.



#include <LiquidCrystal_I2C.h>

int pushButton = 7;
int sensorPin = A0;
int sensorValue = 0;
int lastSensorValue = -1;  // To track changes in sensorValue
int triggerLevel = 900;

#define I2C_ADDR 0x27
#define LCD_COLUMNS 20
#define LCD_LINES 4

LiquidCrystal_I2C lcd(I2C_ADDR, LCD_COLUMNS, LCD_LINES);

void setup() {
  Serial.begin(9600);

  pinMode(9, OUTPUT);
  Serial.println("Pin 9 defined as OUTPUT");
  pinMode(pushButton, INPUT);
  Serial.println("Pin 7 defined as INPUT");

  lcd.begin(16, 2);
  lcd.clear();
  lcd.print("Setup Complete");
  delay(2000);  // Display the initial message for 2 seconds
  lcd.clear();

  Serial.println("Setup completed");
}

void loop() {
  sensorValue = analogRead(sensorPin);  // Read the value from the sensor

  // Only update the LCD if the value changes
  if (sensorValue != lastSensorValue) {
    lcd.clear();
    lcd.print("Sensor Value:");
    lcd.setCursor(0, 1);  // Move to the second line
    lcd.print(sensorValue);

    // Print to the serial monitor
    Serial.print("Sensor Value changed: ");
    Serial.println(sensorValue);

    lastSensorValue = sensorValue;  // Update the last sensor value
  }

  delay(10);  // Short delay for stability

  int buttonState = digitalRead(pushButton);
  digitalWrite(9, buttonState);

  // Provide verbose output for button state
  Serial.print("Button State: ");
  Serial.println(buttonState);

  // Handle trigger level logic with detailed messages
  if (sensorValue >= triggerLevel) {
    digitalWrite(9, LOW);
    Serial.println("Trigger level reached! Pin 9 set to LOW");
  } else {
    digitalWrite(9, HIGH);
    Serial.println("Below trigger level. Pin 9 set to HIGH");
  }
}
