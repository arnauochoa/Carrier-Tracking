clear; close all; clc;

filepath = 'test_real_long.dat';

Nsamp = 500*4096;
signal = DataReader(filepath, Nsamp);

N = 2^20;
fIF = 4.348e6; %Hz
fs = 23.104e6; %Hz

s = signal(1:Nsamp);

omega = linspace(-2*pi, 2*pi, 2*N);

figure
plot(s(1:200), 'o-');

figure;
histogram(s);
title('Quantized signal in time domain');
xlabel('k');


[Swelch, fwelch] = pwelch(s, 256, 0, 256, fs);
figure
plot(fwelch./1e6, 10*log10(Swelch)); hold on;
xline(fIF/1e6);
xlabel('f (MHz)'); ylabel('PSD (dB/Hz)');
title('Welch periodogram');






