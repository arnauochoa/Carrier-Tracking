function [cm] = localCodeReplica(prn, kDelay, tC, tVec)

% Initializations

code        = ca_code(prn);
% Code samples
c          = create_code_samples(code, tVec/tC); %normalize tvec wrt chip duration
% Shift in time
cm          = circshift(c, kDelay);%-5220 % extra -1 accounts for first sample which is code bit 1023 due to t=0
% cm  = [cm(end-kDelay+1:end) cm(1:end-kDelay)];
end