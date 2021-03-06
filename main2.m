clear all; close all;

% available_graphics_toolkits ()
% graphics_toolkit("gnuplot");
% graphics_toolkit("qt");
% graphics_toolkit("fltk");

% For Octave only
% pkg load signal;

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
order       = 2;        % -         Order of the PLL. 1 or 2
Kpll        = 0.01;     % -         Gain of the 1st order PLL
Bl          = 10;       % Hz        Equivalent bandwidth of the 2nd order PLL
thresHist   = 500e-3;   % sec       Threshold to compute the variance of Vd

%% Generation of synthetic signal
A           = 1;        % mW/s       Amplitude of the synthetic signal
cno         = 60;       % dbHz       C/N0 of the synthetic signal
phi         = deg2rad(30);
% phi = linspace(0, 2*pi, length(tVec));
% phi = sin(2*pi*5*tVec);
signal      = syntheticSignal(prn, kDelay, A, cno, tC, fIF, phi, tVec, fDoppler, B);

% figure; plot(tVec(1:ceil(5*tC*fs)), signal(1:ceil(5*tC*fs)), 'o-');
% xlabel('Time (s)');
% ylabel('Amplitude');

%% Loading real signal
filepath = 'test_real_long.dat';
nSampSignal = duration*fs;
signal      = DataReader(filepath, nSampSignal)';

%% Generation of local code replica
cm = localCodeReplica(prn, kDelay, tC, tVec);

%% PLL
nSamples = tI*fs;
Vd = zeros(duration/tR,1);
Vc = zeros(duration/tR,1);
I = zeros(duration/tR,1);
Q = zeros(duration/tR,1);
theta_hat = zeros(duration/tR,1);

% Frequency difference between the local replica and the incoming signal,
switch order
  case 1 % First order
    freq_diff = 0;
  case 2 % Second order
    freq_diff = 0;
  otherwise
    error('Invalid order value');
end

open_loop = false;

k = 2;
iTs = [0:1/fs:tI-1/fs] - tI/2;
% - tI/2 is added to be conformant with theory, it works without it as 
% the dynamic of the phase of the incoming signal is low wrt the frequency of 
% the loop itself.
for t=1:nSamples:length(signal)-nSamples
    In = signal(t:t+nSamples-1).*cm(t:t+nSamples-1);  
    if (open_loop == false)
      Qn = -In.*sin(2*pi*(fIF+fDoppler + freq_diff)*tVec(t:t+nSamples-1) ...
        - 2*pi*Vc(k-1)*iTs - theta_hat(k-1));
      In = In.*cos(2*pi*(fIF+fDoppler + freq_diff)*tVec(t:t+nSamples-1) ...
        - 2*pi*Vc(k-1)*iTs - theta_hat(k-1));
    else
      Qn = -In.*sin(2*pi*(fIF+fDoppler + freq_diff)*tVec(t:t+nSamples-1));
      In = In.*cos(2*pi*(fIF+fDoppler + freq_diff)*tVec(t:t+nSamples-1));
    end
    
    I(k) = (1/nSamples)*sum(In);
    Q(k) = (1/nSamples)*sum(Qn); 
    
    % Vd(k) = - atan2( Q(k), I(k) );
    Vd(k) = - atan(Q(k)/I(k));
    
    switch order
        case 1 % First order
            theta_hat(k) = theta_hat(k-1) + Kpll * Vd(k);
        case 2 % Second order
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

            theta_hat(k) = theta_hat(k-1) + 2*pi*Vc(k-1)*tI;
        otherwise
            error('Invalid order value');
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

figure; % plot(theta(nSamples/2:nSamples:end)*180/pi);
plot(kVec,theta_hat*180/pi);
xlabel('Time (ms)'); ylabel('Phase (deg)');
title('Carrier Phase Tracking');

figure; plot(kVec,Vd*180/pi);
xlabel('Time (ms)'); ylabel('Vd(t) (deg)');
title('Discriminator output');

if order == 2
    figure; plot(kVec,Vc);
    xlabel('Time (ms)'); ylabel('Vc(t) (Hz)');
    title('NCO input signal');
end
    
figure; plot(kVec,I, 'b'); hold on;
plot(kVec, Q, 'r');
xlabel('Time (ms)'); 
title('In-Phase and Quadrature components');
legend('I', 'Q')

figure; plot(kVec, Q./I);
xlabel('Time (ms)'); ylabel('Q/I (t) (Hz)');
title('Q-I ratio');

figure;
hist(rad2deg(VdConv)); 
xlabel('Vd (deg)'); ylabel('Counts');
title('Distribution of Vd');

% TODO: Add qqplot

[Swelch, fwelch] = pwelch(VdConv, 512, 0, 512, 1/tI);
figure
plot(fwelch./1e3, 10*log10(Swelch));
xlabel('f (kHz)'); ylabel('PSD (dB/Hz)');
title('Welch periodogram of the discriminator output');
