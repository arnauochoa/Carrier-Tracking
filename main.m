clear; close all; clc;
%blabla

%% Initializations
prn         = 20;       % -         PRN index
duration    = 3000e-3;  % sec       200 times the PRN
tR          = 1e-3;     % sec       PRN period
prnLength   = 1023;     % samples of the PRN
kDelay      = 8945;     % samples of the PRN
fDoppler    = 1755;     % Hz        Doppler shift
fIF         = 4.348e6;  % Hz        Intermediate frequency
fs          = 23.104e6; % Hz        Sampling frequency
B           = fs/2;     % Hz        RF front-end BW
tI          = 1e-3;     % sec       Integration time
sLength     = duration/tR * prnLength; % Signal length in code samples
tC          = tR/prnLength;
tVec        = 0:1/fs:duration-1/fs;    % Vector of time

%% Configuration
Kpll            = 0.005;    % -         Gain of the 1st order PLL
Bl              = 10;       % Hz        Equivalent bandwidth of the 2nd order PLL
thresHist       = 500e-3;   % sec       Threshold to compute the variance of Vd
fDiff           = 5;        % Hz        Frequency difference between Rx signal and local replica
order           = 2;        % -         Order of the PLL. 1 or 2
useRealSignal   = 0;        % boolean   Flag to use the real signal (1) or the synthetic one (0)
isOpenLoop      = 0;        % boolean   Flag to open the loop (1) or close it (0)

%% Signal loading/generation
if useRealSignal %% Loading real signal
    filepath    = 'test_real_long.dat';
    nSampSignal = duration*fs;
    rxSignal    = DataReader(filepath, nSampSignal)';
else %% Generation of synthetic signal
    A           = 1;        % mW/s       Amplitude of the synthetic signal
    cno         = 50;       % dbHz       C/N0 of the synthetic signal
    phi         = deg2rad(30);
%     phi = linspace(0, 2*pi, length(tVec));
%     phi = sin(2*pi*5*tVec);
    rxSignal    = syntheticSignal(prn, kDelay, A, cno, tC, fIF, phi, tVec, fDoppler+fDiff, B); %fDoppler+fDiff

    % figure; plot(tVec(1:ceil(5*tC*fs)), signal(1:ceil(5*tC*fs)), 'o-');
    % xlabel('Time (s)');
    % ylabel('Amplitude');
end

%% PLL
% Initializations
nSamples = tI*fs;                   % # samples per integration
thetaHat = zeros(duration/tR,1);    % Estimated phase vector
Vd = zeros(duration/tR,1);          % Output of discriminator
Vc = zeros(duration/tR,1);          % Input of NCO for 2nd order PLL
I = zeros(duration/tR,1);           % In-Phase component
Q = zeros(duration/tR,1);           % Quadrature-Phase component
k = 2;                              % Iteration number
iTs = (0:1/fs:tI-1/fs) - tI/2;      % Integration time vector for 2nd order

for t=1:nSamples:length(rxSignal)-nSamples
    % Vector of time during integration period
    tVecInt = tVec(t:t+nSamples-1);
    % Generation of local code replica
    cm = localCodeReplica(prn, kDelay, tC, tVecInt, 0); %fDoppler+fDiff %+Vc(k-1) % TODO: add doppler estimation from Vc
    
    % Frequency of the local replica
    fLO = fIF + fDoppler;
    
    % Multiply received signal by local code replica
    rProd = rxSignal(t:t+nSamples-1) .* cm;
    
    if isOpenLoop
        In = rProd .* cos(2*pi*(fLO)*tVecInt); %#ok<*UNRCH>
        Qn = -rProd .* sin(2*pi*(fLO)*tVecInt);
    else
        In = rProd .* cos(  2*pi*(fLO)*tVecInt  ...
                            - 2*pi*Vc(k-1)*iTs  ... % phase correction due to Doppler within integration interval
                            - thetaHat(k-1));       % phase at beginning of integration interval
        Qn = -rProd .* sin( 2*pi*(fLO)*tVecInt  ...
                            - 2*pi*Vc(k-1)*iTs  ...
                            - thetaHat(k-1));
    end
    
    % I and Q components I&D
    I(k) = (1/nSamples)*sum(In);
    Q(k) = (1/nSamples)*sum(Qn); 
    
    % Discriminator
    Vd(k) = - atan( Q(k)/I(k) );
    
    switch order
        case 1 % First order
            thetaHat(k) = thetaHat(k-1) + Kpll * Vd(k-1);
        case 2 % Second order
            K1 = 60/23 * Bl * tI; 
            K2 = 4/9 * K1^2;
            K3 = 2/27 * K1^3;

            if k-2 <= 0,    Vc2 = Vc(1);    Vd2 = 0;
            else,           Vc2 = Vc(k-2);  Vd2 = Vd(k-2);      end
    
            Vc(k) = 2*Vc(k-1) -                         ...
                    Vc2 +                               ...
                    (K1+K2+K3) * Vd(k)/(2*pi*tI) -      ...
                    (2*K1+K2) * Vd(k-1)/(2*pi*tI) +     ...
                    K1 * Vd2/(2*pi*tI);
                
            thetaHat(k) = thetaHat(k-1) + 2*pi*Vc(k-1)*tI;
        otherwise
            error('Invalid order value');
    end
    k = k + 1;
end

%% Results
% Find k for convergence of Vd.
VdConv = Vd(thresHist/tI:end);

noiseSigmaVd = std(rad2deg(VdConv));

fprintf('\n==== RESULTS ====\n')
fprintf('Noise STD at Vd after %f seconds: %f deg \n', thresHist, noiseSigmaVd);

%% Plots
kVec = 1:duration/tR;

% figure; plot((kVec(1:5)-1)*tC, cm(1:5), 'o-');
% figure; plot(tVec(1:ceil(5*tC*fs)), rxSignal(1:ceil(5*tC*fs)), 'o-');
% xlabel('Time (s)');
% ylabel('Amplitude');
% title('Quantized signal');

figure; plot(thetaHat*180/pi, 'Linewidth', 1.5);
xlabel('Time (ms)'); ylabel('Phase (deg)');
% title('Carrier Phase Tracking');

figure; plot(kVec,Vd*180/pi);
xlabel('Time (ms)'); ylabel('Vd(t) (deg)');
% title('Discriminator output');

if order == 2
    figure; plot(kVec,Vc*180/pi);
    xlabel('Time (ms)'); ylabel('Vc(t) (Hz)');
%     title('NCO input signal');
end
    
figure; plot(kVec,I, 'b'); hold on;
plot(kVec, Q, 'r');
xlabel('Time (ms)'); ylabel('In-Phase and Quadrature amplitude');
legend('I', 'Q')

% figure; plot(kVec, Q./I);
% xlabel('Time (ms)'); ylabel('Q/I (t) (Hz)');
% title('Q-I ratio');

figure;
histogram(rad2deg(VdConv)); 
xlabel('Vd (deg)'); ylabel('Frequency');
% title('Distribution of Vd');

figure;
qqplot(rad2deg(VdConv))
xlabel('Standard Normal Quantiles'); ylabel('Quantiles of Vd');
% title('QQ Plot of Vd vs Standard Normal');
title('');

[Swelch, fwelch] = pwelch(VdConv, 512, 0, 512, 1/tI);
figure;
plot(fwelch./1e3, 10*log10(Swelch));
xlabel('f (kHz)'); ylabel('PSD (dB/Hz)');
% title('Welch periodogram of the discriminator output');


