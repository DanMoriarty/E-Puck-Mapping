%% Script for getting rangefinder data
% To use, must be within the ePic2 home folder; epuck must be connected and
% arduino program: Rangefinder_Only.ino must be uploaded on the arduino.
% e-Puck connection must be reliable at this stage - consider running
% BTMatlabConfigTest
% Arduino over bluetooth must be reliable (in terms of timing and COM ports)

% %% Clear environment
% try 
%     ePic = disconnect(ePic)
% catch
% end
% clearvars();
% clc
% close all

% %% Initialise a connection
% %Must be paired over bluetooth with e-puck
% %Bluetooth firmware (eg BTcom) must be on the epuck or it must be operating
% %in such a way that it can translate asercom commands over a UART
% %connection
% 
% ePic=ePicKernel
% %port = input('What COM port? ''COMXX''\n');%'COM6';
% 
% ePic=connect(ePic,'COM6')
% flush(ePic);
% 
% %assert(ePic.param.connected ~= 0)

% %%
% [ranges, badsensorindex] = getRangefinderData( ePic);

%% Loop through the function
badsensorindex=0;
caught=false;
while(badsensorindex~=-1&&~caught)
    try
    tic
    [ranges, badsensorindex] = getRangefinderData( ePic);
    time = toc
    if ~isnan(badsensorindex)
        badsensorindex
    end
    pause(0.3)
    ranges
    catch
        %reasons for error: timeout
        caught=true;
        input('restart the arduino, then hit enter')
        pause(1);
    end
end

echodemo BTMatlabConfigTest
%% Software Arduino Restart

flush(ePic);
write(ePic,'W,14,0,69') %send 'E' for error %%%%not yet handled in arduino code
a = read(ePic);
