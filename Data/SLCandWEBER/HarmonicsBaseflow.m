clear; close all; more off; 
% these are the hourly co2 data analyzed on page 5 in the notes
load('allbaseflow.mat')
NoNanBase=csvread('NoNanBase.csv')
%%
DVmeanbase=NoNanBase-nanmean(NoNanBase)

y = DVmeanbase(:,12)



%% fit the second harmonic to these data using multiple linear regression
%   and plot it on time series
N = length(y); % length of record
dt = 1; % sampling interval
t = (0:dt:N-1)'; % time vector
f = 2/(N*dt); % frequency of second harmonic
X = [cos(2*pi*f*t) sin(2*pi*f*t)]; % predictor matrix
b = X\y; % same as regress(y,X)
A_2 = sqrt(b(1)^2 + b(2)^2)
psi_2 = atan2(b(2),b(1))
figure; plot(t,y,'ko-'); 
hold on; plot(t,X*b,'g-'); 
set(gca,'xlim',[t(1)-1 t(end)+1]); 
lg = legend('data','regression'); 
set(lg,'location','northeast'); 
xlabel('time (hour)'); 
ylabel('concentration anomaly'); 

%% calculate the discrete Fourier transform 
dft = fft(y); 

%% reproduce the F2 Fourier coefficient using a loop (not fft.m) 
format short; clc
disp(dft(3)); % F2 coefficient from fft 
F_2 = 0; h = 2; 
for k=0:N-1
    F_2 = F_2 + y(k+1)*exp(-1i*2*pi*k*h/N); 
end
disp(F_2)
%% fit the second harmonic to these data using fft.m 
%   and plot it on time series
dft = fft(y);
A_2 = 2/N*abs(dft(3))
psi_2 = atan2(-imag(dft(3)),real(dft(3)))
h2 = A_2*cos(2*pi*2/(N*dt)*t-psi_2);
figure; plot(t,y,'ko-'); 
hold on; plot(t,X*b,'g-'); % regression fit 
plot(t,h2+mean(y),'bs','markerfacecolor','b'); % fft fit 
lg = legend('data','regression','fft'); 
set(lg,'location','northeast'); 
xlabel('time (hour)'); 
ylabel('concentration anomaly'); 
%% model the time seires using N/2 = 12 harmonics using regress 
X = []; 
for h = 0:12
    f = h/(N*dt); % frequency of hth harmonic
    X = [X cos(2*pi*f*t) sin(2*pi*f*t)]; % predictor matrix
end
b = X\y; % same as regress(y,X)
figure; plot(t,y,'ko'); 
hold on; plot(t,X*b,'g-'); % regression fit 
lg = legend('data','regression'); 
set(lg,'location','northeast'); 
xlabel('time (Year)'); 
ylabel('Storage anomaly'); 
title('PC')
WO=X*b
save('WOHarmonic.mat','WO')
%%
load('CCHarmonic.mat')
%skip RB not too many nans
load('ECHarmonic.mat')
load('PCHarmonic.mat')
load('MCHarmonic.mat')
load('BCHarmonic.mat')
load('LCHarmonic.mat')
load('WOHarmonic.mat')

X1=nan(118,7)
X1(:,1)=CC
X1(:,2)=EC
X1(:,3)=PC
X1(:,4)=MC
X1(:,5)=BC
X1(:,6)=LC
X1(:,7)=WO
ColorSet=varycolor(7);
figure; 
for i=1:7
  

plot(t,X1(:,i),'Color',ColorSet(i,:),'linewidth',2); % regression fit 
hold on;
 
legend('Harmonic Fit CC','Harmonic Fit EC','Harmonic Fit PC','Harmonic Fit MC','Harmonic Fit BC','Harmonic Fit LC','Harmonic Fit WO','location','northeast','fontsize',14); 
xlabel('time (Year +1901)','fontsize',14); 
ylabel('Storage anomaly','fontsize',14); 
title('Harmonic Analysis Storage Dev Mean')
end