function [ ACK ] = SendArduinoData( ePic, accelEP, gyro, prox, odom)
%SendArduinoData Sends the epuck sensor data from the epuck to arduino
flush(ePic);

%% ePuck Accelerometer Data
flush(ePic);
write(ePic,'W,14,0,88'); %send X to indicate incoming accelerometer data
ack  = read(ePic);
if (~ack)
    write(ePic,'W,14,0,88'); % send X to indicate Accel data
    ack  = read(ePic);
    if (~ack)
        'could not do first write'
        ACK = -1;
        return
    end
end
for i =1:3 %x,y,z
    
    b = num2str(accelEP(i));
    b=num2str(b);
    %add leading 0's if not 4digits
    while (length(b)<4)
        b = strcat('0',b);
    end
    %because values are of magnitude 10^4, split across 2 bytes
    b1 = b(1:2);
    b2 = b(3:4);
    %write first byte
    write(ePic,['W,14,0,' b1]);
    ack  = read(ePic);
    time = 0;
    while (time<10)&&(ack(1)~='w')
        try
            ack  = read(ePic);
        catch
            
        end
        time=time+1;
    end
    if (time>=10)
        'accel data1 sent but not acknowledged from arduino'
        ACK = -1;
        return;
    end
    pause(0.1);
    %write second byte
    flush(ePic);
    write(ePic,['W,14,0,' b2]);
    ack  = read(ePic);
    time = 0;
    while (time<10)&&(ack(1)~='w')
        try
            ack  = read(ePic);
        catch
            
        end
        time=time+1;
    end
    if (time>=10)
        'accel data2 sent but not acknowledged from arduino'
        ACK = -1;
        return;
    end
    pause(0.1);

end

% %% ePuck Gyro Data
% 
% %%%%%%%Currently only sends 2 bytes, this is ok if gyro data is between
% %%%%%%%0000 and 9999... or between -4999 and 4999
% %%%%%%%otherwise will have to send 3 bytes per number and parse
% %%%%%%%apppropriately
% flush(ePic);
% write(ePic,'W,14,0,98'); % send g to indicate gyro data
% ack  = read(ePic);
% if (~ack)
%     write(ePic,'W,14,0,98'); % send N to indicate gyro data
%     ack  = read(ePic);
%     if (~ack)
%         'could not do first write'
%         ACK = -1;
%         return
%     end
% end
% pause(0.1);
% for i =1:3 %x,y,z
%     
%     b = num2str(gyro(i));
%     b=num2str(b);
%     %add leading 0's if not 4digits
%     while (length(b)<4)
%         b = strcat('0',b);
%     end
%     %because values are of magnitude 10^4, split across 2 bytes
%     b1 = b(1:2);
%     b2 = b(3:4);
%     %write first byte
%     write(ePic,['W,14,0,' b1]);
%     ack  = read(ePic);
%     time = 0;
%     while (time<10)&&(ack(1)~='w')
%         try
%             ack  = read(ePic);
%         catch
%         end
%         time=time+1;
%     end
%     if (time>=10)
%         'gyro data1 sent but not acknowledged from arduino'
%         ACK = -1;
%         return;
%     end
%     pause(0.1);
%     %write second byte
%     flush(ePic);
%     write(ePic,['W,14,0,' b2]);
%     ack  = read(ePic);
%     time = 0;
%     while (time<10)&&(ack(1)~='w')
%         try
%             ack  = read(ePic);
%         catch
%         end
%         time=time+1;
%     end
%     if (time>=10)
%         'gyro data2 sent but not acknowledged from arduino'
%         ACK = -1;
%         return;
%     end
%     pause(0.1);
% end
%% ePuck Prox Data
flush(ePic);
write(ePic,'W,14,0,78'); % send N to indicate gyro data
ack  = read(ePic);
if (~ack)
    write(ePic,'W,14,0,78'); % send N to indicate gyro data
    ack  = read(ePic);
    if (~ack)
        'could not do first write'
        ACK = -1;
        return
    end
end

for i =1:8 %x,y,z
    
    b = num2str(prox(i));
    b=num2str(b);
    %add leading 0's if not 4digits
    while (length(b)<4)
        b = strcat('0',b);
    end
    %because values are of magnitude 10^4, split across 2 bytes
    b1 = b(1:2);
    b2 = b(3:4);
    %write first byte
    write(ePic,['W,14,0,' b1]);
    ack  = read(ePic);
    time = 0;
    while (time<10)&&(ack(1)~='w')
        try
            ack  = read(ePic);
        catch
            break
        end
        time=time+1;
    end
    if (time>=10)
        ACK = -1;
        'prox data1 sent but not acknowledged from arduino' 
        i
        return;
    end
    pause(0.1);
    %write second byte
    flush(ePic);
    write(ePic,['W,14,0,' b2]);
    ack  = read(ePic);
    time = 0;
    while (time<10)&&(ack(1)~='w')
        try
            ack  = read(ePic);
        catch
            
        end
        time=time+1;
    end
    if (time>=10)
        ACK = -1;
        'prox data2 sent but not acknowledged from arduino' 
        i
        return;
    end
    pause(0.1);
end

%% ePuck Odometry Data
flush(ePic);
write(ePic,'W,14,0,79'); % send O to indicate odom data
ack  = read(ePic);
if (~ack)
    write(ePic,'W,14,0,79'); % send O to indicate odom data
    ack  = read(ePic);
    if (~ack)
        'could not do first write'
        ACK = -1;
        return
    end
end

for i =1:3 %x,y,theta
    
    b = num2str(odom(i));
    b=num2str(b);
    %add leading 0's if not 4digits
    while (length(b)<4)
        b = strcat('0',b);
    end
    %because values are of magnitude 10^4, split across 2 bytes
    b1 = b(1:2);
    b2 = b(3:4);
    %write first byte
    write(ePic,['W,14,0,' b1]);
    ack  = read(ePic);
    time = 0;
    while (time<10)&&(ack(1)~='w')
        try
            ack  = read(ePic);
        catch
            break
        end
        time=time+1;
    end
    if (time>=10)
        ACK = -1;
        'odom data1 sent but not acknowledged from arduino' 
        i
        return;
    end
    pause(0.1);
    %write second byte
    flush(ePic);
    write(ePic,['W,14,0,' b2]);
    ack  = read(ePic);
    time = 0;
    while (time<10)&&(ack(1)~='w')
        try
            ack  = read(ePic);
        catch
            
        end
        time=time+1;
    end
    if (time>=10)
        ACK = -1;
        'odom data2 sent but not acknowledged from arduino' 
        i
        return;
    end
    pause(0.1);
end
%%
ACK=1;
end