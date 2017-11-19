%% process workflow
%The main script for communication with an epuck, where the epuck is a
%communication master, but an arduino or matlab is the controller

%%%%%%%REMEMBER TO CHANGE 'COMXX' DEPENDING ON YOUR SYSTEM
TINIT = tic;
% ePic = initialize('COM9');
toc(TINIT)

%%
%note that the choice of STEPs below depends on how quickly things can be
%processed
%things can either be processed:
%-immediately online: processed quickly and returned instantaneously
%-laggy: processed slowly and returned at the next time step
%-infrequently online: processed slowly and returned at a selected sampling
%frequency

sent = 0;
lastCommand = 'NONE';
time = 0;

while(1)
     TLOOP = tic
    %make sure to wait for very small periods between steps
    pause(0.5);
%     TSTEP1 = tic;
    %STEP 1
    %get ePic sensor data
    [ accelEP, gyro, prox, speed, pos ] = CollectSensorData( ePic );
%     toc(TSTEP1)
    
    %STEP 1.5
    %Either:
    %a) run STEP 2, wait for some time to allow processing to finish, and then send
    %processed values as in STEP 3
    %b) send values from previous loop in STEP 3, then run STEP 2
    
%     TSTEP2 = tic;
    %In fully distrib architecture, this will be done on arduino as part of STEP 3
    %STEP 2
    %%%Process Epuck sensor data
    %here, process sensor data
    %ACCELERATION
    %-zero mean (use offline max and min values)
    %-calibrate (to get SI units)
    %-Kalman, LPF, EKF filtering (eg with accelARD)
    %VELOCITYESTEP
    %-integrate acceleration
    %POSITIONESTEP
    %-integrate velocityestEP
    %GYRO
    %-zero mean
    %-calibrate
    %-use to estimate both linear and angular velocity
    %PROX
    %-calibrate
    %SPEED
    %-Use to get idea of linear and angular velocity
    %...FINALLY
    %Store raw values
    %Overwrite raw values with processed values
%     toc(TSTEP2)
    
%     TSTEP3a = tic;
    %STEP 3a) - ARDUINO
    %Send processed values to arduino
%      sent = SendArduinoData( ePic, accelEP, gyro, prox, odom);
%     toc(TSTEP3a)
    
    %STEP 3b) - MATLAB
    %Save processed values in Matlab
    
    %STEP 3.5
    %potentially wait
    %Arduino may be processing its own sensor's data at this point:
    %-gps
    %-compass
    %-accelerometer
    
%     TSTEP39999 = tic;
    %IMAGINARY STEP 3.99999
    %Get other epuck data
    %may want to get other epuck maps or positions over bluetooth
    %This will either have to be implemented in firmware - too slow in matlab
    %or
    %This can be implemented in matlab:
    %save all current epic and epuck data
    %ePic=disconnect(ePic)
    %ePic = initialize(different COM port)
    %[ accelEP, gyro, prox, speed, pos ] = CollectSensorData( ePic );
    %ePic=disconnect(ePic)
    %ePic = initialize(original COM port)
%     toc(TSTEP39999)
    
%     TSTEP4a = tic;
    %STEP 4a) ARDUINO
    %Retrieve command from arduino and run the state machine
    %Arduino by now will either:
    %a) be able to send through commands based off data from previous
    %loop/s that has by now had time to be processed
    %b) be able to receive current data, process it quickly online, and
    %send a command off that
    %....
    %Arduino has 3 commands to epuck:
    % S - set motor speed -> sends through left and right speed
    % M - map -> sends through a map, one package at a time
    % B - Broadcast location -> sends through a location, either another
    % epuck or MATLAB
    [ prevCommand, val ] = GetArduinoCommand( ePic, lastCommand);
%     toc(TSTEP4a)
    
%     TSTEP4b = tic;
    %STEP 4b) MATLAB
    %Retrieve command from MATLAB and run the state machine
    %from the above sensor information, form pose and velocities
    %run controller program, which will return motor speeds
    %prevCommand = S, val = speed
    %if appropriate time, may wish to ask for something else, in which case
    %- set up a command
%     toc(TSTEP4b)

    pause(0.5);
%     TSTEP5 = tic;
    %STEP 5 - enact command
    switch prevCommand
        case 'S' %set the obtained speeds
            %val = speed
            flush(ePic);
            write(ePic,['D,' num2str(val(1)) ',' num2str(val(2))]) %set motor speed
            
    end
%     toc(TSTEP5)
    
    
    time=time+1;
    
    toc(TLOOP)
end
