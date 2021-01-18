clear; close all; clc;

filepath = 'test_real_long.dat';

Nsamp = 2000*4096;
signal = DataReader(filepath, Nsamp);

N = 2^20;
fIF = 4.348e6; %Hz
fs = 23.104e6; %Hz

s = signal(1:Nsamp);

omega = linspace(-2*pi, 2*pi, 2*N);

figure
plot(s(1:200), 'o-', 'Linewidth', 1);
xlabel('Samples'); ylabel('Quantized amplitude');
% title('Quantized signal in time domain');

figure;
histogram(s);
xticks([-1 0 1])
% title('Distribution of symbols of the received signal')
xlabel('Quantized amplitude'); ylabel('Frequency')

[Swelch, fwelch] = pwelch(s, 512, 0, 512, fs);
figure
plot(fwelch./1e6, 10*log10(Swelch), 'Linewidth', 1.2); hold on;
xline(fIF/1e6, 'k','Linewidth', 1.2);
xlabel('f (MHz)'); ylabel('PSD (dB/Hz)');
% title('Periodogram of the received signal');
