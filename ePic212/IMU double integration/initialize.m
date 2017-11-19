function [ ePic ] = initialize( port )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

%% Script for controlling an E-puck via Matlab
% To use, must be within the ePic2 home folder
%
%% Clear environment
try 
    ePic = disconnect(ePic)
catch
end
% clear all
clc
close all
%% Initialise a connection
%Must be paired over bluetooth with e-puck
%Bluetooth firmware (eg BTcom) must be on the epuck or it must be operating
%in such a way that it can translate asercom commands over a UART
%connection

ePic=ePicKernel
%port = input('What COM port? ''COMXX''\n');%'COM6';

ePic=connect(ePic,port)
flush(ePic);

%assert(ePic.param.connected ~= 0)

%% Update once
ePic = update(ePic);

end

