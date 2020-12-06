function [cm] = localCodeReplica(prn, kDelay, tC, sLength, tVec)

% Initializations
% kVec        = 1:sLength;                        % Vector of samples

code        = ca_code(prn);
% Code samples
cm          = create_code_samples(code, tVec/tC); %normalize tvec wrt chip duration
% Shift in time
cm          = circshift(cm, length(cm) - kDelay); 

end