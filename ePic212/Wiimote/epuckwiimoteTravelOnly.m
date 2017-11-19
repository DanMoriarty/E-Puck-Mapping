%% For controlling an Epuck with a wiimote
% Connect the wiimote using windows bluetooth manager
% Use Touchmote to map button presses to key presses in the command line
% eg up->'1'

close all
clear all
clc
%% Clear environment
try 
    ePic = disconnect(ePic)
catch
end

%clearvars();
%clc

close all

%% Initialise a connection
%Must be paired over bluetooth with e-puck
%Bluetooth firmware (eg BTcom) must be on the epuck or it must be operating
%in such a way that it can translate asercom commands over a UART
%connection

ePic=ePicKernel
%port = input('What COM port? ''COMXX''\n');%'COM6';

ePic=connect(ePic,'COM6')
flush(ePic);

%assert(ePic.param.connected ~= 0)

%% Write your program here
%Update once
ePic = update(ePic);
%% Test writing
%turn LED 3 on
data = int8([-76      3      1])
flush(ePic);
writeBin(ePic,data)
%%

%turn LED 3 off
data = int8([-76      3      0])
flush(ePic);
writeBin(ePic,data)

%% Test Reading
data = int8([-78 0])
flush(ePic);
writeBin(ePic,data)
prox = readBinSized(ePic,16)

% %% Test I2C Reading -> not possible with unicode, only ascii
% data = int8([-89 14 0]);
% flush(ePic);
% writeBin(ePic,data);
% I2C = readBinSized(ePic,1)

%% Test ASCII Write
flush(ePic);
write(ePic,'B,1') %turn body LED on
%%
flush(ePic);
write(ePic,'B,0') %turn body LED off
%% Test ASCII Read
flush(ePic);
write(ePic,'H')
a = read(ePic);
for i =1:27
    a = [a read(ePic)];
end

%% 
bodytoggle=false;
lastcmd='';
while(true)
    cmd = input('');
    switch(cmd)
        case 0
            fprintf('rest')
            speed = [0,0];
        
        case 1
            fprintf('up')
            if lastcmd==3
                speed=[0,0];
            else speed = [200,200];
            end
        
        case 2
            fprintf('right')
            if lastcmd==4
                speed = [0,0];
            else
                speed = [200,0];
            end
        
        case 3
            fprintf('down')
            if lastcmd==1
                speed = [0,0];
            else
                speed = [-200,-200];
            end
        
        case 4
            fprintf('left')
            if lastcmd==2
                speed = [0,0];
            else
                speed = [0,200];
            end
        
        case 9
            if bodytoggle
                fprintf('led on')
                flush(ePic);
                write(ePic,'B,1') %turn body LED on
                ack = read(ePic);
                bodytoggle=~bodytoggle;
            else
                fprintf('led off')
                flush(ePic);
                write(ePic,'B,0') %turn body LED off
                ack = read(ePic);
                bodytoggle=~bodytoggle;
            end
        case 8
    end
    fprintf('\n');
    speed
    flush(ePic);
    write(ePic,['D,' num2str(speed(1)) ',' num2str(speed(2))]);
    ack = read(ePic);
    
    lastcmd=cmd;

    end
