function [cm] = localCodeReplica(prn, kDelay, tC, sLength, tVec)

% Initializations
kVec        = 1:sLength;                        % Vector of samples

code        = ca_code(prn);
% Code samples
c          = create_code_samples(code, tVec*1023/1e-3); %normalize tvec wrt chip duration
% Shift in time
cm          = circshift(c, length(c) - kDelay);
% Modulation
% cm = ones(1, length(tVec));
% for t = 1:length(tVec)-1
%     cm(t) = c(fix(tVec(t)/tC)+1);
% end

end