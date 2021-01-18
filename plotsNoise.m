clear all; close all; clc;
%% Noise charactization plots: First Order PLL
Kpll = [0.01 0.05 0.1 0.5];
cn0 = [35 40 45 50 60];

%% TODO change noise power in dB by STD in linear
noisePowerK001 = [652.237448 183.196869 52.791025 16.658201 1.599654];
thresholdK001 = [500 500 500 500 500];
noisePowerK005 = [677.620497 183.658355 54.505032 16.910811 1.639800];
thresholdK005 = [500 500 500 500 500];
noisePowerK01 = [698.782236 186.214484 54.790660 17.211559 1.720205];
thresholdK01 = [500 500 500 500 500];
noisePowerK05 = [915.654036 223.374036 70.439770 22.394798 2.072684];
thresholdK05 = [500 500 500 500 500];

noisePowerKdB = 10*log10([noisePowerK001' noisePowerK005' noisePowerK01' noisePowerK05']);
noiseThresholdK = [thresholdK001' thresholdK005' thresholdK01' thresholdK05'];

[KPLL,CN0] = meshgrid(Kpll,cn0);

figure; plot(cn0, noisePowerKdB(:,1), ...
             cn0, noisePowerKdB(:,2), ...
             cn0, noisePowerKdB(:,3), ...
             cn0, noisePowerKdB(:,4));
xlabel('CN0'); ylabel('Noise Power (dB)');
legend('Kpll = 0.01', 'Kpll = 0.05', 'Kpll = 0.1', 'Kpll = 0.5');
title('Comparison of noise PSD at discriminator output');

figure; plot(Kpll, noisePowerKdB(1,:), ...
             Kpll, noisePowerKdB(2,:), ...
             Kpll, noisePowerKdB(3,:), ...
             Kpll, noisePowerKdB(4,:), ...
             Kpll, noisePowerKdB(5,:));
xlabel('Kpll'); ylabel('Noise Power (dB)');
legend('CN0 = 35', 'CN0 = 40', 'CN0 = 45', 'CN0 = 50', 'CN0 = 60')
title('Comparison of noise PSD at discriminator output');

figure; plot(cn0, thresholdK001, ...
             cn0, thresholdK005, ...
             cn0, thresholdK01, ...
             cn0, thresholdK05);
xlabel('CN0'); ylabel('Convergence time (sec)');
legend('Kpll = 0.01', 'Kpll = 0.05', 'Kpll = 0.1', 'Kpll = 0.5');
title('Convergence time comparison');

figure;
[~,ph] = contourf(KPLL, CN0, noisePowerKdB);
set(ph,'LineColor','none')
grid off;
xlabel('Kpll'); ylabel('CN0'); 
k = colorbar;
set(get(k,'label'),'string', 'Noise Power (dB)');
title('Noise Power at Discriminator Output');

%% Noise charactization plots: Second Order PLL
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

noisePowerdB = 10*log10([noisePowerBl10' noisePowerBl20' noisePowerBl30' noisePowerBl40' noisePowerBl50' noisePowerBl60']);
noiseThreshold = [thresholdBl10' thresholdBl20' thresholdBl30' thresholdBl40' thresholdBl50' thresholdBl60'];

[BL,CN0] = meshgrid(Bl,cn0);

figure; plot(cn0, noisePowerdB(:,1), ...
             cn0, noisePowerdB(:,2), ...
             cn0, noisePowerdB(:,3), ...
             cn0, noisePowerdB(:,4), ...
             cn0, noisePowerdB(:,5), ...
             cn0, noisePowerdB(:,6));
xlabel('CN0'); ylabel('Noise Power (dB)');
legend('BW = 10 Hz', 'BW = 20 Hz', 'BW = 30 Hz', 'BW = 40 Hz', 'BW = 50 Hz', 'BW = 60 Hz')
title('Comparison of noise PSD at discriminator output');

figure; plot(Bl, noisePowerdB(1,:), ...
             Bl, noisePowerdB(2,:), ...
             Bl, noisePowerdB(3,:), ...
             Bl, noisePowerdB(4,:), ...
             Bl, noisePowerdB(5,:));
xlabel('BW (Hz)'); ylabel('Noise Power (dB)');
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
[~,ph] = contourf(BL, CN0, noisePowerdB);
set(ph,'LineColor','none')
grid off;
xlabel('Bandwidth (Hz)'); ylabel('CN0'); 
k = colorbar;
set(get(k,'label'),'string', 'Noise Power (dB)');
title('Noise Power at Discriminator Output');
