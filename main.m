clear; close all; clc;
%blabla

%% Initializations
prn         = 20;       %           PRN index
duration    = 200e-3;   % sec   -   200 times the PRN
tR          = 1e-3;     % sec   -   PRN period
prnLength   = 1023;     % samples of the PRN
kDelay      = 8945;     % samples of the PRN
fDoppler    = 1755;     % Hz
fIF         = 4.348e6;  % Hz
fs          = 23.104e6; % Hz
phi         = 0;        % Phase delay
sLength     = duration/tR * prnLength; % Signal length in samples
tC          = tR/prnLength;

%% Generation of synthetic signal
% tVec        = 0:1/fs:duration-1/fs;                  % Vector of time
% signal      = syntheticSignal(prn, kDelay, tC, sLength, fIF, phi, tVec);

% figure; plot(tVec(1:ceil(5*tC*fs)), signal(1:ceil(5*tC*fs)), 'o-');
% xlabel('Time (s)');
% ylabel('Amplitude');

%% Loading real signal
filepath = 'test_real_long.dat';
tVec        = 0:1/fs:duration;                  % Vector of time
nSampSignal = duration*fs;
signal      = DataReader(filepath, nSampSignal)';

%% Generation of local code replica
cm = localCodeReplica(prn, kDelay, tC, sLength, tVec);

%% PLL
nSamples = tR*fs;
theta = zeros(duration/tR,1);
Ve = zeros(duration/tR,1);
k = 2;
for t=1:nSamples:length(signal)-nSamples
    In = signal(t:t+nSamples-1).*cm(t:t+nSamples-1).*cos(2*pi*fIF*tVec(t:t+nSamples-1)-theta(k-1));
    Qn = signal(t:t+nSamples-1).*cm(t:t+nSamples-1).*sin(2*pi*fIF*tVec(t:t+nSamples-1)-theta(k-1));
    
    I = (1/nSamples)*sum(In);
    Q = (1/nSamples)*sum(Qn);
    
    Ve(k) = atan2(Q,I);
    theta(k) = theta(k-1) + Ve(k);
    k = k + 1;
end

%% Plots
kVec = 1:duration/tR;

figure; plot((kVec(1:5)-1)*tC, cm(1:5), 'o-');
figure; plot(tVec(1:ceil(5*tC*fs)), signal(1:ceil(5*tC*fs)), 'o-');
xlabel('Time (s)');
ylabel('Amplitude');

figure; plot(kVec,theta*180/pi);
xlabel('Time (ms)'); ylabel('Phase (deg)');
title('Carrier Phase Tracking');

figure; plot(kVec,Ve*180/pi);
xlabel('Time (ms)'); ylabel('Phase (deg)');
title('Carrier Phase Tracking');