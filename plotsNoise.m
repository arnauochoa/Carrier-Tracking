clear all; close all; clc;
%% Noise charactization plots

Bl = [10 20 30 40 50 60];
cn0 = [35 40 45 50 60];
noisePowerBl10 = [1090.278549 271.844448 80.020182 24.870782 2.447463]; 
thresholdBl10 = [1000 1100 1100 1500 2000];
noisePowerBl20 = [1134.436031 264.879452 79.240616 25.433156 2.426378]; 
thresholdBl20 = [1000 1000 1000 1200 1200];
noisePowerBl30 = [1236.048311 281.420084 81.877807 24.411705 2.502479]; 
thresholdBl30 = [1000 1000 1000 900 800];
noisePowerBl40 = [1234.120404 271.186310 81.766125 25.189881 2.527062]; 
thresholdBl40 = [800 800 800 700 600];
noisePowerBl50 = [1243.855370 286.371578 81.335278 26.410251 2.656466]; 
thresholdBl50 = [800 800 600 600 500];
noisePowerBl60 = [1237.519903 281.098273 87.126546 26.700544 2.683888]; 
thresholdBl60 = [500 500 500 500 500];

noisePower = [noisePowerBl10' noisePowerBl20' noisePowerBl30' noisePowerBl40' noisePowerBl50' noisePowerBl60'];
noiseThreshold = [thresholdBl10' thresholdBl20' thresholdBl30' thresholdBl40' thresholdBl50' thresholdBl60'];

[BL,CN0] = meshgrid(Bl,cn0);

figure; plot(cn0, noisePowerBl10, ...
             cn0, noisePowerBl20, ...
             cn0, noisePowerBl30, ...
             cn0, noisePowerBl40, ...
             cn0, noisePowerBl50, ...
             cn0, noisePowerBl60);
xlabel('CN0'); ylabel('Noise Power (W/Hz)');
legend('BW = 10 Hz', 'BW = 20 Hz', 'BW = 30 Hz', 'BW = 40 Hz', 'BW = 50 Hz', 'BW = 60 Hz')
title('Comparison of noise PSD at discriminator output');

figure; plot(Bl, noisePower(1,:), ...
             Bl, noisePower(2,:), ...
             Bl, noisePower(3,:), ...
             Bl, noisePower(4,:), ...
             Bl, noisePower(5,:));
xlabel('BW (Hz)'); ylabel('Noise Power (W/Hz)');
legend('CN0 = 35', 'CN0 = 40', 'CN0 = 45', 'CN0 = 50', 'CN0 = 60')
title('Comparison of noise PSD at discriminator output');

figure; plot(cn0, thresholdBl10, ...
             cn0, thresholdBl20, ...
             cn0, thresholdBl30, ...
             cn0, thresholdBl40, ...
             cn0, thresholdBl50, ...
             cn0, thresholdBl60);
xlabel('CN0'); ylabel('Convergence time (sec)');
legend('BW = 10 Hz', 'BW = 20 Hz', 'BW = 30 Hz', 'BW = 40 Hz', 'BW = 50 Hz', 'BW = 60 Hz')
title('Convergence time comparison');

figure;
[~,ph] = contourf(BL, CN0, noisePower);
set(ph,'LineColor','none')
grid off;
xlabel('Bandwidth (Hz)'); ylabel('CN0'); 
k = colorbar;
set(get(k,'label'),'string', 'Noise Power');
title('Noise Power at Discriminator Output');
