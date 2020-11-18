function code_samples = create_code_samples(code_sequence, time_vec)
%%% This function calculates the sampled version of the chosen ca_code_sequence 
%%% code_sequence is the C/A PRN code sequence to be sampled
%%% time_vec is the time vector to be                      time vector for which to be sampled
%                       starting time of the sampling
%                       code doppler
%
%   Output Parameters:  Sampled Array
%
%   Error           : Error message generated if the number of inouts incorrect
%   Date            :    22 May, 2003
%   Author          : Sameet Deshpande
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin~=2
   error('insufficient number of input arguments')
end

code_index = mod( ceil(time_vec), length(code_sequence) );

% Correct for 1023 mod 1023 which returns 0 but should be 1023
code_index( find(code_index == 0) ) = length(code_sequence);
code_samples = code_sequence(code_index);
