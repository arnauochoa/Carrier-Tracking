clear; close all; clc;
%blabla

%% Initializations
prn         = 20;       %           PRN index
duration    = 200e-3;   % sec   -   200 times the PRN
tR          = 1e-3;     % sec   -   PRN period
prnLength   = 1023;     % samples
kDelay      = 8945;     % samples
fDoppler    = 1755;     % Hz
fIF         = 4.348e6;  % Hz
fs          = 23.104e6; % Hz
phi         = 0;        % Phase delay
sLength     = duration/tR * prnLength; % Signal length in samples
tC          = tR/prnLength;
tDelay      = kDelay * tC;

%% Generation of signal
tVec        = 0:1/fs:duration;                  % Vector of time
kVec        = 1:sLength;                            % Vector of samples
code        = ca_code(prn);
% Code samples
cm          = create_code_samples(code, kVec);
% Shift in time
cm          = circshift(cm, sLength - kDelay);
% Modulation
signal = ones(1, length(tVec));
for t = 1:length(tVec)-1
    signal(t) = cm(fix(tVec(t)/tC)+1);
end
signal      = signal .* cos(2*pi*fIF*(tVec-tDelay) + phi);

% Quantization
signal(signal <= -0.5) = -1;
signal(signal >= 0.5) = 1;
signal(signal > -0.5 & signal < 0.5) = 0;

figure; plot((kVec(1:5)-1)*tC, cm(1:5), 'o-');
figure; plot(tVec(1:ceil(5*tC*fs)), signal(1:ceil(5*tC*fs)), 'o-');
xlabel('Time (s)');
ylabel('Amplitude');


%% PLL


