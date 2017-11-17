# Arduino Mastery
Without having to change the E-Puck firmware, allows the Arduino to issue speed commands to the E-Puck wheels.

How it works:
* Workflow file is the Control Loop
* Matlab will interrupt the E-Puck over bluetooth, to send a 'C' to the arduino, requesting a command. 
This command is something that the arduino needs done either by the E-Puck or in Matlab, 
but since the Arduino is a slave, it can't initiate this process itself, it must be polled by Matlab.
(currently, the only programmed command is to receive speed 'S', as calculated by the Arduino. 
But it could for example return an 'F', indicating to Matlab that the arduino will now transmit data in its F array)
* The arduino switches to state S and calculates a speed. At the moment, this speed is constant: [1010 30], which across 2 transmissions: [10 10 00 30]
* This speed is written to the I2C bus, and Matlab is expected to perform the necessary number of read operations

## Installation
* Upload the arduino command file. (the other is provided to help understand I2C; note that the epuck has its own I2C program)
* Save the matlab files in the Epic2 home folder
