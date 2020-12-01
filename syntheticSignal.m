function [signal] = syntheticSignal(prn, kDelay, tC, sLength, fIF, phi, tVec, fDoppler)
% This function generates a synthetic signal with the specified parameters

% Initializations
tDelay      = kDelay * tC;

[cm] = localCodeReplica(prn, kDelay, tC, sLength, tVec);
phi = pi/4;%linspace(0, 2*pi, length(tVec));
% phi = sin(2*pi*5*tVec);
signal      = cm .* cos(2*pi*(fIF+fDoppler)*(tVec) + phi);

% Quantization (not necessary)
signal(signal <= -0.5) = -1;
signal(signal >= 0.5) = 1;
signal(signal > -0.5 & signal < 0.5) = 0;

end