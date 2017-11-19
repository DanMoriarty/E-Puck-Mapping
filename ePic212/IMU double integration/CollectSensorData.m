function [ accelEP, gyro, prox, speed, pos ] = CollectSensorData( ePic )
%CollectSensorData Collects sensor data from the epuck and arduino

flush(ePic);

%% ePuck Accelerometer
write(ePic,'A');
a = read(ePic); %returns string buffer: 'a,####,####,####'
a = strsplit(a,',');
accx = str2num(a{2});
accy = str2num(a{3});
accz = str2num(a{4});
%will need to confirm if these axes are correct

%% ePuck Gyro
flush(ePic);
write(ePic,'g');
a = read(ePic); %returns string buffer: 'a,####,####,####'
a = strsplit(a,',');
agyrx = str2num(a{2});
agyry = str2num(a{3});
agyrz = str2num(a{4});
%will need to confirm if these axes are correct

%% ePuck Proximity
write(ePic,'N');
a = read(ePic); %returns string buffer: 'n,###,###,###,###,###,###,###,###'
a = strsplit(a,',');
aprox1 = str2num(a{2});
aprox2 = str2num(a{3});
aprox3 = str2num(a{4});
aprox4 = str2num(a{5});
aprox5 = str2num(a{6});
aprox6 = str2num(a{7});
aprox7 = str2num(a{8});
aprox8 = str2num(a{9});

%will need to know which proximity sensor is which
%also proximity sensors do not form a perfect circle, some are offcentre

%% ePuck Motor Speed
%can get from update function if it is called regularly, otherwise:
write(ePic,'E');
a = [];
a = read(ePic); %returns string buffer: 'e,###,###'
a = strsplit(a,',');
aLeftSpd = str2num(a{2});
aRightSpd = str2num(a{3});

%% ePuck Motor Position
%can get from update function if it is called regularly, otherwise:
write(ePic,'Q');
a = read(ePic); %returns string buffer: 'q,###,###'
a = strsplit(a,',');
aLeftPos = str2num(a{2});
aRightPos = str2num(a{3});

%% Return Values
accelEP = [accx accy accz];
gyro = [agyrx agyry agyrz];
prox = [aprox1 aprox2 aprox3 aprox4 aprox5 aprox6 aprox7 aprox8];
speed = [aLeftSpd aRightSpd];
pos = [aLeftPos aRightPos];
end

