
#include <SoftwareSerial.h>
#include <Wire.h>



#include <Wire.h>
#include "Arduino.h"
#include "SoftwareSerial.h"

SoftwareSerial port(12, 13);

byte state = 0;
byte message[3];

void setup() {

  Wire.begin(0x07);             // join i2c bus with address #7
  Wire.onRequest(requestEvent); // register event
  Wire.onReceive(receiveEvent); // register event
  Serial.begin(9600);           // start serial for output
  port.begin(9600);

  Serial.println("Test started!");

}

void loop() {
  switch (state) {
    case 0:
      state = 1;
      //state = s;
      break;
    case 1:
      state = 2;
      break;
    case 2:
      state = 0;
      break;
  }
  delay(10000);
}

// function that executes whenever data is requested by master
// this function is registered as an event, see setup()
void requestEvent() {
    Serial.println("Data requested ");
    
    Wire.write(state); // respond with message of 1 byte as expected by master
    Serial.println(state);
    
    
}

// function that executes whenever data is received from master
// this function is registered as an event, see setup()
void receiveEvent(int howMany) {
    Serial.print("# of Bytes to recv: ");
    int i = Wire.available();
    Serial.print(i);
    Serial.print(" - ");
    i = 0;
    char d='z';
    while(Wire.available())
    {
      byte b = Wire.read();
      Serial.print(b);
      d = (char)(b);
      i ++;
    }
    Serial.println(" ");
    
    Serial.println(d);
    Serial.println(" ");
    Serial.println("Data received successfully");
}
