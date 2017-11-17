#include <SPI.h>

#include <SoftwareSerial.h>
#include <Wire.h>

#include "Arduino.h"
#include "SoftwareSerial.h"

SoftwareSerial port(12, 13);

//rangefinder variables
int nVals = 0;
uint16_t Measurements[8];
uint8_t Measurements8[16];
uint8_t g_SpiBuffer[255];
volatile uint8_t g_BufferPos;
volatile uint8_t g_BytesToExpect;
volatile bool g_fProcessSPIBuffer;
volatile bool g_fIsReset;

//data transfer variables
boolean suspend=false;
int index = 0;

void setup (void)
{
  
  Serial.begin (115200);   // debugging
  Wire.begin(0x07);             // join i2c bus with address #7
  Wire.onRequest(requestEvent); // register event
  Wire.onReceive(receiveEvent); // register event
  
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
  Serial.println("\nstarting test");
}  // end of setup


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

//Software reset
void(* resetFunc) (void) = 0; //declare reset function @ address 0

// main loop - wait for flag set in interrupt routine
void loop (void)
{
  /* Runs the interrupt servicing to allow rangefinder data collection.
   * Where an I2C read command (request event) is sent to the arudino, the current rangefinder data
   * (stored in Measurements) is copied across and held in the Measurements8 matrix.
   * Until the final value of this matrix has been put on the I2C bus, the suspend flag is active, indicating 
   * that transfer into the Measrements8 matrix is suspended.
   * Where a message timing conflict occurs due to the ISR clashing with the I2C, an exception is recognised and handled
   */
  
  if (suspend){
    interrupts();
      Serial.println("suspended data:");
        Serial.print("======");
        for (uint8_t i = 0; i < 16; i++)
        {
          Serial.print(Measurements8[i], DEC);
          if (i<15)
          {
            Serial.print(",");
          }
        }
        Serial.println("======");
  } else {

  noInterrupts();
  nVals=0;
  if (g_fProcessSPIBuffer)
  {
    g_fProcessSPIBuffer = false;
    //Serial.println("Processing buffer");
    
    memcpy((uint8_t*)Measurements, g_SpiBuffer, g_BufferPos);
    nVals = g_BufferPos/2;    
    
    if (!suspend) {
      if (nVals==8) {
        uint8_t idx = 0;
        for( uint8_t i = 0; i < 8; i++)
        {
          uint16_t m = Measurements[i];
          uint8_t b1 = (uint8_t)(m & 0x00FF);
          uint8_t b2 = (uint8_t)((m & 0xFF00) >> 8);
          Measurements8[idx++] = b1;
          Measurements8[idx++] = b2;
        }
      }
    }
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
    Serial.print("#");
  }
  interrupts();
  Serial.print("  NVALS is: ");
  Serial.print(nVals);
  
  
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
  }
  
  Serial.print("; Index is: ");
  Serial.println(index);

  //raising this will slightly lower the chance of invalid sensor values and will also slightly lower the chance of timing conflicts
  delay(100);
  
}  // end of loop

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



// function that executes whenever data is requested by master through an 'I2C read'
// this function is registered as an event, see setup()
void requestEvent() {
  
    Serial.println("Data requested ");
            
    if (nVals==8) {
    uint8_t m1 = Measurements8[index++];
    
    Serial.println();
    Serial.print("SENDING DATA: ");
    Serial.println(sizeof(Measurements8));

    //255 is a reserved value -> equivalent to a signed byte -1
    if (m1 == 255)
      m1=254;
      
    Wire.write(m1);
    } else {
      //sensor registry exception, not all values present in Measurements8
      Serial.println("EXCEPTION++++++++++++++");
      Wire.write(-1);
      //Reset parameters
      suspend=false;
      index=0;
    }
    if (index>15) {
      index=0;
     suspend=false;
    }

    Serial.println();
}

// function that executes whenever data is received from master
// this function is registered as an event, see setup()
void receiveEvent(int howMany) {
   Serial.println("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
    char d;
    byte b;
    int i = Wire.available();
    Serial.print(i);
    Serial.print(" - ");
     while(Wire.available())
    {
     b = Wire.read();
      d = (char)(b);
    }
    Serial.println("b is::::::");
    Serial.println(b);
    //I2C initiated arduino software reset
    if (d=='E')
      resetFunc();
   suspend=true;

   
}



