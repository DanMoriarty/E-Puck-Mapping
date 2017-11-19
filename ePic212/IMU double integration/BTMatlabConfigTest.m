%% Script for controlling an E-puck via Matlab
% To use, must be within the ePic2 home folder
%
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
a
% %% Test I2C Read
% flush(ePic);
% write(ePic,'Y,14,0')
% a = read(ePic);
% a = [a read(ePic)]
% %% Test I2C Write
% flush(ePic);
% write(ePic,'W,14,0,67') %send 'C'
% a = read(ePic)
% %% Test I2C Write
% flush(ePic);
% write(ePic,'W,14,0,70')
% a = read(ePic)