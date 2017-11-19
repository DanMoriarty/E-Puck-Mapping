function [ranges, badsensorindex] = getRangefinderData( ePic)
%Collects rangefinder data from the arduino through the epuck bluetooth protocol
%e-puck must be successully connected over bluetooth. This requires loading
%of the bluetooth demo hex file and successful running of the initalize
%function.
%
%% Error handling

%sensor board issues:
%-random restarting of arduino
%-null measurements
%-zero measurements
%-timing conflicts between interrupt routine and request event
%^These are all handled in software below

%This function does not solve the rangefinder sensor integration errors mentioned above. In some cases,
%sensor data is not sent to the arduino. And in some cases, I2C causes a
%conflict with the SPI interrupt routines. And in rare cases, the sensor
%board initiates an arduino restart.
%
%BADSENSORINDEX
%if a sensor returns a dubious value, this function returns it's index in the
%ranges matrix. It is up to the function that calls this function to
%resolve the bad information (eg through filtering, or holding previous values)
%
%if there has been a conflict, all captured sensor values are not trustworthy and the board
%is restarted. At this stage the badsensorindex is still default at NaN. If
%the next few readings are again invalid for whatever reason, a -1 index value is returned and a
%physical restart is recommended.
%
%If a reading is valid, the returned index is NaN.
%% VARIABLES
% DATA ARRAYS
ranges = zeros(1,8);
data = zeros(1,16);

% ERROR HANDLES
persistent numbadreadings;
if isempty(numbadreadings)
    numbadreadings=0;
end
interruptconflict=false;
badsensorindex = NaN;
maxsensorthresh = 9000;
%% INITIALIZE
% Initialize read
flush(ePic);
write(ePic,'W,14,0,67'); %send arbitrary letter 'C'
a = read(ePic);
%% READ
%Collect raw data
for i=1:16
    %perform read of 1byte packet
    flush(ePic);
    write(ePic,'Y,14,0');
    a = read(ePic); %command echo: 'Y,#,#'
    a = read(ePic); %returned data:  'Y,#'
    a=strsplit(a,',');
    a = str2num(a{2}); % '#'

    %conflict - not all sensor readings captured
    if a==-1 %error sentinel, sent when interrupt conflicts occur, deleting the messages matrix on the arduino
        fprintf('exception')
        errorval = i/2;
        interruptconflict=true;
        %don't want to continue collecting readings, end the process
        break
    end

    %Convert signed char to byte value
    if (a<0)
        a = 256+a;
    end

    data(i) = a;
end

data

%convert high bytes and low bytes in data to decimal integer value, for
%ranges
for i=1:length(data)/2
    d1 = data(2*i-1);
    d2 = data(2*i);
    
    ranges(i)=d1+d2*256;
    if d1==255||d2==255
        ranges(i)=-1;
    end
    
    if (ranges(i)>maxsensorthresh)||(ranges(i)==0);
        %dodgy sensor reading
        ranges(i)=0; %flatten to 0
        if isnan(badsensorindex)
        badsensorindex = i; %return the sensor index
        else
            badsensorindex = [badsensorindex i]; %already >1 unreliable sensor values
        end
    end
end

%% ERROR HANDLING

if interruptconflict||sum(ranges)==0
    numbadreadings=numbadreadings+1;
    fprintf('bad reading registered\n');
    interruptconflict=0;
else
    numbadreadings=0;
end

if (numbadreadings==2)
    %2 bad readings in a row - restart
    
    %Arduino malfunction - restart required
    fprintf('2 bad readings registered in a row; restarting\n');
        flush(ePic);
        write(ePic,'W,14,0,69') %send 'E' for error %%%%not yet handled in arduino code
        a = read(ePic);
    
    pause(0.5);
    ranges = getRangefinderData(ePic);
end

if (numbadreadings>3)
    %restart did not fix
    fprintf('too many bad reading registered\n');
    ranges = zeros(1,8);
    badsensorindex = -1;
end

end
