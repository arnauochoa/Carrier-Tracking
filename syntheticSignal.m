function [signal] = syntheticSignal(prn, kDelay, tC, sLength, fIF, phi, tVec)
% This function generates a synthetic signal with the specified parameters

% Initializations
tDelay      = kDelay * tC;

[cm] = localCodeReplica(prn, kDelay, tC, sLength, tVec);
phi = linspace(0, 2*pi, length(tVec));
% phi = sin(2*pi*5*tVec);
signal      = cm .* cos(2*pi*fIF*(tVec-tDelay) + phi);

% Quantization
signal(signal <= -0.5) = -1;
signal(signal >= 0.5) = 1;
signal(signal > -0.5 & signal < 0.5) = 0;

end