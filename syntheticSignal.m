function [signal] = syntheticSignal(prn, kDelay, A, cno, tC, fIF, phi, tVec, fDoppler)
% This function generates a synthetic signal with the specified parameters

% Initializations

[cm] = localCodeReplica(prn, kDelay, tC, tVec);

% Noise
cno = 10^(cno/10);
noiseSTD    = sqrt( (A^2) / (4*cno) );
bf          = normrnd(0, noiseSTD, size(tVec));

% Signal generation
signal  = A * cm .* cos(2*pi*(fIF+fDoppler)*(tVec) + phi) + bf;

% Quantization (not necessary)
% signal(signal <= -0.5) = -1;
% signal(signal >= 0.5) = 1;
% signal(signal > -0.5 & signal < 0.5) = 0;

end