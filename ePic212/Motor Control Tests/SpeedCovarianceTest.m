%% SpeedCovariance
pause(2)
dL=[];
dR=[];
speeds = 0:100:400;
j=1;


data = [];
MEAN = [];
COVAR=[];
k=10;
for s = 100:100:300
   
    dL=[];
    dR=[];
    for i=1:5%i = -1000:100:1000
%         k = j;
%         j=xor(1,j);
        [ difL,difR ] = getWheelSpeedDif(ePic,[s s])
        dL=[dL;difL];
        dR=[dR;difR];
    end
    meanL = sum(dL)/k;
    meanR = sum(dR)/k;
    mean = (meanL+meanR)/2;
    MEAN = [MEAN;meanL meanR mean];
    
    covsumL = 0;
    covsumR = 0;
    
    for i=1:5
        covsumL = covsumL+abs(dL(i)-meanL);
        covsumR = covsumR+abs(dR(i)-meanR);
    end
    
    covarL = covsumL/k;
    covarR = covsumR/k;
    avgCovar = (covarL+covarR)/2; 
    COVAR = [COVAR;covarL covarR avgCovar];
    
    data = [data; s mean meanL-meanR avgCovar]
end
%%
    
d = dL-dR;
% %%
% figure(1),
% title('covar')
% s=s';
% plot(zeros(length(data),1),'r.');
% hold on
% plot(data(1:end,6));
% 
% figure(2),
% title('difference at speed 400')
% s=s';
% plot(zeros(length(data),1),'r.');
% hold on
% plot(d);