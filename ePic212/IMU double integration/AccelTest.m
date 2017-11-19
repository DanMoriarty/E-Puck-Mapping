%%
clear all
ePic = initialize('COM6')
%%
accel = [];
count = 0;
t=[0];
[ accelEP, gyro, prox, speed, pos ] = CollectSensorData( ePic );
%%
while (count<60)
    
    [ accelEP, gyro, prox, speed, pos ] = CollectSensorData( ePic );
    accel = [accel; accelEP(1) accelEP(2) accelEP(3)];
    
    count=count+1;
    t = [t; count];
end
%%
plot(t(1:size(accel,1),1),accel(1:end,1));
hold on
plot(t(1:size(accel,1),1),accel(1:end,2));
hold on
plot(t(1:size(accel,1),1),accel(1:end,3));
%%
%%
ACCEL = [];
count = 0;
t=[0];
toggle = -1;
tic
[ accelEP, gyro, prox, speed, pos ] = CollectSensorData( ePic );
toc
%%
while (count<60)
    if (mod(count,10)==0)
        toggle = -1*toggle;
        flush(ePic);
        write(ePic,['D' ',' num2str(10*count*toggle) ',' num2str(10*count*toggle)])
        ack = read(ePic);
    end
%     if (count == 10)
%         toggle = -1*toggle;
%         flush(ePic);
%         write(ePic,['D' ',' num2str(600*toggle) ',' num2str(600*toggle)])
%         ack = read(ePic);
%     end
    [ accelEP, gyro, prox, speed, pos ] = CollectSensorData( ePic );
    ACCEL = [ACCEL; accelEP(1) accelEP(2) accelEP(3)];
    
    count=count+1;
    t = [t; count];
end
flush(ePic);
write(ePic,'D,0,0');
ack = read(ePic);
%%
%%
plot(t(1:size(ACCEL,1),1),ACCEL(1:end,1));
hold on
plot(t(1:size(ACCEL,1),1),ACCEL(1:end,2));
hold on
plot(t(1:size(ACCEL,1),1),ACCEL(1:end,3));
movingAccel = ACCEL;

%% Discrete Integration of Accelerometer Data (X)

time = t;
dt = 0.5;

ACCEL = movingAccel(1:end,1);
velocity = zeros(size(ACCEL,1),1);

sum = 0;
for i = 1:size(ACCEL,1)
    sum = sum+ACCEL(i);
end
%mean = sum/size(ACCEL,1);
mean = ACCEL(1);

ACCEL = ACCEL-mean;

for i = 2:size(ACCEL,1)
    s = 0;
    for j = 2:i
        d = ACCEL(j)-ACCEL(j-1);
        s = s+ACCEL(j)*dt+0.5*dt*d;
    end
    velocity(i) = s;
    %d = ACCEL(i)-ACCEL(i-1);
    %velocity(i) = velocity(i-1) + ACCEL(i)*dt+0.5*dt*d; %trapezoidal
end
velocity(1)=[];

displacement= zeros(size(velocity,1),1);
for i = 2:size(velocity,1)
    s = 0;
    for j = 2:i
        d = ACCEL(j)-ACCEL(j-1);
        s = s+ACCEL(j)*dt+0.5*dt*d;
    end
    displacement(i) = s;
%     d = velocity(i)-velocity(i-1);
%     displacement(i) = displacement(i-1) + velocity(i)*dt+0.5*dt*d; %backwards piecewise
end
displacement(1)=[];

figure,
subplot(1,3,1), plot(time(1:size(ACCEL,1)),ACCEL(1:end))
title('Acceleration')
xlabel('seconds')
ylabel('m/s^2')
subplot(1,3,2), plot(time(1:size(velocity,1)),velocity(1:end))
title('Velocity')
xlabel('seconds')
ylabel('m/s')
subplot(1,3,3), plot(time(1:size(displacement,1)),displacement(1:end))
title('Displacement')
xlabel('seconds')
ylabel('m')

%% Discrete Integration of Accelerometer Data (Y)

time = t;
dt = 0.5;
velocity = zeros(size(ACCEL,1),1);
ACCEL = movingAccel(1:end,2);

sum = 0;
for i = 1:size(ACCEL,1)
    sum = sum+ACCEL(i);
end
%mean = sum/size(ACCEL,1);
mean = ACCEL(1);

ACCEL = ACCEL-mean;

for i = 2:size(ACCEL,1)
    s = 0;
    for j = 2:i
        d = ACCEL(j)-ACCEL(j-1);
        s = s+ACCEL(j)*dt+0.5*dt*d;
    end
    velocity(i) = s;
    %d = ACCEL(i)-ACCEL(i-1);
    %velocity(i) = velocity(i-1) + ACCEL(i)*dt+0.5*dt*d; %trapezoidal
end
velocity(1)=[];

displacement= zeros(size(velocity,1),1);
for i = 2:size(velocity,1)
    s = 0;
    for j = 2:i
        d = ACCEL(j)-ACCEL(j-1);
        s = s+ACCEL(j)*dt+0.5*dt*d;
    end
    displacement(i) = s;
%     d = velocity(i)-velocity(i-1);
%     displacement(i) = displacement(i-1) + velocity(i)*dt+0.5*dt*d; %backwards piecewise
end
displacement(1)=[];

figure,
subplot(1,3,1), plot(time(1:size(ACCEL,1)),ACCEL(1:end))
title('Acceleration')
xlabel('seconds')
ylabel('m/s^2')
subplot(1,3,2), plot(time(1:size(velocity,1)),velocity(1:end))
title('Velocity')
xlabel('seconds')
ylabel('m/s')
subplot(1,3,3), plot(time(1:size(displacement,1)),displacement(1:end))
title('Displacement')
xlabel('seconds')
ylabel('m')
%%
% %% HPF Filter
% [B,A] = butter(1,0.5,'high');
% filtmovingaccel = filter(B,A,ACCEL);
%% TRAPZ X
time = t;
dt = 0.5;
velocity = zeros(size(ACCEL,1),1);

ACCEL = movingAccel(1:end,1);
[B,A] = butter(10,0.1,'high');
%ACCEL = filter(B,A,ACCEL);
ACCEL(1)=[];
sum = 0;
for i = 1:size(ACCEL,1)
    sum = sum+ACCEL(i);
end
%mean = sum/size(ACCEL,1);
mean = ACCEL(1);

ACCEL = ACCEL-mean;
a = [];

for i = 1:size(ACCEL,1)
    %b = ACCEL(1:i,1);
    b = filter(B,A,ACCEL(1:i,1));
    a = [a; trapz(b)];
    
    
    
end
velocity = a;

a = [];
displacement= zeros(size(velocity,1),1);
for i = 1:size(velocity,1)
    b = velocity(1:i,1);
    a = [a; trapz(b)];
end
displacement = a;

figure,
subplot(1,3,1), plot(time(1:size(ACCEL,1)),ACCEL(1:end))
title('Acceleration')
xlabel('seconds')
ylabel('m/s^2')
subplot(1,3,2), plot(time(1:size(velocity,1)),velocity(1:end))
title('Velocity')
xlabel('seconds')
ylabel('m/s')
subplot(1,3,3), plot(time(1:size(displacement,1)),displacement(1:end))
title('Displacement')
xlabel('seconds')
ylabel('m')

%% TRAPZ X
time = t;
dt = 0.5;
velocity = zeros(size(ACCEL,1),1);

ACCEL = movingAccel(1:end,2);
[B,A] = butter(10,0.1,'high');
%ACCEL = filter(B,A,ACCEL);
ACCEL(1)=[];
sum = 0;
for i = 1:size(ACCEL,1)
    sum = sum+ACCEL(i);
end
%mean = sum/size(ACCEL,1);
mean = ACCEL(1);

ACCEL = ACCEL-mean;
a = [];

for i = 1:size(ACCEL,1)
    %b = ACCEL(1:i,1);
    b = filter(B,A,ACCEL(1:i,1));
    a = [a; trapz(b)];
    
    
    
end
velocity = a;

a = [];
displacement= zeros(size(velocity,1),1);
for i = 1:size(velocity,1)
    b = velocity(1:i,1);
    a = [a; trapz(b)];
end
displacement = a;

figure,
subplot(1,3,1), plot(time(1:size(ACCEL,1)),ACCEL(1:end))
title('Acceleration')
xlabel('seconds')
ylabel('m/s^2')
subplot(1,3,2), plot(time(1:size(velocity,1)),velocity(1:end))
title('Velocity')
xlabel('seconds')
ylabel('m/s')
subplot(1,3,3), plot(time(1:size(displacement,1)),displacement(1:end))
title('Displacement')
xlabel('seconds')
ylabel('m')
