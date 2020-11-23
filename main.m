clear; close all; clc;

filepath = 'test_real_long.dat';

% signal = DataReader(filepath, Inf);

load('subsignal.mat');

N = 2^20;
fIF = 4.348e6; %Hz
fs = 23.104e6; %Hz

s = signal5000(1:4096);

omega = linspace(-2*pi, 2*pi, 2*N);

figure
plot(s, 'o-');

figure;
histogram(s);
title('Quantized signal in time domain');
xlabel('k');

S = fft(s);

w = linspace(-2*pi,2*pi,length(s));
figure
plot(w, fftshift(abs(S)));
title('Quantized signal in frequency domain');
xlabel('w');

Rs = xcorr(s, 'biased');
Ss = fft(Rs, 2*N);

% figure;
% plot(fftshift(abs(Ss)));
% title('Spectral density from autocorrelation');
% xlabel('w');
% 
% [Ss, f] = periodogram(s, rectwin(length(s)), [], fs);
% figure
% plot(f/1e6, 10*log10(Ss));
% % plot([-flip(f); f], [flip(Ss); Ss]);
% title('Periodogram');
% xlabel('f (MHz)'); ylabel('PSD (dB/Hz)')

[Swelch, fwelch] = pwelch(s, 30, 15, [], fs);
figure
% plot([-flip(fwelch); fwelch]./1e6, [flip(Swelch); Swelch]);
plot(fwelch./1e6, 10*log10(Swelch)); hold on;
xline(fIF/1e6);
xlabel('f (MHz)'); ylabel('PSD (dB/Hz)');
title('Welch periodogram');






