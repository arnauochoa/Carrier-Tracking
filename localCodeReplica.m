function [cm] = localCodeReplica(prn, kDelay, tC, tVec, fDoppler)

% Obtain code for specific satellite prn
code        = ca_code(prn);
% Code duration due to Doppler
fChip = 1/tC;
tChipDoppler = 1/(fChip + fDoppler);
% Code samples
c           = create_code_samples(code, tVec/tChipDoppler); %normalize tvec wrt chip duration
% Shift in time
cm          = circshift(c, kDelay);
% cm  = [cm(end-kDelay+1:end) cm(1:end-kDelay)];
end