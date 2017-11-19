
#include <SoftwareSerial.h>
#include <Wire.h>



#include <Wire.h>
#include "Arduino.h"
#include "SoftwareSerial.h"

SoftwareSerial port(12, 13);

byte state = 0;
char STATE = 'A'; //awaiting
byte currentPos[] = {0,0};
int commandSent = 0;
byte data;
int index = 0;
byte prox[16];
byte accel[3];
byte gyro[3];
int readingSensor = 0;
byte F[]={0};
int readWhileWrite = 0;
byte prev = 0;
byte toggle=0;
byte d1 = 0;
byte d2 = 0;

void setup() {

  Wire.begin(0x07);             // join i2c bus with address #7
  Wire.onRequest(requestEvent); // register event
  Wire.onReceive(receiveEvent); // register event
  Serial.begin(9600);           // start serial for output
  port.begin(9600);

  Serial.println("Test started!");

}

void loop() {
  //update state in here
  Serial.print("STATE is: ");
  Serial.println(STATE);
  Serial.print("F is: ");
  Serial.println(F[0]);
  toggle=!toggle;
  Serial.print(" toggle: ");
  Serial.println(toggle);
  delay(2000);
}

byte* getSpeed() {
  static byte d[] = {03, 00, 00, 30};
  if (toggle) {
    d[0]=00;
    d[3]=00;
  } else {
    d[0]=03;
    d[3]=30;
  }
  //put controller things here
  return d;
}

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
          readingSensor=0;
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

void resetState() {
  STATE='A';
  readingSensor=0;
  commandSent=0;
  index=0;
  
}

// function that executes whenever data is requested by master through an 'I2C read'
// this function is registered as an event, see setup()
void requestEvent() {
    Serial.println("Data requested ");
    Serial.println("ReadingSensor is:");
          Serial.println(readingSensor);
    //state = 3;
    if (!commandSent) {
      Wire.write(STATE); // respond with message of 1 byte as expected by master
      
    }else {
      if (readingSensor <= 1) {
        if(STATE!='A') {
          Serial.println("State is not A");
          readingSensor=2;
          Serial.println("ReadingSensor is:");
          Serial.println(readingSensor);
          Wire.write(STATE);
        } else {
          Wire.write(STATE);
          Serial.println("State is A");
        }
      } else {
        switch (STATE) {
          case 'S': {
            data = sendData();
            Wire.write(data);
            //Serial.println(data[0]);
            break;
          }
          default: {
            //trying to read data when supposed to be writing
            resetState();
          }
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
        case 'C': {//Request command 
          Serial.println("command requested");
          STATE = 'S'; //change state to speed
          commandSent = 1;
          
          //Serial.print("STATE = ");
          //Serial.println(STATE);
          break;
        }
        case 'N': {
          index = 0;
          //copy prox into old prox array here
          STATE = 'N';
          readingSensor = 1;
          commandSent = 0;
          break;
        }
        case 'X': {
          index = 0;
          //copy accel into old accel array here
          STATE = 'X';
          readingSensor = 1;
          commandSent = 0;
          break;
        }
        case 'G': {
          index = 0;
          //copy gyro into old gyro array here
          STATE = 'G';
          readingSensor = 1;
          commandSent = 0;
          break;
        }
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
            if (index%2 ==0) {
              byte d1 = d;
            }else {
              byte d2 = d;
              prox[index] = d1*100 + d2;
              Serial.print("prox at index is:");
              Serial.println(prox[index]);
            }
            index++;
            if (index>31) {
              index = 0;
              readingSensor = 0;
              STATE = 'A';
            }
            break;
          }
          case 'G': {//Receiving Gyro data
            if (index%2 ==0) {
              byte d1 = d;
            }else {
              byte d2 = d;
              accel[index] = d1*100 + d2;
              Serial.print("gyro at index is:");
              Serial.println(gyro[index]);
            }
            index++;
            if (index>5) {
              index = 0;
              readingSensor = 0;
              STATE = 'A';
            }
            break;
          }
          case 'X': {//Receiving Accel data
            if (index%2 ==0) {
              byte d1 = d;
            }else {
              byte d2 = d;
              accel[index] = d1*100 + d2;
              Serial.print("accel at index is:");
              Serial.println(accel[index]);
            }
            index++;
            if (index>5) {
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
            //readingSensor = 0;
            
          }
        
      
      }
    }
    
    
  
    
    Serial.println(" ");
    Serial.println(" ");
    Serial.println("Data received successfully");
}
