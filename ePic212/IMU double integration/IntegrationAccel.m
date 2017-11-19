%% Script for getting forward displacement and velocity from fast acceleration data

close all
%clear all
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

%setting data to be zero mean
d = d-369; %X
%d = d-350; %Y
%d = d-397; %Y
%d = d-487; %Z
figure, plot(t(1:end,1),d(1:end));
title('x acceleration (zero mean)')
%%
%Converting into SI units
d=d*9.81/70;

%% Integrator Function

[velocity, displacement, V] = integrateAccel(d);
