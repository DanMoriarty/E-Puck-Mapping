function [ prevCommand, val ] = GetArduinoCommand( ePic, lastCommand)
%UNTITLED Sends a prompt to the arduino, asking for a command
%returns the command, and a value to go with that command

% lastCommand - char
% epic - epicKernel
%   Arduino can only send 1 byte at a time using read: 'Y,14,0'
lastCommand

switch lastCommand
    case 'S' %set speed
        [speed, chunks] = readSpeed(ePic);
        prevCommand = lastCommand;
        val = speed;
        return;
    case 'M' %sending epuck map: map data
        %do nothing for now
        %Use this for when the arduino needs to broadcast the map over
        %bluetooth, either to host or to other epucks
        return;
    case 'B' %sending epuck map: broadcast instruction
        %do nothing for now
        %Use this for when the arduino needs to broadcast the map over
        %bluetooth, either to host or to other epucks; indicates the target
        return;
    case 'R' %request rangefinder data
        %do nothing for now
        %Use this for when the arduino needs to broadcast rangefinder data
        %to matlab
        [ranges] = getRangefinderData(ePic)
        prevCommand = lastCommand;
        return;    
    case 'NONE'
        %No previous command given
        ' entered none' 
        
        % send a C to indicate prompt for a command
        flush(ePic);
        write(ePic,'W,14,0,67') 
        ack = read(ePic);
        if (ack~='w') 
            write(ePic,'W,14,0,67') % send a C to indicate prompt for a command
            ack = read(ePic);
            assert(~isempty(ack));
        end
        
        %get command
        flush(ePic);
        write(ePic,'Y,14,0'); %send a read I2C to epuck, this will read the arduino command
        ack  = read(ePic); %the command you just sent
        cmd = read(ePic); %the returned message 'y,###'
        
        cmd = strsplit(cmd,',');
        cmd = cmd{2};
%         cmd='S';
        cmd = str2num(cmd)
        [ prevCommand, val ] = GetArduinoCommand( ePic, cmd);
        return
    otherwise
        'otherwise entered'
        prevCommand='';
        val='';
        return;
end

end

