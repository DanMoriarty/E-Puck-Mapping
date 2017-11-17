function [data, chunks] = readSpeed(ePic)
%READSPEED Used to obtain 2 speed values from the arduino that it has
%calculated prior
%   data = [leftspeed rightspeed]
%   chunks = each package received; since speed values can be > 255, need
%   to be sent as 2 bytes, therefore for 2 speeds -> 2 bytes for left 'XXYY', 2 bytes for right 'AABB'
%   -> 4 chunks [XX YY AA BB]

%   eg arduino has decided left speed as 330, right speed as 1000:
%        data = [330 1000]
%        chunks = [03 30 10 00]


data = zeros(1,2);        
chunks = zeros(1,4);      

flush(ePic);
write(ePic,'Y,14,0'); %send a read I2C to epuck, this will prompt arduino for information
in  = read(ePic); %'y,14,0'
leftspd1 = read(ePic); %'y,###
leftspd1 = strsplit(leftspd1,',');
leftspd1 = leftspd1{2};
leftspd1 = str2double(leftspd1)
chunks(1)=leftspd1;

flush(ePic);
write(ePic,'Y,14,0'); %send a read I2C to epuck, this will prompt arduino for information
in  = read(ePic); %'y,14,0'
leftspd2 = read(ePic); %'y,###
leftspd2 = strsplit(leftspd1,',');
leftspd2 = leftspd1{2};
leftspd2 = str2double(leftspd1)
chunks(2)=leftspd2;

data(1) = leftspd1*100 +leftspd2;

flush(ePic);
write(ePic,'Y,14,0'); %send a read I2C to epuck, this will prompt arduino for information
in  = read(ePic); %'y,14,0'
rightspd1 = read(ePic);%'y,###
rightspd1 = strsplit(rightspd1,',');
rightspd1 = rightspd1{2};
rightspd1 = str2double(rightspd1)
chunks(3)=rightspd1;

flush(ePic);
write(ePic,'Y,14,0'); %send a read I2C to epuck, this will prompt arduino for information
in  = read(ePic); %'y,14,0'
rightspd2 = read(ePic);%'y,###
rightspd2 = strsplit(rightspd2,',');
rightspd2 = rightspd2{2};
rightspd2 = str2double(rightspd2)
chunks(4)=rightspd2;

data(2) = rightspd1*100 +rightspd2;

data;
chunks;
end

