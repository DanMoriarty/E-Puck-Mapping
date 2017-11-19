
#include <SoftwareSerial.h>
#include <Wire.h>

#include <SPI.h>

uint8_t g_SpiBuffer[255];
volatile uint8_t g_BufferPos;
volatile uint8_t g_BytesToExpect;
volatile bool g_fProcessSPIBuffer;
volatile bool g_fIsReset;


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
  Serial.println("Test started!");
  Wire.begin(0x07);             // join i2c bus with address #7
  Wire.onRequest(requestEvent); // register event
  Wire.onReceive(receiveEvent); // register event
  Serial.begin(115200);           // start serial for output
  port.begin(115200);
  
  // get ready for an interrupt 
  g_BufferPos = 0;   // buffer empty
  g_BytesToExpect = 0;
  g_fProcessSPIBuffer = false;
  g_fIsReset = false;

  // have to send on master in, *slave out*
  pinMode(SS, INPUT);
  pinMode(SCK, INPUT);
  pinMode(MISO, OUTPUT);

  // turn on SPI in slave mode
  SPCR |= _BV(SPE);

  // Turn on interrupts
  //SPCR |= _BV(SPIE);

  SPI.attachInterrupt();
  Serial.println("Test started!");

}

void loop() {
  //update state in here
  //Serial.print("STATE is: ");
  //Serial.println(STATE);
  //Serial.print("INDEX is: ");
  //Serial.println(index);
  uint16_t Measurements[8];
  
  int nVals = 0;
  if (g_fProcessSPIBuffer)
  {
    g_fProcessSPIBuffer = false;
    //Serial.println("Processing buffer");
    noInterrupts();
    memcpy((uint8_t*)Measurements, g_SpiBuffer, g_BufferPos);
    nVals = g_BufferPos/2;    
    interrupts();
    


    Serial.print("$");
    for (uint8_t i = 0; i < nVals; i++)
    {
      Serial.print(Measurements[i], DEC);
      if (i<7)
      {
        Serial.print(",");
      }
    }
    Serial.println("#");

  }


  noInterrupts();
  if (digitalRead(SS) == HIGH)
  {
    if (!g_fProcessSPIBuffer)
    {
      resetBuffers();
    }
  }
  interrupts();

//  if (digitalRead(SS) == HIGH)
//  {
//    Serial.println("^");
//  }
//  else
//  {
//    Serial.println("v");
//  }

  delay(100);
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
          case 'R': {
            /*
            int i = floor(index/2);
            uint16_t range = Measurements[i];
            if (index%2 ==0) {
              byte data = lowByte(word(range));
              Serial.print("low: ");
              Serial.print(data);
            }else {
              byte data = highByte(word(range));
              Serial.print("low: ");
              Serial.print(data);
            }
            Wire.write(data);
            //Serial.println(data[0]);
            
            index++;
            if (index>15) {
              index = 0;
              readingSensor = 0;
              STATE = 'A';
            }
            */
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
          commandSent = 0;
          
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
        case 'R': {
          index = 0;
          //copy into old array here
          STATE = 'R';
          Serial.println("Entered R.............");
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

// SPI interrupt routine
ISR (SPI_STC_vect)
{
  uint8_t recvByte = SPDR;  // grab byte from SPI Data Register
  SPDR = 0x01;

  if (g_fProcessSPIBuffer)
  {
    return;
  }

//  if ((digitalRead(SS) == LOW))
//  {
//    Serial.print("@ 0x"); Serial.println(recvByte, HEX);
//  }
  
  if (g_fIsReset)
  {
    if ((digitalRead(SS) == LOW))
    {
      g_fIsReset = false;
      g_BytesToExpect = recvByte;
      g_BufferPos = 0;
      g_fProcessSPIBuffer = 0;
      
      //Serial.print("Expecting Bytes: "); Serial.println(g_BytesToExpect, DEC);
    }
    return;
  }
  
  g_SpiBuffer[g_BufferPos] = recvByte;
  g_BufferPos++;
  
  //Serial.print(recvByte, HEX); Serial.print(", "); Serial.println(g_BufferPos, DEC);
  if (g_BufferPos == g_BytesToExpect)
  {
    g_fProcessSPIBuffer = true;
  }
}  // end of interrupt routine SPI_STC_vect

uint16_t SwapByteOrder(uint16_t inValue)
{
  uint8_t buffer[2];
  *buffer = inValue;

  uint8_t temp = buffer[0];
  buffer[0] = buffer[1];
  buffer[1] = temp;

  return *(uint16_t*)buffer;
}

void resetBuffers()
{
    g_BytesToExpect = 0;
    g_fProcessSPIBuffer = false;
    g_BufferPos = 0;
    memset(g_SpiBuffer, 0, sizeof(g_SpiBuffer));
    g_fIsReset = true;
    //Serial.println("@");
}
