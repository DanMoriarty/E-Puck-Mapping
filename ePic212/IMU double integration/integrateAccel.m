function [velocity, displacement, V] = integrateAccel(forwardacceleration)
%%integrateAccel integrates accelerometer data to get an approximate value
%%for forward velocity and displacement

%% Initialization
s=0; %rolling sum
point = []; %points less than variance threshold
v = []; %velocity placeholder
V = []; %variance array placeholder
next = []; %zero acceleration point indexes
add=false; %flag for adding to next array

d = forwardacceleration;

%time data
t = 1:size(d,1);
t=t';
%% Tuning Parameters
% The algorithm works by running a window over the last csample-many samples
% from given operating point i
% It calculates the mean and covariance within this windows, and if the
% covariance falls below a threshold value thresh, this operating point is flagged
% as being a point of rest and so the integration process is
% recalibrated to offset drift, as we know this point has 0 acceleration
% and 0 velocity

%csample should be somewhere between 5 and 30, and depends on how long we
%stop for. A shorter csample is preferred, but it must be long enough to
%get a solid average
csample = 2;

%thresh should be reflective of the expected variance from the mean. In
%noisier settings, thresh will have to be raised.
thresh = 1;

%Thresh and csample must be tuned together to ensure that rest-points are
%accurately caught.

% %% Hysteresis Correction
% for i=2:size(d)
%     if d(i)<d(i-1)
%         %d(i) = 2.7254*d(i); %X
%         %d(i) = 2.7254*d(i); %Y
%         %d(i) = 2.12915*d(i); %Z
%     end
% end

%csample = 30;
%thresh = 0.4;

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
%% Integrate for Velocity

%Assume that the first reading is at rest
next=[1;next];

for i =2:numel(next)
    T=[];
    k = next(i-1);
    
    %integrate up to the next point of rest
    for j = k:next(i)
        T = [T;0.001*sum(d(k:j,1))];
    end
    
    %Correct the linearly offsetting error
    grad = (T(end)-T(1))/csample;
    for g = 1:numel(T)
        T(g) = T(g)*grad/t(g)+T(g);
    end
    
    %store velocity
    V = [V;T];
end
figure, plot(V(1:end))
title('velocity');
%% Low Pass Filter
lpFilt = designfilt('lowpassfir','PassbandFrequency',0.01, ...
'StopbandFrequency',0.05,'PassbandRipple',0.5, ...
'StopbandAttenuation',65,'DesignMethod','kaiserwin');
velocity=filtfilt(lpFilt,V)
figure,plot(velocity(1:end))
title('velocity Filtered')
%% Integrate for Displacement

X = [];
for i =2:numel(next)
    T=[];
    k = next(i-1);
    for j = k:next(i)
        T = [T;0.001*sum(velocity(k:j,1))];
        %T = [T;sum(velocity(k:j,1))];
    end
    
    
    grad = (T(end)-T(1))/csample;
    for g = 1:numel(T)
        T(g) = T(g)*grad/t(g)+T(g);
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
scaling = 1/3;
displacement = X*scaling;
figure, plot(displacement(1:end));
title('displacement')
end