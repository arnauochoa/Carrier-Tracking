clear; close all; clc;
%blabla

%% Initializations
prn         = 20;       %           PRN index
duration    = 5000e-3;  % sec   -   200 times the PRN
tR          = 1e-3;     % sec   -   PRN period
prnLength   = 1023;     % samples of the PRN
kDelay      = 8945;     % samples of the PRN
fDoppler    = 1755;     % Hz        Doppler shift
fIF         = 4.348e6;  % Hz        Intermediate frequency
fs          = 23.104e6; % Hz        Sampling frequency
B           = fs/2;     % Hz        RF front-end BW
Bl          = 40;       % Hz        Equivalent bandwidth of the PLL
tI          = 1e-3;     % sec       Integration time
sLength     = duration/tR * prnLength; % Signal length in code samples
tC          = tR/prnLength;
tVec        = 0:1/fs:duration-1/fs;                  % Vector of time
isFirstOrder = 0;
Kpll        = 0.05;
thresHist   = 1200e-3;  % sec       Threshold to compute the variance of Vd

%% Generation of synthetic signal
A           = 1;        % mW/s       Amplitude of the synthetic signal
cno         = 45;       % dbHz      C/N0 of the synthetic signal
phi         = pi/3; 
% phi = linspace(0, 2*pi, length(tVec));
% phi = sin(2*pi*5*tVec);
signal      = syntheticSignal(prn, kDelay, A, cno, tC, fIF, phi, tVec, fDoppler, B);

% figure; plot(tVec(1:ceil(5*tC*fs)), signal(1:ceil(5*tC*fs)), 'o-');
% xlabel('Time (s)');
% ylabel('Amplitude');

%% Loading real signal
filepath = 'test_real_long.dat';
nSampSignal = duration*fs;
% signal      = DataReader(filepath, nSampSignal)';

%% Generation of local code replica
cm = localCodeReplica(prn, kDelay, tC, tVec);

%% PLL
nSamples = tI*fs;
theta = zeros(1,length(tVec));
Vd = zeros(duration/tR,1);
Vc = zeros(duration/tR,1);
I = zeros(duration/tR,1);
Q = zeros(duration/tR,1);
k = 2;
iTs = 0:1/fs:tI-1/fs;
for t=1:nSamples:length(signal)-nSamples
    In = signal(t:t+nSamples-1)     ...
        .*cm(t:t+nSamples-1)        ... %add doppler in code
        .*cos(2*pi*(fIF+fDoppler)*tVec(t:t+nSamples-1) - theta(t:t+nSamples-1));
    Qn = signal(t:t+nSamples-1)     ...
        .*cm(t:t+nSamples-1)        ...
        .*sin(2*pi*(fIF+fDoppler)*tVec(t:t+nSamples-1) - theta(t:t+nSamples-1));
     
    I(k) = (1/nSamples)*sum(In);
    Q(k) = (1/nSamples)*sum(Qn); 
    
    if isFirstOrder
        Vd(k) = atan2( Q(k), I(k) );
        theta(t+nSamples:t+2*nSamples-1) = theta(t:t+nSamples-1) + Kpll * Vd(k);
    else
        Vd(k) = atan2( Q(k), I(k) );
        
        K1 = 60/23 * Bl * tI; 
        K2 = 4/9 * K1^2;
        K3 = 2/27 * K1^3;

        if k-2 <= 0,    Vc2 = 0;        Vd2 = 0;
        else,           Vc2 = Vc(k-2);  Vd2 = Vd(k-2);      end

        Vc(k) = 2*Vc(k-1) -                     ...
                Vc2 +                           ...
                (K1+K2+K3) * Vd(k)/(2*pi*tI)  - ...
                (2*K1+K2) * Vd(k-1)/(2*pi*tI) + ...
                K1 * Vd2/(2*pi*tI);

        theta(t+nSamples:t+2*nSamples-1) = theta(t:t+nSamples-1) + 2*pi*Vc(k)*iTs;
    end
    k = k + 1;
end

%% Results
% Find k for convergence of Vd.
VdConv = Vd(thresHist/tI:end);

noisePowerVd = var(rad2deg(VdConv));

fprintf('\n==== RESULTS ====\n')
fprintf('Noise power at Vd after %f seconds: %f deg^2 \n', thresHist, noisePowerVd);

%% Plots
kVec = 1:duration/tR;

% figure; plot((kVec(1:5)-1)*tC, cm(1:5), 'o-');
figure; plot(tVec(1:ceil(5*tC*fs)), signal(1:ceil(5*tC*fs)), 'o-');
xlabel('Time (s)');
ylabel('Amplitude');
title('Quantized signal');

figure; plot(tVec*1000,theta*180/pi);
xlabel('Time (ms)'); ylabel('Phase (deg)');
title('Carrier Phase Tracking');

figure; plot(kVec,Vd*180/pi);
xlabel('Time (ms)'); ylabel('Vd(t) (deg)');
title('Discriminator output');

figure; plot(kVec,Vc*180/pi);
xlabel('Time (ms)'); ylabel('Vc(t) (Hz)');
title('NCO input signal');

figure; plot(kVec,I, 'b'); hold on;
plot(kVec, Q, 'r');
xlabel('Time (ms)'); 
title('In-Phase and Quadrature components');
legend('I', 'Q')

figure; plot(kVec, Q./I);
xlabel('Time (ms)'); ylabel('Q/I (t) (Hz)');
title('Q-I ratio');

figure;
histogram(rad2deg(VdConv));
xlabel('Vd (deg)'); ylabel('Counts');
title('Distribution of Vd')



