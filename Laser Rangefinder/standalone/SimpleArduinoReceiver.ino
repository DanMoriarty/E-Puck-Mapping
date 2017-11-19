#include <SPI.h>


uint8_t g_SpiBuffer[255];
volatile uint8_t g_BufferPos;
volatile uint8_t g_BytesToExpect;
volatile bool g_fProcessSPIBuffer;
volatile bool g_fIsReset;

void setup (void)
{
  Serial.begin (115200);   // debugging

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



// main loop - wait for flag set in interrupt routine
void loop (void)
{
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

