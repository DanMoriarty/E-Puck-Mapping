# E-Puck-Mapping
Using Matlab to get an E-Puck to map an unfamiliar environment
------------------------------------------------------------------------------------------------------------------------------------------

## Description
The following files were used to control an E-Puck via bluetooth communication. 
It is assumed that the E-Puck is a recent model that comes equipped with an Arduino Uno attached over the I2C bus.

The following program includes methods to:
-Initialize and test bluetooth communication with the unit
-Access E-Puck sensor data
-Access information from, and transmit information to, the Arduino board
-Poll the E-Puck and arduino, establishing either Matlab or Arduino as the system master
-Establish a flexible control loop/sequence to accomodate localization, mapping, SLAM, message passing, etc

The program was designed in conjunction with he Multi-Agent Simulation program available here:
<....>

The program was established as part of a Master's Thesis in Engineering (Mechatronics), accessible here:
<....>

------------------------------------------------------------------------------------------------------------------------------------------

## Installation
The program requires installation of necessary E-Puck development programs. 
The program itself does not require the firmware of the E-Puck to be changed, one must simply use a firmware demo that facilitates bluetooth communication, eg BTCom.hex or the BTCom demo from the default demo suite of GCTronic.

ePic2 must be installed in order to communicate with the bot over Matlab. The method of communication early in the program development was to use ePic2 commands, but they have since been stripped back, yet some features are still relied upon, though can be replaced/rewritten. One may wish to write into the program the same functions/variables that ePic2 uses.

The program must be installed into the ePic home directory.


* Applications: important applications	
* Arduino Mastery: Virtual State machine and matlab arduino interfacing	
* IMU forward double integration: Method for accelerometer double integration (forwards detrending)
* Laser Rangefinder: code for accessing laser shield data
* ePic212: All code required for matlab control and bluetooth communication

Installation files
* BasicDemos (1).zip	
* DemoGCtronic-arduino (2).zip	
* DemoGCtronic-complete-rev135 (1).zip	
* e-puck-gna-svn-rev116 (1).zip	
* epic212.zip
