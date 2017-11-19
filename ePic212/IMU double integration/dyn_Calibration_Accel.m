%% Script for experimenting with getting forward displacement and velocity from fast acceleration data

close all
%clear all
close all

clc
%% Gather Data
%Data is acceleration data collected form the arduino accelerometer sensor,
%in the direction of forward motion. Scenarios that involve frequent
%stopping will produce a better output, as the integrator can recalibrate
%to offset any drift due to accelerometer hysteresis

%Data must have sample time of 1ms
%Using data that has a different sample time will require changing of the
%dt variable in the integrator function

%Data must be taken from an initial state of rest - ie the epuck should not
%be accelerating when the first reading is taken

%Different scenarios will involve different levels of noise on the
%accelerometer, different analogue steady state values when at rest, and 
%different lengths of stop/travel time, all these must be accounted for and 
%tuned within the integrator function 

%Acceleration data
%filename = 'Book1.csv'
 %filename = 'allaccel.csv'
 %filename = 'backforth.csv'
 filename = 'forward.csv'
 filename = 'noepuckaccels.csv'
data = csvread(filename,2);

%% Calibration
t = 1:size(data,1);
t=t';
plot(t(1:end,1),data(1:end,1));
title('x acceleration')
% figure, plot(t(1:end,1),data(1:end,2));
% title('y')
% figure, plot(t(1:end,1),data(1:end,3));
% title('z')

d = data(1:end,1);
%%
%setting data to be zero mean
d = d-369; %X
d=d+369;
%d = d-350; %Y
%d = d-397; %Y
%d = d-487; %Z
figure, plot(t(1:end,1),d(1:end));
title('x acceleration (zero mean)')
%%
%Converting into SI units
d=d*9.81/70;

%% Initialization
s=0; %rolling sum
point = []; %points less than variance threshold
v = []; %velocity placeholder
V = []; %variance array placeholder
next = []; %zero acceleration point indexes
add=false; %flag for adding to next array


%time data
t = 1:size(d,1);
t=t';
%% Tuning Parameters
csample = 5;

thresh = 0.01;%0.01;


%% Rest Point Extraction

for i = csample+1:numel(d)
    s=0;
    mean = sum(d(i-csample:i,1))/csample; %get mean for the current window
    
    %get covariance
    for j = i-csample:i
        s = s+abs(d(j)-mean);
    end
    var = s/csample;
    
    %check if lower than rest threshold
    if var<thresh
        
        next=[next;i];
        if add==false
            next=[next;i];
        end
        add = true;
        %v=[var;v];
        %point = [point;i];
    else
        if add==true
            add=false;
        end
    end
end

next
%%
d = data(1:end,1);

%setting data to be zero mean
base = 0;
d = d-base; %X

d = d/70;
%%

accels=zeros(1,10);

for i =2:numel(next)
    T=[];
    k = next(i-1);
    
    %collect data up to next point of rest
    for j = 1:next(i)
        T = [T;d(k:j,1)];
    end
    
    %get mean of last 10 data points
    meansum=0;
    for j = 1:min(10,
        
        accels(j)=data(k-j+1);
        meansum=meansum+accels(j);
    end
    %correct
    mean=meansum/10
    
    base=base+round(mean*1)    
    d(k:end,1) = (data(k:end,1)-base)/70;
end

figure,plot(t(1:end,1),d(1:end,1))
%%
DDD=d;
%% Integrate for Velocity

%Assume that the first reading is at rest
next=[1;next];

for i =2:numel(next)
    T=[];
    k = next(i-1);
    
    %integrate up to the next point of rest
    for j = k:next(i)
        T = [T;0.001*sum(DDD(k:j,1))];
    end

    %store velocity
    V = [V;T];
end
figure, plot(V(1:end))
title('velocity');
% %% Low Pass Filter
% lpFilt = designfilt('lowpassfir','PassbandFrequency',0.01, ...
% 'StopbandFrequency',0.1,'PassbandRipple',0.5, ...
% 'StopbandAttenuation',65,'DesignMethod','kaiserwin');
% velocity=filtfilt(lpFilt,V)
% figure,plot(velocity(1:end))
% title('velocity Filtered')
%% Integrate for Displacement

X = [];
for i =2:numel(next)
    T=[];
    k = next(i-1);
    for j = k:next(i)
        T = [T;0.001*sum(velocity(k:j,1))];
        %T = [T;sum(velocity(k:j,1))];
    end
   
    %displacement is cumulative
    if isempty(X)
        X = [X;T];
    else
        X = [X;T+X(end)];
    end
    
end
%figure, plot(X(1:end))

% T=[]
% for j = 1:numel(vvv)
% T = [T;sum(velocity(1:j,1))];
% end
% figure, plot(T(1:end))
%% Unit scaling
%this scaling factor is related in some way to csample
scaling = 1;
displacement = X*scaling;
figure, plot(displacement(1:end));
title('displacement')