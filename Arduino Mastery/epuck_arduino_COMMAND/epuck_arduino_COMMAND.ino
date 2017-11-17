
#include <SoftwareSerial.h>
#include <Wire.h>
#include "Arduino.h"
#include "SoftwareSerial.h"

SoftwareSerial port(12, 13);

/*Communication variables*/
byte state = 0;
byte data;
char STATE = 'A'; //awating
int commandSent = 0;

/*data and sensor variables*/
byte currentPos[] = {0,0};
byte prox[16];
byte F[]={0}; //general register
byte prev = 0;
int index = 0;
int readingSensor = 0;
int readWhileWrite = 0;


void setup() {

  Wire.begin(0x07);             // join i2c bus with address #7
  Wire.onRequest(requestEvent); // register event
  Wire.onReceive(receiveEvent); // register event
  Serial.begin(9600);           // start serial for output
  port.begin(9600);

  Serial.println("Test started!");

}

/*Prints the state and F register contents every 2 sec*/
void loop() {
  //update state in here
  Serial.print("STATE is: ");
  Serial.println(STATE);
  Serial.print("F is: ");
  Serial.println(F[0]);
  delay(2000);
}

/*Returns some defined speed; replace with a controller. This speed is sent to the E-Puck motors by the Matlab Control program*/
byte* getSpeed() {
  static byte d[] = {10, 10, 00, 30};
  //put controller things here
  return d;
}

/*Function that sends data if the state is one that requires data sent*/
byte sendData() {
  //byte speeds[] = {10,10,00,30};
  switch (STATE) {
      case 'S': {//Request speed command
        byte* a;
        a = getSpeed();
        byte val = *(a+index);
        index++;
        if (index>3) {
          index=0;
          commandSent = 0;
          STATE = 'A';
        }
        return val;
      }
      
      default: {
        Serial.println("default");
        break;
      }
  }
  byte p = 0;
  return p;
}

// function that executes whenever data is requested by master through an 'I2C read'
// this function is registered as an event, see setup()
void requestEvent() {
    Serial.println("Data requested ");
    //state = 3;
    if (!commandSent) {
      Wire.write(STATE); // respond with message of 1 byte as expected by master
      
    }else {
      switch (STATE) {
        case 'S': {
          data = sendData();
          Wire.write(data);
          //Serial.println(data[0]);
          break;
        }
      }
    }
      
    
}

// function that executes whenever data is received from master
// this function is registered as an event, see setup()
void receiveEvent(int howMany) {
    /*if (readWhileWrite) {
      readWhileWrite = 0;
      return;
    }
    */
    Serial.print("# of Bytes to recv: ");
    int i = Wire.available();
    Serial.print(i);
    Serial.print(" - ");
    i = 0;
    char d;
    while(Wire.available())
    {
      byte b = Wire.read();
      Serial.print(b);
      d = (char)(b);
      i ++;
    }
    if (!readingSensor) {
      switch (d) {
        /*Matlab requesting instruction (command) from arduino*/
        case 'C': {//Request command 
          Serial.println("command requested");
          STATE = 'S'; //change state to speed
          commandSent = 1;
          //Serial.print("STATE = ");
          //Serial.println(STATE);
          break;
        }
        /*requesting arduino proximity data*/
        case 'N': {
          index = 0;
          //copy prox into old prox array here
          STATE = 'N';
          readingSensor = 1;
          commandSent = 0;
          break;
        }
        /*requesting F register data*/
        case 'F': {
          index = 0;
          STATE = 'F';
          readingSensor = 1;
          commandSent = 0;
          break;
        }
      }
    }
    else {
      
        switch (STATE) {
          case 'N': {//Receiving Prox data
            prox[index] = d;
            index++;
            if (index>15) {
              index = 0;
              readingSensor = 0;
              STATE = 'A';
            }
            break;
          }
          case 'F': {//Receiving 1 byte of data
            Serial.println("entered F");
            F[index] = d;
            index++;
            if (index>0) {
              index = 0;
              readingSensor = 0;
              STATE = 'A';
            }
            break;
          }
          default: {
            Serial.println("entered default");
            readingSensor = 0;
          }
        
      
      }
    }
    
    Serial.println(" ");
    Serial.println(" ");
    Serial.println("Data received successfully");
}
